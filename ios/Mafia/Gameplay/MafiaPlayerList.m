//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaPlayerList.h"
#import "MafiaPlayer.h"
#import "MafiaRole.h"


@implementation MafiaPlayerList


- (id)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded {
    if (self = [super init]) {
        NSMutableArray *players = [NSMutableArray arrayWithCapacity:[playerNames count] * 2];
        for (NSString *playerName in playerNames) {
            if (isTwoHanded) {
                [players addObject:[MafiaPlayer playerWithName:[NSString stringWithFormat:@"%@:L", playerName]]];
                [players addObject:[MafiaPlayer playerWithName:[NSString stringWithFormat:@"%@:R", playerName]]];
            } else {
                [players addObject:[MafiaPlayer playerWithName:playerName]];
            }
        }
        _players = [players copy];
    }
    return self;
}


#pragma mark - NSFastEnumeration


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])stackbuf
                                    count:(NSUInteger)len {
    return [self.players countByEnumeratingWithState:state objects:stackbuf count:len];
}


#pragma mark - Public


- (NSUInteger)count {
    return [self.players count];
}


- (MafiaPlayer *)playerAtIndex:(NSUInteger)index {
    return self.players[index];
}


- (MafiaPlayer *)playerNamed:(NSString *)name {
    for (MafiaPlayer *player in self.players) {
        if ([player.name isEqualToString:name]) {
            return player;
        }
    }
    return nil;
}


- (NSArray *)alivePlayers {
    return [self alivePlayersWithRole:nil selectedBy:nil];
}


- (NSArray *)alivePlayersWithRole:(MafiaRole *)role {
    return [self alivePlayersWithRole:role selectedBy:nil];
}


- (NSArray *)alivePlayersSelectedBy:(MafiaRole *)selectorRole {
    return [self alivePlayersWithRole:nil selectedBy:selectorRole];
}


- (NSArray *)alivePlayersWithRole:(MafiaRole *)role selectedBy:(MafiaRole *)selectorRole {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:
        ^BOOL(id object, NSDictionary *bindings) {
            MafiaPlayer *player = object;
            if (player.isDead) {
                return NO;
            }
            if (role != nil && ![role isEqualToRole:player.role]) {
                return NO;
            }
            if (selectorRole != nil && ![player isSelectedByRole:selectorRole]) {
                return NO;
            }
            return YES;
        }];
    return [self.players filteredArrayUsingPredicate:predicate];
}


- (void)reset {
    for (MafiaPlayer *player in self.players) {
        [player reset];
    }
}


@end  // MafiaPlayerList
