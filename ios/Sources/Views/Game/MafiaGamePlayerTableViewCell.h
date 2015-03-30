//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaPlayer;


@interface MafiaGamePlayerTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *roleLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stateImageCollection;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *tagImageCollection;

- (void)refreshWithPlayer:(MafiaPlayer *)player;

@end // MafiaGamePlayerTableViewCell

