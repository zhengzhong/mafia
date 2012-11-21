#import "MafiaRole.h"

@implementation MafiaRole


@synthesize name = _name;
@synthesize alignment = _alignment;


- (void)dealloc
{
    [_name release];
    [super dealloc];
}


- (id)initWithName:(NSString *)name alignment:(NSInteger)alignment
{
    if (self = [super init])
    {
        _name = [name copy];
        _alignment = alignment;
    }
    return self;
}


- (NSString *)description
{
    return self.name;
}


+ (MafiaRole *)unrevealed
{
    static MafiaRole *Unrevealed = nil;
    if (Unrevealed == nil)
    {
        Unrevealed = [[self alloc] initWithName:@"Unrevealed" alignment:0];
    }
    return Unrevealed;
}


+ (MafiaRole *)civilian
{
    static MafiaRole *Civilian = nil;
    if (Civilian == nil)
    {
        Civilian = [[self alloc] initWithName:@"Civilian" alignment:1];
    }
    return Civilian;
}


+ (MafiaRole *)killer
{
    static MafiaRole *Killer = nil;
    if (Killer == nil)
    {
        Killer = [[self alloc] initWithName:@"Killer" alignment:-3];
    }
    return Killer;
}


+ (MafiaRole *)detective
{
    static MafiaRole *Detective = nil;
    if (Detective == nil)
    {
        Detective = [[self alloc] initWithName:@"Detective" alignment:3];
    }
    return Detective;
}


+ (MafiaRole *)doctor
{
    static MafiaRole *Doctor = nil;
    if (Doctor == nil)
    {
        Doctor = [[self alloc] initWithName:@"Doctor" alignment:1];
    }
    return Doctor;
}


+ (MafiaRole *)guardian;
{
    static MafiaRole *Guardian = nil;
    if (Guardian == nil)
    {
        Guardian = [[self alloc] initWithName:@"Guardian" alignment:1];
    }
    return Guardian;
}


+ (MafiaRole *)traitor
{
    static MafiaRole *Traitor = nil;
    if (Traitor == nil)
    {
        Traitor = [[self alloc] initWithName:@"Traitor" alignment:-2];
    }
    return Traitor;
}


@end // MafiaRole

