//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetup.h"
#import "MafiaDocuments.h"
#import "MafiaPerson.h"
#import "MafiaRole.h"
#import "NSError+MafiaAdditions.h"


static NSString *const kGameSetupFilenamePrefix = @"GameSetup_";
static NSString *const kGameSetupFilenameSuffix = @".json";
static NSString *const kGameSetupRecent = @"[Recent]";


@implementation MafiaGameSetup


- (instancetype)init {
    if (self = [super init]) {
        _persons = [NSMutableArray arrayWithCapacity:20];
        _isTwoHanded = YES;
        _isAutonomic = NO;
        _roleSettings = [@{
            [MafiaRole killer]: @2,
            [MafiaRole detective]: @2,
            [MafiaRole assassin]: @0,
            [MafiaRole guardian]: @1,
            [MafiaRole doctor]: @1,
            [MafiaRole traitor]: @1,
            [MafiaRole undercover]: @0,
        } mutableCopy];
        _date = [NSDate date];
    }
    return self;
}


- (void)addPerson:(MafiaPerson *)person {
    if (person != nil && ![self.persons containsObject:person]) {
        [self.persons addObject:person];
    }
}


- (NSInteger)numberOfActorsForRole:(MafiaRole *)role {
    return [self.roleSettings[role] intValue];
}


- (void)setNumberOfActors:(NSInteger)numberOfActors forRole:(MafiaRole *)role {
    self.roleSettings[role] = @(numberOfActors);
}


- (NSInteger)numberOfPersonsRequired {
    NSInteger numberOfRoles = 0;
    for (MafiaRole *role in self.roleSettings) {
        numberOfRoles += [self.roleSettings[role] intValue];
    }
    return (NSInteger)ceil(numberOfRoles * (self.isTwoHanded ? 0.7 : 1.4));
}


- (BOOL)isValid {
    return ([self.persons count] >= [self numberOfPersonsRequired]);
}


#pragma mark - Saving / Loading / Removing / Listing


- (BOOL)saveWithName:(NSString *)name {
    NSString *filename = [[self class] mafia_gameSetupFilenameForName:name];
    NSError *error = nil;
    NSDictionary *dictionary = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
    return [MafiaDocuments saveDictionary:dictionary toFile:filename];
}


- (BOOL)saveAsRecent {
    return [self saveWithName:kGameSetupRecent];
}


+ (instancetype)loadWithName:(NSString *)name {
    NSString *filename = [self mafia_gameSetupFilenameForName:name];
    NSDictionary *dictionary = [MafiaDocuments dictionaryWithContentsOfFile:filename];
    NSError *error = nil;
    MafiaGameSetup *gameSetup = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dictionary error:&error];
    if (gameSetup == nil || error != nil) {
        NSLog(@"Fail to load game setup from file: %@", error);
    }
    return gameSetup;
}


+ (instancetype)loadRecent {
    MafiaGameSetup *gameSetup = [self loadWithName:kGameSetupRecent];
    if (gameSetup == nil) {
        gameSetup = [[self alloc] init];
    }
    return gameSetup;
}


+ (void)removeGameSetupWithName:(NSString *)name {
    NSString *filename = [self mafia_gameSetupFilenameForName:name];
    [MafiaDocuments removeItemWithName:filename];
}


+ (NSArray *)namesOfSavedGameSetups {
    NSArray *filenames = [MafiaDocuments filenamesOfDirectoryWithName:nil];
    NSMutableArray *gameSetupNames = [[NSMutableArray alloc] initWithCapacity:[filenames count]];
    for (NSString *filename in filenames) {
        if ([filename hasPrefix:kGameSetupFilenamePrefix] && [filename hasSuffix:kGameSetupFilenameSuffix]) {
            NSUInteger location = [kGameSetupFilenamePrefix length];
            NSUInteger length = [filename length] - [kGameSetupFilenameSuffix length] - location;
            NSString *gameSetupName = [filename substringWithRange:NSMakeRange(location, length)];
            [gameSetupNames addObject:gameSetupName];
        }
    }
    return gameSetupNames;
}


+ (NSString *)mafia_gameSetupFilenameForName:(NSString *)name {
    NSMutableCharacterSet *invalidCharacters = [[NSMutableCharacterSet alloc] init];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet illegalCharacterSet]];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [invalidCharacters removeCharactersInString:@"()[]-_"];  // some allowed symbols...
    name = [[name componentsSeparatedByCharactersInSet:invalidCharacters] componentsJoinedByString:@""];
    return [NSString stringWithFormat:@"%@%@%@", kGameSetupFilenamePrefix, name, kGameSetupFilenameSuffix];
}


#pragma mark - MTLJSONSerializing


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"persons": @"persons",
        @"isTwoHanded": @"is_two_handed",
        @"isAutonomic": @"is_autonomic",
        @"roleSettings": @"role_settings",
        @"date": @"date",
    };
}


+ (NSValueTransformer *)personsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MafiaPerson class]];
}


+ (NSValueTransformer *)dateJSONTransformer {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    });

    return [MTLValueTransformer
        transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError **error) {
            return [dateFormatter dateFromString:dateString];
        }
        reverseBlock:^id(NSDate *date, BOOL *success, NSError **error) {
            return [dateFormatter stringFromDate:date];
        }];
}


+ (NSValueTransformer *)roleSettingsJSONTransformer {
    return [MTLValueTransformer
        transformerUsingForwardBlock:^(NSDictionary *dictionary, BOOL *success, NSError **error) {
            // Transform from a dictionary where key is role name, and value is number of actors.
            NSMutableDictionary *roleSettings = [[NSMutableDictionary alloc] initWithCapacity:[dictionary count]];
            for (NSString *roleName in dictionary) {
                MafiaRole *role = [MafiaRole roleWithName:roleName];
                if (role == nil) {
                    *success = NO;
                    NSString *errorDescription = [NSString stringWithFormat:@"Invalid role name %@", roleName];
                    *error = [NSError mafia_errorOfDataPersistenceWithDescription:errorDescription];
                    break;
                }
                id numberOfActors = dictionary[roleName];
                if (![numberOfActors isKindOfClass:[NSNumber class]]) {
                    *success = NO;
                    NSString *errorDescription = [NSString stringWithFormat:@"Number of actors (%@) is not a number", numberOfActors];
                    *error = [NSError mafia_errorOfDataPersistenceWithDescription:errorDescription];
                    break;
                }
                roleSettings[role] = numberOfActors;
            }
            return (*success ? roleSettings : nil);
        }
        reverseBlock:^(NSMutableDictionary *roleSettings, BOOL *success, NSError **error) {
            // Transform to a dictionary where key is role name, and value is number of actors.
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:[roleSettings count]];
            for (MafiaRole *role in roleSettings) {
                dictionary[role.name] = roleSettings[role];
            }
            return dictionary;
        }];
}


@end
