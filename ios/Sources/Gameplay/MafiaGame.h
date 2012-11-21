#import <Foundation/Foundation.h>

@class MafiaAction;
@class MafiaPlayer;
@class MafiaPlayerList;


@interface MafiaGame : NSObject

@property (readonly, retain, nonatomic) MafiaPlayerList *playerList;
@property (readonly, retain, nonatomic) NSArray *actions;
@property (assign, nonatomic) NSInteger round;
@property (assign, nonatomic) NSInteger actionIndex;
@property (copy, nonatomic) NSString *winner;

- (id)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded;

- (void)reset;

- (BOOL)checkGameOver;

- (MafiaAction *)currentAction;

- (MafiaAction *)continueToNextAction;

@end // MafiaGame

