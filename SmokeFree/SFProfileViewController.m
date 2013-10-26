//
//  SFProfileViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <MessageUI/MessageUI.h>

#import "SFProfileHeaderView.h"
#import "SFProfileCell.h"

#import "SFProfileViewController.h"

@interface SFProfileViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) SFProfileHeaderView *profileView;
@end

@implementation SFProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [@"Mike" uppercaseString];
        
        self.data = @[@(0.12),@(1.24),@(-4.23), @(2.41), @(4.21), @(7.23)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                               target:self action:@selector(shareButtonTouched:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // setup Pull To Refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTriggered:) forControlEvents:UIControlEventValueChanged];
    
    // add header view
    self.profileView = [[UINib nibWithNibName:@"SFProfileHeaderView" bundle:nil]
                        instantiateWithOwner:nil options:nil][0];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    [headerView addSubview:self.profileView];
    self.tableView.tableHeaderView = headerView;
    
    // animate header in
    self.profileView.boxOffset = 100.0;
    [UIView animateWithDuration:0.66 delay:0.1 options:0 animations:^{
        self.profileView.boxOffset = 0.0;
    } completion:nil];

    // register cell
    [self.tableView registerNib:[UINib nibWithNibName:[SFProfileCell reuseIdentifier] bundle:nil]
         forCellReuseIdentifier:[SFProfileCell reuseIdentifier]];
}

#pragma mark sharing

- (void)shareButtonTouched:(UIBarButtonItem*)sender;
{
    if (![MFMailComposeViewController canSendMail]) return;

    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setToRecipients:@[@"\"Better Caul Saul\"<nosmoke@therapy.org>"]];
    [mailController setSubject:@"Look, I really need some help…"];
    [mailController setMessageBody:@"Here are my latest SmokeFree stats.. You better have a look at it. Sorry Saul.\n\n Cheers Mike" isHTML:NO];
    mailController.mailComposeDelegate = self;
    
    NSData *someData = [[NSData alloc] init];
    [mailController addAttachmentData:someData mimeType:@"text/json" fileName:@"stats.json"];
    
    [self presentViewController:mailController animated:YES completion:nil];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIRefreshControl

- (void)refreshTriggered:(UIRefreshControl*)refreshControl;
{
    self.data = [self.data arrayByAddingObject:@((arc4random()*1000)/1000.0)];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.data.count-1 inSection:1]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    CGFloat overshoot = ABS(MAX(0, scrollView.contentOffset.y + 50));
    self.profileView.boxOffset= overshoot/5.0;
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return (section == 0) ? 0 : self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [SFProfileCell preferredHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    SFProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:[SFProfileCell reuseIdentifier]];
    cell.accessoryLabel.text = [NSString stringWithFormat: @"%.1f %%", [self.data[indexPath.row] floatValue]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*indexPath.row];
//    cell.mainLabel.text = [NSString stringWithFormat: @"<#string#>", <#param1#>];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
