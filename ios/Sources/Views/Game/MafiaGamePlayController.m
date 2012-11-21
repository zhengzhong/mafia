#import "MafiaGamePlayController.h"
#import "MafiaGamePlayerTableViewCell.h"

#import "../../Gameplay/MafiaGameplay.h"


@interface MafiaGamePlayController ()

@end


@implementation MafiaGamePlayController


@synthesize dayNightImageView = _dayNightImageView;
@synthesize roundLabel = _roundLabel;
@synthesize actionLabel = _actionLabel;
@synthesize playersTableView = _playersTableView;

@synthesize game = _game;
@synthesize selectedPlayers = _selectedPlayers;


+ (UIViewController *)controllerForTab
{
    return [[[self alloc] initForTab] autorelease];
}


- (void)dealloc
{
    [_dayNightImageView release];
    [_roundLabel release];
    [_actionLabel release];
    [_playersTableView release];
    [_game release];
    [_selectedPlayers release];
    [super dealloc];
}


- (id)initForTab
{
    if (self = [self initWithNibName:@"MafiaGamePlayController" bundle:nil])
    {
        self.title = @"Game";
        self.tabBarItem.image = [UIImage imageNamed:@"GameIcon.png"]; // TODO:
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        NSArray *playerNames = [NSArray arrayWithObjects:
                                @"雯雯", @"狼尼", @"小何", @"大叔", @"青青", @"老妖", nil];
        _game = [[MafiaGame alloc] initWithPlayerNames:playerNames isTwoHanded:YES];
        _selectedPlayers = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // TODO: Can't this be done in XIB?
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"game_background.png"]];
    [self.game reset];
    [self reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Public methods


- (void)reloadData
{
    MafiaAction *currentAction = [self.game currentAction];
    MafiaRole *currentRole = [currentAction role];
    if (currentRole != nil)
    {
        self.dayNightImageView.image = [UIImage imageNamed:@"action_in_night.png"];
    }
    else
    {
        self.dayNightImageView.image = [UIImage imageNamed:@"action_in_day.png"];
    }
    if (self.game.winner)
    {
        self.roundLabel.text = @"Game Over";
        self.actionLabel.text = [NSString stringWithFormat:@"%@ Wins!", self.game.winner];
    }
    else
    {
        self.roundLabel.text = [NSString stringWithFormat:@"Round %d", self.game.round];
        if (currentAction.isAssigned)
        {
            self.actionLabel.text = [NSString stringWithFormat:@"%@:", currentAction];
        }
        else
        {
            self.actionLabel.text = [NSString stringWithFormat:@"Assign %@:", currentRole];
        }
    }
    [self.playersTableView reloadData];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.game.playerList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MafiaGamePlayerTableViewCell";
    MafiaGamePlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"MafiaGamePlayerTableViewCell" owner:self options:nil];
        cell = [nibObjects objectAtIndex:0];
    }
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    [cell refreshWithPlayer:player];
    UIColor *backgroundColor = nil;
    if ([self.selectedPlayers containsObject:player])
    {
        backgroundColor = [UIColor colorWithRed:0.87 green:0.94 blue:0.84 alpha:1.0];
    }
    else if (player.isDead)
    {
        backgroundColor = [UIColor colorWithRed:0.95 green:0.87 blue:0.87 alpha:1.0];
    }
    else if (indexPath.row % 2 == 0)
    {
        backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    }
    else
    {
        backgroundColor = [UIColor whiteColor];
    }
    cell.contentView.backgroundColor = backgroundColor;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.game.winner != nil)
    {
        return nil; // Game over...
    }
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    MafiaAction *currentAction = [self.game currentAction];
    if (!currentAction.isAssigned)
    {
        return ([player isUnrevealed] ? indexPath : nil);
    }
    else
    {
        return ([currentAction isPlayerSelectable:player] ? indexPath : nil);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MafiaAction *currentAction = [self.game currentAction];
    NSInteger numberOfChoices = [self numberOfChoicesForActon:currentAction];
    MafiaPlayer *selectedPlayer = [self.game.playerList playerAtIndex:indexPath.row];
    if ([self.selectedPlayers containsObject:selectedPlayer])
    {
        [self.selectedPlayers removeObject:selectedPlayer];
    }
    else
    {
        [self.selectedPlayers addObject:selectedPlayer];
    }
    while ([self.selectedPlayers count] > numberOfChoices)
    {
        [self.selectedPlayers removeObjectAtIndex:0];
    }
    [self reloadData];
}


#pragma mark - IBAction methods


- (IBAction)resetGame:(id)sender
{
    [self.game reset];
    [self reloadData];
}


- (IBAction)continueToNext:(id)sender
{
    MafiaAction *currentAction = [self.game currentAction];
    NSInteger numberOfChoices = [self numberOfChoicesForActon:currentAction];
    if ([self.selectedPlayers count] == numberOfChoices)
    {
        // Assign role to player(s) or execute the current action.
        NSArray *messages = nil;
        if (!currentAction.isAssigned)
        {
            [currentAction assignRoleToPlayers:self.selectedPlayers];
        }
        else
        {
            [currentAction beginAction];
            if ([currentAction isExecutable])
            {
                for (MafiaPlayer *player in self.selectedPlayers)
                {
                    [currentAction executeOnPlayer:player];
                }
            }
            messages = [currentAction endAction];
            [self.game continueToNextAction];
        }
        // Clear the selected players.
        [self.selectedPlayers removeAllObjects];
        // Display alert as necessary.
        if (messages != nil && [messages count] > 0)
        {
            NSString *messageString = [messages componentsJoinedByString:@"\n"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Messages"
                                                            message:messageString
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else
    {
        NSString *messageString = [NSString stringWithFormat:@"You need to select %d player(s).", numberOfChoices];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Messages"
                                                        message:messageString
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [self reloadData];
}


#pragma mark - Private methods


- (NSInteger)numberOfChoicesForActon:(MafiaAction *)action
{
    if (!action.isAssigned)
    {
        return action.numberOfActors;
    }
    else if ([action isExecutable])
    {
        return 1;
    }
    else
    {
        return 0;
    }
}


@end // MafiaGamePlayController

