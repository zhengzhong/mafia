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


- (MafiaPlayer *)twinOfPlayer:(MafiaPlayer *)player {
    // FIXME: implement this!
    return nil;
}


- (NSArray *)alivePlayers {
    return [self playersWithRole:nil selectedBy:nil aliveOnly:YES];
}


- (NSArray *)playersWithRole:(MafiaRole *)role aliveOnly:(BOOL)aliveOnly {
    return [self playersWithRole:role selectedBy:nil aliveOnly:aliveOnly];
}


- (NSArray *)playersSelectedBy:(MafiaRole *)selectedByRole aliveOnly:(BOOL)aliveOnly {
    return [self playersWithRole:nil selectedBy:selectedByRole aliveOnly:aliveOnly];
}


- (NSArray *)playersWithRole:(MafiaRole *)role
                  selectedBy:(MafiaRole *)selectedByRole
                   aliveOnly:(BOOL)aliveOnly {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:
        ^BOOL(id object, NSDictionary *bindings) {
            MafiaPlayer *player = object;
            if (role != nil && ![role isEqualToRole:player.role]) {
                return NO;
            }
            if (selectedByRole != nil && ![player isSelectedByRole:selectedByRole]) {
                return NO;
            }
            if (aliveOnly && player.isDead) {
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


- (void)prepareToStart {
    for (MafiaPlayer *player in self.players) {
        [player prepareToStart];
    }
}


@end
