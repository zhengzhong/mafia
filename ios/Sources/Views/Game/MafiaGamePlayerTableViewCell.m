#import "MafiaGamePlayerTableViewCell.h"

#import "../../Gameplay/MafiaGameplay.h"


@interface MafiaGamePlayerTableViewCell ()

- (UIImage *)imageForPlayer:(MafiaPlayer *)player;

@end


@implementation MafiaGamePlayerTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)refreshWithPlayer:(MafiaPlayer *)player
{
    self.avatarImageView.image = [self imageForPlayer:player];
    self.nameLabel.text = player.name;
    self.roleLabel.text = player.role.name;
    NSInteger stateImageIndex = 0;
    if (player.isMisdiagnosed)
    {
        UIImageView *stateImageView = [self.stateImageCollection objectAtIndex:stateImageIndex];
        stateImageView.image = [UIImage imageNamed:@"is_misdiagnosed.png"];
        ++stateImageIndex;
    }
    if (player.isJustGuarded)
    {
        UIImageView *stateImageView = [self.stateImageCollection objectAtIndex:stateImageIndex];
        stateImageView.image = [UIImage imageNamed:@"is_just_guarded.png"];
        ++stateImageIndex;
    }
    if (player.isUnguardable)
    {
        UIImageView *stateImageView = [self.stateImageCollection objectAtIndex:stateImageIndex];
        stateImageView.image = [UIImage imageNamed:@"is_unguardable.png"];
        ++stateImageIndex;
    }
    if (player.isVoted)
    {
        UIImageView *stateImageView = [self.stateImageCollection objectAtIndex:stateImageIndex];
        stateImageView.image = [UIImage imageNamed:@"is_voted.png"];
        ++stateImageIndex;
    }
    for (NSInteger i = stateImageIndex; i < [self.stateImageCollection count]; ++i)
    {
        UIImageView *stateImageView = [self.stateImageCollection objectAtIndex:i];
        stateImageView.image = nil;
    }
    NSInteger tagImageIndex = 0;
    for (MafiaRole *taggedByRole in player.tags)
    {
        UIImageView *tagImageView = [self.tagImageCollection objectAtIndex:tagImageIndex];
        NSString *imageName = [NSString stringWithFormat:@"tag_%@.png", [taggedByRole.name lowercaseString]];
        tagImageView.image = [UIImage imageNamed:imageName];
        ++tagImageIndex;
    }
    for (NSInteger i = tagImageIndex; i < [self.tagImageCollection count]; ++i)
    {
        UIImageView *tagImageView = [self.tagImageCollection objectAtIndex:i];
        tagImageView.image = nil;
    }
}


- (UIImage *)imageForPlayer:(MafiaPlayer *)player
{
    NSString *imageName = nil;
    if (player.isDead)
    {
        imageName = @"role_dead.png";
    }
    else
    {
        imageName = [NSString stringWithFormat:@"role_%@.png", [player.role.name lowercaseString]];
    }
    return [UIImage imageNamed:imageName];
}


@end // MafiaGamePlayerTableViewCell

