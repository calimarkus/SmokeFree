//
//  SFProfileViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <MessageUI/MessageUI.h>

#import "SFDetailsViewController.h"
#import "SFProfileHeaderView.h"
#import "SFProfileCell.h"
#import "SFFileManager.h"

#import "SFProfileViewController.h"

@interface SFProfileViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, strong) SFProfileHeaderView *profileView;
@end

@implementation SFProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [@"Mike" uppercaseString];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                               target:self action:@selector(shareButtonTouched:)];
        
        [self reloadData];
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
    __weak typeof(self) blockSelf = self;
    [[SFFileManager sharedInstance] loadBoxNetContentsWithProgress:^(NSString *filename) {
        [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"Received file: %@", filename]];
    } completion:^{
        [JDStatusBarNotification showWithStatus:@"Finished downloading files"
                                   dismissAfter:1.0];
        
        [refreshControl endRefreshing];
        [blockSelf reloadData];
        [self.tableView reloadData];
    }];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    // update box offset for profile view
    CGFloat overshoot = ABS(MAX(0, scrollView.contentOffset.y + 50));
    self.profileView.boxOffset= overshoot/5.0;

    // fade out cells at the bottom
    NSArray *visibleCells = [self.tableView visibleCells];
    CGFloat fadeOutPosition = [UIScreen mainScreen].bounds.size.height - 100;
    for (UITableViewCell *cell in visibleCells) {
        CGFloat relativePosition = cell.centerY - scrollView.contentOffset.y;
        if (relativePosition > fadeOutPosition) {
            CGFloat relativeDistance = (1.0 - MIN([UIScreen mainScreen].bounds.size.height, (relativePosition - fadeOutPosition))/100.0);
            cell.alpha = relativeDistance;
        } else {
            cell.alpha = 1.0;
        }
    }
}

#pragma mark data

- (void)reloadData;
{
    self.files = [[SFFileManager sharedInstance] existingFiles];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return (section == 0) ? 0 : self.files.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [SFProfileCell preferredHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    SFProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:[SFProfileCell reuseIdentifier]];
    
    SFFile *file = self.files[indexPath.row];
    
    // update percentage
    cell.accessoryLabel.text = [NSString stringWithFormat: @"%.1f %%", file.value];
    cell.accessoryLabel.textColor = (file.value < 0) ? [UIColor smokeFreeGreen] : [UIColor smokeFreeRed];
    
    // update day label
    cell.mainLabel.text = file.formattedName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SFProfileCell *cell = (SFProfileCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    SFDetailsViewController* viewController = [[SFDetailsViewController alloc] init];
    viewController.title = cell.mainLabel.text;
    viewController.file = self.files[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
