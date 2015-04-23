//
//  Created by ZHENG Zhong on 2015-04-20.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import "MafiaDocuments.h"


@implementation MafiaDocuments


#pragma mark - Loading


+ (NSString *)stringWithContentsOfFile:(NSString *)filename {
    NSString *filepath = [self mafia_localFilepathWithName:filename];
    NSError *error = nil;
    NSString *string = [NSString stringWithContentsOfFile:filepath
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
    if (error != nil) {
        NSLog(@"Fail to load string from file %@: %@", filename, error);
        return nil;
    } else {
        return string;
    }
}


+ (NSData *)dataWithContentsOfFile:(NSString *)filename {
    NSString *filepath = [self mafia_localFilepathWithName:filename];
    NSError *error = nil;
    NSDataReadingOptions options = (NSDataReadingOptions)0;  // !!!: cast to shut up compiler warning.
    NSData *data = [NSData dataWithContentsOfFile:filepath options:options error:&error];
    if (error != nil) {
        NSLog(@"Fail to load data from file %@: %@", filename, error);
        return nil;
    } else {
        return data;
    }
}


+ (NSDictionary *)dictionaryWithContentsOfFile:(NSString *)filename {
    NSData *data = [self dataWithContentsOfFile:filename];
    if (data == nil) {
        return nil;
    }
    NSError *error = nil;
    NSJSONReadingOptions options = (NSJSONReadingOptions)0;  // !!!: cast to shut up compiler warning.
    id object = [NSJSONSerialization JSONObjectWithData:data options:options error:&error];
    if (error != nil) {
        NSLog(@"Fail to load JSON dictionary from file %@: %@", filename, error);
        return nil;
    } else if (![object isKindOfClass:[NSDictionary class]]) {
        NSLog(@"JSON object from file %@ is NOT a dictionary.", filename);
        return nil;
    } else {
        return object;
    }
}


+ (UIImage *)imageWithContentsOfFile:(NSString *)filename {
    NSData *data = [self dataWithContentsOfFile:filename];
    return (data != nil ? [UIImage imageWithData:data] : nil);
}


#pragma mark - Saving


+ (BOOL)saveString:(NSString *)string toFile:(NSString *)filename {
    NSString *filepath = [self mafia_localFilepathWithName:filename];
    BOOL success = [self mafia_prepareParentDirectoryOfFilepath:filepath];
    if (!success) {
        return NO;
    }
    NSError *error = nil;
    success = [string writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"Fail to save string to file %@: %@", filename, error);
    }
    return success;
}


+ (BOOL)saveData:(NSData *)data toFile:(NSString *)filename {
    NSString *filepath = [self mafia_localFilepathWithName:filename];
    BOOL success = [self mafia_prepareParentDirectoryOfFilepath:filepath];
    if (!success) {
        return NO;
    }
    NSError *error = nil;
    success = [data writeToFile:filepath options:NSDataWritingAtomic error:&error];
    if (error != nil) {
        NSLog(@"Fail to save data to file %@: %@", filename, error);
    }
    return success;
}


+ (BOOL)saveDictionary:(NSDictionary *)dictionary toFile:(NSString *)filename {
    NSError *error = nil;
    NSJSONWritingOptions options = (NSJSONWritingOptions)0;  // !!!: cast to shut up compiler warning.
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:options error:&error];
    if (error != nil) {
        NSLog(@"Fail to save JSON dictionary to data: %@", error);
        return NO;
    }
    return [self saveData:data toFile:filename];
}


+ (BOOL)saveImage:(UIImage *)image toFile:(NSString *)filename {
    NSData *data = UIImagePNGRepresentation(image);
    if (data == nil) {
        NSLog(@"Fail to convert image to PNG representation.");
        return NO;
    }
    return [self saveData:data toFile:filename];
}


#pragma mark - Removing


+ (BOOL)removeItemWithName:(NSString *)name {
    NSString *itempath = [self mafia_localFilepathWithName:name];
    return [[NSFileManager defaultManager] removeItemAtPath:itempath error:nil];
}


#pragma mark - Directory listing


+ (NSArray *)filenamesOfDirectoryWithName:(NSString *)name {
    NSString *dirpath = [self mafia_localFilepathWithName:name];
    NSError *error = nil;
    NSArray *entries = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirpath error:&error];
    if (error != nil) {
        NSLog(@"Fail to list contents in directory %@: %@", name, error);
        return @[];
    }
    NSPredicate *predicate = [NSPredicate predicateWithBlock:
        ^BOOL(NSString *entry, NSDictionary *bindings) {
            NSString *filepath = [dirpath stringByAppendingPathComponent:entry];
            BOOL isDirectory = NO;
            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDirectory];
            return (fileExists && !isDirectory);
        }];
    return [entries filteredArrayUsingPredicate:predicate];
}


#pragma mark - Private


+ (NSString *)mafia_localFilepathWithName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    if ([name length] > 0) {
        return [documentsDirectory stringByAppendingPathComponent:name];
    } else {
        return documentsDirectory;
    }
}


+ (BOOL)mafia_prepareParentDirectoryOfFilepath:(NSString *)filepath {
    NSString *dirpath = [filepath stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // Check if parent directory already exists.
    BOOL isDirectory = NO;
    BOOL fileExists = [fileManager fileExistsAtPath:dirpath isDirectory:&isDirectory];
    if (fileExists && isDirectory) {
        return YES;
    }
    // Create directories to the filepath.
    NSError *error = nil;
    BOOL success = [fileManager createDirectoryAtPath:dirpath
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
    if (error != nil) {
        NSLog(@"Fail to create directories to %@: %@", dirpath, error);
    }
    return success;
}


@end
