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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UINib nibWithNibName:@"SFProfileHeaderView" bundle:nil] instantiateWithOwner:nil options:nil][0];
}

@end
