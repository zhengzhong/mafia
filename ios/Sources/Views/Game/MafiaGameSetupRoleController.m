//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGameSetupRoleController.h"

#import "../../Gameplay/MafiaGameplay.h"


@implementation MafiaGameSetupRoleController


@synthesize role = _role;
@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;
@synthesize value = _value;
@synthesize delegate = _delegate;


+ (id)controllerWithRole:(MafiaRole *)role
                minValue:(NSInteger)minValue
                maxValue:(NSInteger)maxValue
                   value:(NSInteger)value
                delegate:(id<MafiaGameSetupRoleControllerDelegate>)delegate
{
    return [[[self alloc] initWithRole:role
                              minValue:minValue
                              maxValue:maxValue
                                 value:value
                              delegate:delegate] autorelease];
}


- (void)dealloc
{
    [_role release];
    [super dealloc];
}


- (id)initWithRole:(MafiaRole *)role
          minValue:(NSInteger)minValue
          maxValue:(NSInteger)maxValue
             value:(NSInteger)value
          delegate:(id<MafiaGameSetupRoleControllerDelegate>)delegate
{
    NSAssert(minValue <= value && value <= maxValue, @"Invalid minValue/maxValue/value.");
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        _role = [role retain];
        _minValue = minValue;
        _maxValue = maxValue;
        _value = value;
        _delegate = delegate;
        self.title = role.displayName;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    [self.navigationItem setHidesBackButton:YES animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.maxValue - self.minValue + 1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MafiaGameSetupRoleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"role_%@.png", self.role.name]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ x %d", self.role.displayName, (self.minValue + indexPath.row)];
    if (indexPath.row == self.value - self.minValue)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:(self.value - self.minValue) inSection:0];
    if (![previousIndexPath isEqual:indexPath])
    {
        self.value = self.minValue + indexPath.row;
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *previousCell = [tableView cellForRowAtIndexPath:previousIndexPath];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Actions


- (void)doneTapped:(id)sender
{
    [self.delegate roleController:self didSelectValue:self.value forRole:self.role];
}


@end // MafiaGameSetupRoleController

