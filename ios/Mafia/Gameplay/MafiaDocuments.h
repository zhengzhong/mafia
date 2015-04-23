//
//  Created by ZHENG Zhong on 2015-04-20.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MafiaDocuments : NSObject

+ (NSString *)stringWithContentsOfFile:(NSString *)filename;

+ (NSData *)dataWithContentsOfFile:(NSString *)filename;

+ (NSDictionary *)dictionaryWithContentsOfFile:(NSString *)filename;

+ (UIImage *)imageWithContentsOfFile:(NSString *)filename;

+ (BOOL)saveString:(NSString *)string toFile:(NSString *)filename;

+ (BOOL)saveData:(NSData *)data toFile:(NSString *)filename;

+ (BOOL)saveDictionary:(NSDictionary *)dictionary toFile:(NSString *)filename;

+ (BOOL)saveImage:(UIImage *)image toFile:(NSString *)filename;

+ (BOOL)removeItemWithName:(NSString *)name;

/*!
 * Returns an array of NSString objects, each of which identifies a file in the given directory.
 * If any error occurs, this method returns an empty array.
 */
+ (NSArray *)filenamesOfDirectoryWithName:(NSString *)name;

@end
