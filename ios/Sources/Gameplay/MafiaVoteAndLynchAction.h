#import <Foundation/Foundation.h>

#import "MafiaAction.h"


@interface MafiaVoteAndLynchAction : MafiaAction

- (id)initWithPlayerList:(MafiaPlayerList *)playerList;

+ (id)actionWithPlayerList:(MafiaPlayerList *)playerList;

- (NSArray *)settleVoteAndLynch;

@end // MafiaVoteAndLynchAction

