#import <UIKit/UIKit.h>


@class MafiaGame;


@interface MafiaGamePlayController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) IBOutlet UIImageView *dayNightImageView;
@property (retain, nonatomic) IBOutlet UILabel *roundLabel;
@property (retain, nonatomic) IBOutlet UILabel *actionLabel;
@property (retain, nonatomic) IBOutlet UITableView *playersTableView;

@property (retain, nonatomic) MafiaGame *game;
@property (retain, nonatomic) NSMutableArray *selectedPlayers;

+ (UIViewController *)controllerForTab;

- (id)initForTab;

- (void)reloadData;

- (IBAction)resetGame:(id)sender;

- (IBAction)continueToNext:(id)sender;

@end // MafiaGamePlayController

