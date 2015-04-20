//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetup.h"
#import "MafiaDocuments.h"
#import "MafiaPerson.h"
#import "MafiaRole.h"
#import "NSError+MafiaAdditions.h"


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


#pragma mark - Saving/Loading


- (BOOL)saveWithName:(NSString *)name {
    NSString *filename = [[self class] mafia_gameSetupFilenameForName:name];
    NSError *error = nil;
    NSDictionary *dictionary = [MTLJSONAdapter JSONDictionaryFromModel:self error:&error];
    return [MafiaDocuments saveDictionary:dictionary toFile:filename];
}


- (BOOL)saveToRecent {
    return [self saveWithName:kGameSetupRecent];
}


+ (instancetype)loadWithName:(NSString *)name {
    NSString *filename = [self mafia_gameSetupFilenameForName:name];
    NSDictionary *dictionary = [MafiaDocuments dictionaryWithContentsOfFile:filename];
    NSError *error = nil;
    MafiaGameSetup *gameSetup = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:dictionary error:&error];
    if (error != nil) {
        NSLog(@"Fail to load game setup from file: %@", error);
    }
    return gameSetup;
}


+ (instancetype)loadFromRecent {
    return [self loadWithName:kGameSetupRecent];
}


+ (NSString *)mafia_gameSetupFilenameForName:(NSString *)name {
    NSMutableCharacterSet *invalidCharacters = [[NSMutableCharacterSet alloc] init];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet illegalCharacterSet]];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [invalidCharacters removeCharactersInString:@"()[]-_"];  // some allowed symbols...
    name = [[name componentsSeparatedByCharactersInSet:invalidCharacters] componentsJoinedByString:@""];
    return [NSString stringWithFormat:@"GameSetup_%@.json", name];
}


#pragma mark - MTLJSONSerializing


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"persons": @"persons",
        @"isTwoHanded": @"is_two_handed",
        @"isAutonomic": @"is_autonomic",
        @"roleSettings": @"role_settings",
    };
}


+ (NSValueTransformer *)personsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MafiaPerson class]];
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
