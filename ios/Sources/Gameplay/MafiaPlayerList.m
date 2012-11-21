#import "MafiaPlayerList.h"
#import "MafiaPlayer.h"
#import "MafiaRole.h"


@implementation MafiaPlayerList


@synthesize players = _players;


- (void)dealloc
{
    [_players release];
    [super dealloc];
}


- (id)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded
{
    if (self = [super init])
    {
        NSMutableArray *players = [[NSMutableArray alloc] initWithCapacity:[playerNames count] * 2];
        for (NSString *playerName in playerNames)
        {
            if (isTwoHanded)
            {
                [players addObject:[MafiaPlayer playerWithName:[NSString stringWithFormat:@"%@:L", playerName]]];
                [players addObject:[MafiaPlayer playerWithName:[NSString stringWithFormat:@"%@:R", playerName]]];
            }
            else
            {
                [players addObject:[MafiaPlayer playerWithName:playerName]];
            }
        }
        _players = [players copy];
        [players release];
    }
    return self;
}


#pragma mark - NSFastEnumeration method


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [self.players countByEnumeratingWithState:state objects:stackbuf count:len];
}


- (NSUInteger)count
{
    return [self.players count];
}


- (MafiaPlayer *)playerAtIndex:(NSUInteger)index
{
    return [self.players objectAtIndex:index];
}


- (MafiaPlayer *)playerNamed:(NSString *)name
{
    for (MafiaPlayer *player in self.players)
    {
        if ([player.name isEqualToString:name])
        {
            return player;
        }
    }
    return nil;
}


- (NSArray *)alivePlayers
{
    return [self alivePlayersWithRole:nil selectedBy:nil];
}


- (NSArray *)alivePlayersWithRole:(MafiaRole *)role
{
    return [self alivePlayersWithRole:role selectedBy:nil];
}


- (NSArray *)alivePlayersSelectedBy:(MafiaRole *)selectedBy
{
    return [self alivePlayersWithRole:nil selectedBy:selectedBy];
}


- (NSArray *)alivePlayersWithRole:(MafiaRole *)role selectedBy:(MafiaRole *)selectedBy
{
    NSPredicate *playerIsAlive = [NSPredicate predicateWithFormat:@"isDead == NO"];
    NSArray *filteredPlayers = [self.players filteredArrayUsingPredicate:playerIsAlive];
    if (role != nil)
    {
        NSPredicate *playerIsRole = [NSPredicate predicateWithFormat:@"role.name == %@", role.name];
        filteredPlayers = [filteredPlayers filteredArrayUsingPredicate:playerIsRole];
    }
    if (selectedBy != nil)
    {
        NSPredicate *playerIsSelected = [NSPredicate predicateWithBlock:^BOOL(id player, NSDictionary *bindings) {
            return [player isSelectedByRole:selectedBy];
        }];
        filteredPlayers = [filteredPlayers filteredArrayUsingPredicate:playerIsSelected];
    }
    return filteredPlayers;
}


- (void)reset
{
    for (MafiaPlayer *player in self.players)
    {
        [player reset];
    }
}


@end // MafiaPlayerList

