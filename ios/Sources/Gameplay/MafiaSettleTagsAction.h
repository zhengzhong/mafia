#import <Foundation/Foundation.h>

#import "MafiaAction.h"


@interface MafiaSettleTagsAction : MafiaAction

- (id)initWithPlayerList:(MafiaPlayerList *)playerList;

+ (id)actionWithPlayerList:(MafiaPlayerList *)playerList;

- (NSArray *)settleTags;

@end // MafiaSettleTagsAction

