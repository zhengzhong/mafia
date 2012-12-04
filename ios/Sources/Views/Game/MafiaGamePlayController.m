//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGamePlayController.h"
#import "MafiaGamePlayerTableViewCell.h"
#import "MafiaGameInformationController.h"

#import "../../Gameplay/MafiaGameplay.h"


@interface MafiaGamePlayController ()

@end


@implementation MafiaGamePlayController


@synthesize dayNightImageView = _dayNightImageView;
@synthesize actionLabel = _actionLabel;
@synthesize promptLabel = _promptLabel;
@synthesize playersTableView = _playersTableView;
@synthesize informationController = _informationController;
@synthesize game = _game;
@synthesize selectedPlayers = _selectedPlayers;


+ (UIViewController *)controllerWithGameSetup:(MafiaGameSetup *)gameSetup
{
    return [[[self alloc] initWithGameSetup:gameSetup] autorelease];
}


- (void)dealloc
{
    [_dayNightImageView release];
    [_actionLabel release];
    [_promptLabel release];
    [_playersTableView release];
    [_informationController release];
    [_game release];
    [_selectedPlayers release];
    [super dealloc];
}


- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup
{
    if (self = [super initWithNibName:@"MafiaGamePlayController" bundle:nil])
    {
        _informationController = [[MafiaGameInformationController alloc] initWithDelegate:self];
        _game = [[MafiaGame alloc] initWithGameSetup:gameSetup];
        _selectedPlayers = [[NSMutableArray alloc] initWithCapacity:2];
        self.title = @"Game";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                   target:self
                                   action:@selector(continueToNextAction:)];
    self.navigationItem.rightBarButtonItem = nextButton;
    [nextButton release];
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                    target:self
                                    action:@selector(confirmResetGame:)];
    self.navigationItem.leftBarButtonItem = resetButton;
    [resetButton release];
    [self.navigationItem setHidesBackButton:YES animated:YES];
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
        self.title = @"Game Over";
        self.actionLabel.text = [NSString stringWithFormat:@"%@ Wins!", self.game.winner];
        self.promptLabel.text = nil;
    }
    else
    {
        self.title = [NSString stringWithFormat:@"Round %d", self.game.round];
        if (currentAction.isAssigned)
        {
            self.actionLabel.text = [NSString stringWithFormat:@"%@:", currentAction];
            if ([[currentAction actors] count] == 0)
            {
                self.promptLabel.text = [NSString stringWithFormat:@"%@ not available.", [currentAction role]];
            }
            else
            {
                NSInteger numberOfChoices = [self numberOfChoicesForActon:currentAction];
                self.promptLabel.text = [NSString stringWithFormat:@"Select %d player(s).", numberOfChoices];
            }
        }
        else
        {
            self.actionLabel.text = [NSString stringWithFormat:@"Assign %@:", currentRole];
            NSInteger numberOfChoices = [self numberOfChoicesForActon:currentAction];
            self.promptLabel.text = [NSString stringWithFormat:@"Select %d player(s).", numberOfChoices];
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


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MafiaPlayer *selectedPlayer = [self.game.playerList playerAtIndex:indexPath.row];
    // TODO: push player detail controller.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Player Details"
                                                    message:[NSString stringWithFormat:@"You selected player: %@", selectedPlayer]
                                                   delegate:nil
                                          cancelButtonTitle:@"Won't happen again"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


#pragma mark - actions for navigation bar button items


- (void)confirmResetGame:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure to reset game?"
                                  delegate:self
                                  cancelButtonTitle:@"No. Take me back."
                                  destructiveButtonTitle:@"Yes. Reset the game!"
                                  otherButtonTitles:nil];
    // See: http://stackoverflow.com/questions/4447563/last-button-of-actionsheet-does-not-get-clicked
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionSheet release];
}


- (void)continueToNextAction:(id)sender
{
    MafiaAction *currentAction = [self.game currentAction];
    NSInteger numberOfChoices = [self numberOfChoicesForActon:currentAction];
    if ([self.selectedPlayers count] == numberOfChoices)
    {
        // Assign role to player(s) or execute the current action.
        MafiaInformation *information = nil;
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
            information = [currentAction endAction];
            [self.game continueToNextAction];
        }
        // Clear the selected players.
        [self.selectedPlayers removeAllObjects];
        // Display information as necessary.
        if (information != nil)
        {
            [self.informationController presentInformation:information inSuperview:self.view];
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


#pragma mark - IBAction for cell accessory button


- (IBAction)playerAccessoryButtonTapped:(id)sender
{
    UIButton *accessoryButton = (UIButton *) sender;
    UITableViewCell *cell = (UITableViewCell *) accessoryButton.superview;
    NSIndexPath *indexPath = [self.playersTableView indexPathForCell:cell];
    [self tableView:self.playersTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}


#pragma mark - UIActionSheetDelegate (Reset Game)


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex])
    {
        [self.game reset];
        [self reloadData];
    }
}


#pragma mark - MafiaGameInformationDelegate


- (void)informationControllerDidComplete:(MafiaGameInformationController *)controller
{
    [self.informationController dismissInformationFromSuperview];
}


#pragma mark - Private methods


// TODO: fix this for assassin (who can select 0 or 1 player).
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

