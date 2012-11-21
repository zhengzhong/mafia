#import <Foundation/Foundation.h>

@class MafiaRole;
@class MafiaPlayer;


@interface MafiaPlayerList : NSObject <NSFastEnumeration>

@property (readonly, copy, nonatomic) NSArray *players;

- (id)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded;

- (NSUInteger)count;

- (MafiaPlayer *)playerAtIndex:(NSUInteger)index;

- (MafiaPlayer *)playerNamed:(NSString *)name;

- (NSArray *)alivePlayers;

- (NSArray *)alivePlayersWithRole:(MafiaRole *)role;

- (NSArray *)alivePlayersSelectedBy:(MafiaRole *)selectedBy;

- (NSArray *)alivePlayersWithRole:(MafiaRole *)role selectedBy:(MafiaRole *)selectedBy;

- (void)reset;

@end // MafiaPlayerList

