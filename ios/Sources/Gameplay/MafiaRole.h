#import <Foundation/Foundation.h>

@interface MafiaRole : NSObject

@property (readonly, copy, nonatomic) NSString *name;
@property (readonly, assign, nonatomic) NSInteger alignment;

- (id)initWithName:(NSString *)name alignment:(NSInteger)alignment;

+ (MafiaRole *)unrevealed;

+ (MafiaRole *)civilian;

+ (MafiaRole *)killer;

+ (MafiaRole *)detective;

+ (MafiaRole *)doctor;

+ (MafiaRole *)guardian;

+ (MafiaRole *)traitor;

@end // MafiaRole

