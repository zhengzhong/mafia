//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaPlayerList.h"
#import "MafiaPerson.h"
#import "MafiaPlayer.h"
#import "MafiaRole.h"


@implementation MafiaPlayerList


- (id)initWithPersons:(NSArray *)persons isTwoHanded:(BOOL)isTwoHanded {
    if (self = [super init]) {
        NSMutableArray *players = [NSMutableArray arrayWithCapacity:[persons count] * 2];
        for (MafiaPerson *person in persons) {
            if (isTwoHanded) {
                [players addObject:[MafiaPlayer playerWithPerson:person handSide:MafiaHandSideLeft]];
                [players addObject:[MafiaPlayer playerWithPerson:person handSide:MafiaHandSideRight]];
            } else {
                [players addObject:[MafiaPlayer playerWithPerson:person handSide:MafiaHandSideBoth]];
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


- (MafiaPlayer *)playerWithName:(NSString *)name handSide:(MafiaHandSide)handSide {
    for (MafiaPlayer *player in self.players) {
        if ([player.person.name isEqualToString:name] && player.handSide == handSide) {
            return player;
        }
    }
    return nil;
}


- (MafiaPlayer *)twinOfPlayer:(MafiaPlayer *)player {
    for (MafiaPlayer *otherPlayer in self.players) {
        if ([otherPlayer.person isEqualToPerson:player.person] && otherPlayer.handSide != player.handSide) {
            return otherPlayer;
        }
    }
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
