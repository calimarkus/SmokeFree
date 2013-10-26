//
//  SFProfileViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <MessageUI/MessageUI.h>

#import "SFProfileHeaderView.h"

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
        
        self.data = @[@(0),@(1),@(2), @(3), @(4), @(5)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                               target:self action:@selector(shareButtonTouched:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.data = [self.data arrayByAddingObject:@(self.data.count)];
    
    double delayInSeconds = 0.15;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // create / dequeue cell
    static NSString* identifier = @"identifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat: @"%d", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
