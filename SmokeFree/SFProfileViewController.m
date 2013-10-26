//
//  SFProfileViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import "SFProfileHeaderView.h"

#import "SFProfileViewController.h"

@interface SFProfileViewController ()

@end

@implementation SFProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [@"Mike" uppercaseString];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                               target:nil action:nil];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menubtn"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil action:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SFProfileHeaderView *profileView = [[UINib nibWithNibName:@"SFProfileHeaderView" bundle:nil]
                                        instantiateWithOwner:nil options:nil][0];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 240)];
    [headerView addSubview:profileView];
    self.tableView.tableHeaderView = headerView;

}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return (section == 0) ? 0 : 12;
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

@end
