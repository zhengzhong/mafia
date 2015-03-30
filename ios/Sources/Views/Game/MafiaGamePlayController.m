//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGamePlayController.h"
#import "MafiaGamePlayerTableViewCell.h"
#import "MafiaGamePlayerController.h"
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
    return [[self alloc] initWithGameSetup:gameSetup];
}




- (id)initWithGameSetup:(MafiaGameSetup *)gameSetup
{
    if (self = [super initWithNibName:@"MafiaGamePlayController" bundle:nil])
    {
        _informationController = [[MafiaGameInformationController alloc] initWithDelegate:self];
        _game = [[MafiaGame alloc] initWithGameSetup:gameSetup];
        _selectedPlayers = [[NSMutableArray alloc] initWithCapacity:2];
        self.title = NSLocalizedString(@"Game", nil);
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
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                    target:self
                                    action:@selector(confirmResetGame:)];
    self.navigationItem.leftBarButtonItem = resetButton;
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
        self.title = NSLocalizedString(@"Game Over", nil);
        self.actionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Wins!", nil), self.game.winner];
        self.promptLabel.text = nil;
    }
    else
    {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Round %d", nil), self.game.round];
        if (currentAction.isAssigned)
        {
            self.actionLabel.text = [NSString stringWithFormat:@"%@", currentAction];
            if ([currentAction isExecutable])
            {
                MafiaNumberRange *numberOfChoices = [self numberOfChoicesForActon:currentAction];
                NSString *numberOfChoicesString = [numberOfChoices
                                                   formattedStringWithSingleForm:NSLocalizedString(@"player", nil)
                                                   pluralForm:NSLocalizedString(@"players", nil)];
                self.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Select %@", nil), numberOfChoicesString];
            }
            else if (currentRole != nil)
            {
                self.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ not available", nil), currentRole];
            }
            else
            {
                self.promptLabel.text = NSLocalizedString(@"Continue to next", nil);
            }
        }
        else
        {
            self.actionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Assign %@", nil), currentRole];
            MafiaNumberRange *numberOfChoices = [self numberOfChoicesForActon:currentAction];
            NSString *numberOfChoicesString = [numberOfChoices
                                               formattedStringWithSingleForm:NSLocalizedString(@"player", nil)
                                               pluralForm:NSLocalizedString(@"players", nil)];
            self.promptLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Select %@", nil), numberOfChoicesString];
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
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}


#pragma mark - Table view delegate


// Note: Setting backgrund color of a cell must be done in this delegate method.
// See: http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableViewCell_Class/Reference/Reference.html
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    UIColor *backgroundColor = nil;
    if ([self.selectedPlayers containsObject:player])
    {
        backgroundColor = [UIColor colorWithRed:0.87 green:0.94 blue:0.84 alpha:1.0];
    }
    else if (player.isDead)
    {
        backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    }
    else if (indexPath.row % 2 == 0)
    {
        backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    }
    else
    {
        backgroundColor = [UIColor whiteColor];
    }
    cell.backgroundColor = backgroundColor;
}


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
    MafiaNumberRange *numberOfChoices = [self numberOfChoicesForActon:currentAction];
    MafiaPlayer *selectedPlayer = [self.game.playerList playerAtIndex:indexPath.row];
    if ([self.selectedPlayers containsObject:selectedPlayer])
    {
        [self.selectedPlayers removeObject:selectedPlayer];
    }
    else
    {
        [self.selectedPlayers addObject:selectedPlayer];
    }
    while ([self.selectedPlayers count] > numberOfChoices.maxValue)
    {
        [self.selectedPlayers removeObjectAtIndex:0];
    }
    [self reloadData];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    MafiaPlayer *player = [self.game.playerList playerAtIndex:indexPath.row];
    MafiaGamePlayerController *playerController = [MafiaGamePlayerController controllerWithPlayer:player delegate:self];
    [self.navigationController pushViewController:playerController animated:YES];
}


#pragma mark - actions for navigation bar button items


- (void)confirmResetGame:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"Are you sure to reset game?", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"No. Take me back.", nil)
                                  destructiveButtonTitle:NSLocalizedString(@"Yes. Reset the game!", nil)
                                  otherButtonTitles:nil];
    // See: http://stackoverflow.com/questions/4447563/last-button-of-actionsheet-does-not-get-clicked
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)continueToNextAction:(id)sender
{
    MafiaAction *currentAction = [self.game currentAction];
    MafiaNumberRange *numberOfChoices = [self numberOfChoicesForActon:currentAction];
    if ([numberOfChoices isNumberInRange:[self.selectedPlayers count]])
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
        NSString *numberOfChoicesString = [numberOfChoices
                                           formattedStringWithSingleForm:NSLocalizedString(@"player", nil)
                                           pluralForm:NSLocalizedString(@"players", nil)];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You must select %@", nil), numberOfChoicesString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Messages", nil)
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self reloadData];
}


#pragma mark - IBAction for cell accessory button


- (IBAction)playerAccessoryButtonTapped:(id)sender
{
    // Find out the indexPath of the cell within which the accessory button is tapped.
    // To find the container cell, go through the view hierarchy until MafiaGamePlayerTableViewCell.
    UIButton *accessoryButton = (UIButton *) sender;
    UIView *superview = accessoryButton.superview;
    while (superview != nil && ![superview isKindOfClass:[MafiaGamePlayerTableViewCell class]])
    {
        superview = superview.superview;
    }
    NSAssert([superview isKindOfClass:[MafiaGamePlayerTableViewCell class]], @"Unable to find container cell for accessory button.");
    MafiaGamePlayerTableViewCell *containerCell = (MafiaGamePlayerTableViewCell *) superview;
    NSIndexPath *indexPath = [self.playersTableView indexPathForCell:containerCell];
    [self tableView:self.playersTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}


#pragma mark - UIActionSheetDelegate (Reset Game)


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - MafiaGamePlayerControllerDelegate


- (void)playerController:(MafiaGamePlayerController *)controller didCompleteWithPlayer:(MafiaPlayer *)player
{
    [self.navigationController popViewControllerAnimated:YES];
    [self reloadData];
}


#pragma mark - MafiaGameInformationDelegate


- (void)informationControllerDidComplete:(MafiaGameInformationController *)controller
{
    [self.informationController dismissInformationFromSuperview];
}


#pragma mark - Private methods


- (MafiaNumberRange *)numberOfChoicesForActon:(MafiaAction *)action
{
    if (!action.isAssigned)
    {
        return [MafiaNumberRange numberRangeWithSingleValue:action.numberOfActors];
    }
    else if ([action isExecutable])
    {
        return [action numberOfChoices];
    }
    else
    {
        return [MafiaNumberRange numberRangeWithSingleValue:0];
    }
}


@end // MafiaGamePlayController

