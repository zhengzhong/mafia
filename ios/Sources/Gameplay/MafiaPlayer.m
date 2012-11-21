#import "MafiaPlayer.h"
#import "MafiaRole.h"


@implementation MafiaPlayer


@synthesize name = _name;
@synthesize role = _role;
@synthesize isDead = _isDead;
@synthesize isMisdiagnosed = _isMisdiagnosed;
@synthesize isJustGuarded = _isJustGuarded;
@synthesize isUnguardable = _isUnguardable;
@synthesize isVoted = _isVoted;
@synthesize tags = _tags;


- (void)dealloc
{
    [_name release];
    [_role release];
    [_tags release];
    [super dealloc];
}


- (id)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        _name = [name copy];
        _role = [[MafiaRole unrevealed] retain];
        _isDead = NO;
        _isMisdiagnosed = NO;
        _isJustGuarded = NO;
        _isUnguardable = NO;
        _isVoted = NO;
        _tags = [[NSMutableArray alloc] initWithCapacity:8];
    }
    return self;
}


+ (id)playerWithName:(NSString *)name
{
    return [[[self alloc] initWithName:name] autorelease];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.role, self.name];
}


- (void)reset
{
    self.role = [MafiaRole unrevealed];
    self.isDead = NO;
    self.isMisdiagnosed = NO;
    self.isJustGuarded = NO;
    self.isUnguardable = NO;
    self.isVoted = NO;
    [self.tags removeAllObjects];
}


- (BOOL)isUnrevealed
{
    return self.role == [MafiaRole unrevealed];
}


- (void)selectByRole:(MafiaRole *)role
{
    [self.tags addObject:role];
}


- (void)unselectFromRole:(MafiaRole *)role
{
    [self.tags removeObject:role];
}


- (BOOL)isSelectedByRole:(MafiaRole *)role
{
    return [self.tags containsObject:role];
}


- (void)lynch
{
    if (!self.isJustGuarded)
    {
        [self markDead];
    }
}


- (void)markDead
{
    self.isDead = YES;
    [self.tags removeAllObjects];
}


@end // MafiaPlayer

