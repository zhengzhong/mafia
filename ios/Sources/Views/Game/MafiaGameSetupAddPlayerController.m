//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupAddPlayerController.h"


@implementation MafiaGameSetupAddPlayerController


@synthesize playerNameLabel = _playerNameLabel;
@synthesize playerNameField = _playerNameField;
@synthesize delegate = _delegate;


+ (id)controllerWithDelegate:(id<MafiaGameSetupAddPlayerControllerDelegate>)delegate
{
    return [[self alloc] initWithDelegate:delegate];
}




- (id)initWithDelegate:(id<MafiaGameSetupAddPlayerControllerDelegate>)delegate
{
    if (self = [super initWithNibName:@"MafiaGameSetupAddPlayerController" bundle:nil])
    {
        _delegate = delegate;
        self.title = NSLocalizedString(@"Add New Player", nil);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.playerNameLabel.text = NSLocalizedString(@"Name", nil);
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
    NSString *firstName = (NSString *) CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = (NSString *) CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
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

