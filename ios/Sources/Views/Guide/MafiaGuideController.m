//
//  Created by ZHENG Zhong on 2012-12-05.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaGuideController.h"
#import "MafiaHTMLPage.h"
#import "MafiaHTMLPageController.h"


@implementation MafiaGuideController


@synthesize tableOfContents = _tableOfContents;


+ (UIViewController *)controllerForTab
{
    MafiaGuideController *guideController = [[self alloc] initWithTableOfContents];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:guideController];
    navigationController.title = NSLocalizedString(@"Guide", nil);
    navigationController.tabBarItem.image = [UIImage imageNamed:@"guide.png"];
    return navigationController;
}




- (id)initWithTableOfContents
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        _tableOfContents = [[NSArray alloc] initWithObjects:
                            [MafiaHTMLPage pageWithTitle:NSLocalizedString(@"Gameplay", nil) pageName:@"gameplay" language:@"zh"],
                            nil];
        self.title = NSLocalizedString(@"Guide", nil);
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
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
    return [self.tableOfContents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MafiaGuideCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    MafiaHTMLPage *htmlPage = [self.tableOfContents objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"guide.png"];
    cell.textLabel.text = htmlPage.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate


// Note: Setting backgrund color of a cell must be done in this delegate method.
// See: http://developer.apple.com/library/ios/#documentation/uikit/reference/UITableViewCell_Class/Reference/Reference.html
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *backgroundColor = nil;
    if (indexPath.row % 2 == 0)
    {
        backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    }
    else
    {
        backgroundColor = [UIColor whiteColor];
    }
    cell.backgroundColor = backgroundColor;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MafiaHTMLPage *htmlPage = [self.tableOfContents objectAtIndex:indexPath.row];
    MafiaHTMLPageController *htmlPageController = [MafiaHTMLPageController controllerWithHTMLPage:htmlPage];
    [self.navigationController pushViewController:htmlPageController animated:YES];
}


@end // MafiaGuideController

