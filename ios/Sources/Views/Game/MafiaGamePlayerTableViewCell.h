#import <UIKit/UIKit.h>

@class MafiaPlayer;


@interface MafiaGamePlayerTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *roleLabel;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *stateImageCollection;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *tagImageCollection;

- (void)refreshWithPlayer:(MafiaPlayer *)player;

@end // MafiaGamePlayerTableViewCell

