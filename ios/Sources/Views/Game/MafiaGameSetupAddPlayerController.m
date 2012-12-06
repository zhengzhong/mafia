//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupAddPlayerController.h"


@implementation MafiaGameSetupAddPlayerController


@synthesize playerNameField = _playerNameField;
@synthesize delegate = _delegate;


+ (id)controllerWithDelegate:(id<MafiaGameSetupAddPlayerControllerDelegate>)delegate
{
    return [[[self alloc] initWithDelegate:delegate] autorelease];
}


- (void)dealloc
{
    [_playerNameField release];
    [super dealloc];
}


- (id)initWithDelegate:(id<MafiaGameSetupAddPlayerControllerDelegate>)delegate
{
    self = [super initWithNibName:@"MafiaGameSetupAddPlayerController" bundle:nil];
    if (self = [super initWithNibName:@"MafiaGameSetupAddPlayerController" bundle:nil])
    {
        _delegate = delegate;
        self.title = @"Add Player";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    [self.navigationItem setHidesBackButton:YES animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)cancelTapped:(id)sender
{
    [self.delegate addPlayerController:self didAddPlayer:nil];
}


#pragma mark - IBAction


- (IBAction)doneTapped:(id)sender
{
    [self.delegate addPlayerController:self didAddPlayer:self.playerNameField.text];
}


- (IBAction)showContactPicker:(id)sender
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self presentModalViewController:peoplePicker animated:YES];
    [peoplePicker release];
}


- (IBAction)backgroundTapped:(id)sender
{
    [self.playerNameField resignFirstResponder];
}


#pragma mark - ABPeoplePickerNavigationControllerDelegate


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    NSString *firstName = (NSString *) ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (NSString *) ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", (firstName != nil ? firstName : @""), (lastName != nil ? lastName : @"")];
    self.playerNameField.text = [fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}


// The people picker is always dismissed when the user selects a person. Thus this method will never be called.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}


@end // MafiaGameSetupAddPlayerController

