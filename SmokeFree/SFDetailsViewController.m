//
//  SFDetailsViewController.m
//  SmokeFree
//
//  Created by Markus on 26.10.13.
//
//

#import <BoxSDK/BoxSDK.h>
#import <ios-linechart/LineChartView.h>
#import <MessageUI/MessageUI.h>

#import "SFDetailsViewController.h"

static NSString *const SFDetailsSharedBoxFolderID = @"1262497306";

@interface SFDetailsViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation SFDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // seutp view
    self.view.backgroundColor = [UIColor whiteColor];
    self.bgImage.image = [[UIImage imageNamed:@"bg_details"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setDidReachTarget:(self.value < 0)];

    // add share button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self action:@selector(shareButtonTouched:)];
    
    // animate in
    self.topView.frameBottom = 0;
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation
                                  duration:0.6];
    
    // replace line chart view (so correct initalizer is used)
    [self.lineChartView removeFromSuperview];
    self.lineChartView = [[LineChartView alloc] initWithFrame:self.lineChartView.frame];
    self.lineChartView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.lineChartView belowSubview:self.topView];
    
    // update data
    [self loadBoxNetJSON];
    [self reloadChartData];
}

- (void)setDidReachTarget:(BOOL)didReachTarget;
{
    CGPoint imageCenter = self.imageView.center;
    
    if (didReachTarget) {
        self.bgImage.tintColor = [UIColor smokeFreeGreen];
        self.titleLabel.text = @"That's how we roll!";
        self.subTitleLabel.text = @"You reached your goal today!";
        self.imageView.image = [UIImage imageNamed:@"details_positive"];
    } else {
        self.bgImage.tintColor = [UIColor smokeFreeRed];
        self.titleLabel.text = @"Come on!";
        if (self.value < 1.0) {
            self.subTitleLabel.text = @"So close… tomorrow you can do it!";
            self.imageView.image = [UIImage imageNamed:@"details_neutral"];
        } else {
            self.subTitleLabel.text = @"You can do better! You wanted this, no?";
            self.imageView.image = [UIImage imageNamed:@"details_negative"];
        }
    }
    
    [self.imageView sizeToFit];
    self.imageView.center = imageCenter;
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

#pragma mark chart

- (void)loadBoxNetJSON;
{
    [[BoxSDK sharedSDK].foldersManager folderItemsWithID:SFDetailsSharedBoxFolderID requestBuilder:nil success:^(BoxCollection *collection) {
        NSMutableArray *files = [NSMutableArray array];
        for (NSUInteger i = 0; i < collection.numberOfEntries; i++) {
            [files addObject:[collection modelAtIndex:i]];
        }
        
        for (BoxModel *model in files) {
            NSLog(@"%@, %@, %@", model.type, model.modelID, model.rawResponseJSON[@"name"]);
            [self saveFileID:model.modelID filename:model.rawResponseJSON[@"name"]];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
        NSLog(@"folder items error: %@", error);
    }];
}

- (void)saveFileID:(NSString *)fileID filename:(NSString *)filename
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *path = [documentRootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", fileID, filename]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        NSLog(@"File existing.");
        return;
    }
    
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [[BoxSDK sharedSDK].filesManager downloadFileWithID:fileID outputStream:outputStream requestBuilder:nil success:^(NSString *fileID, long long expectedTotalBytes) {
        NSLog(@"downloaded file - %@", fileID);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"download error with response code: %i", response.statusCode);
    }];
}

- (void)reloadChartData;
{
    LineChartData *actualData = [LineChartData new];
    actualData.xMin = 1;
    actualData.xMax = 31;
    actualData.title = @"Smoke Amount";
    actualData.color = (self.value < 0) ? [UIColor smokeFreeGreen] : [UIColor smokeFreeRed];
    actualData.itemCount = 10;
    
    NSMutableArray *actualValues = [NSMutableArray new];
    for(NSUInteger i = 0; i < actualData.itemCount; ++i) {
        [actualValues addObject:@((rand() / (float)RAND_MAX) * (31 - 1) + 1)];
    }
    [actualValues sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    actualData.getData = ^(NSUInteger item) {
        float x = [actualValues[item] floatValue];
        float y = powf(2, x / 7);
        NSString *label1 = [NSString stringWithFormat:@"%lu", (unsigned long)item];
        NSString *label2 = [NSString stringWithFormat:@"%f", y];
        return [LineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
    };
    
    LineChartData *goalData = [LineChartData new];
    goalData.xMin = 1;
    goalData.xMax = 31;
    goalData.title = @"Goal";
    goalData.color = [UIColor colorWithWhite:0.66 alpha:1.0];
    goalData.itemCount = 10;
    
    NSMutableArray *goalValues = [NSMutableArray new];
    for(NSUInteger i = 0; i < goalData.itemCount; ++i) {
        [goalValues addObject:@((rand() / (float)RAND_MAX) * (31 - 1) + 1)];
    }
    [goalValues sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    goalData.getData = ^(NSUInteger item) {
        float x = [goalValues[item] floatValue];
        float y = powf(2, x / 7);
        NSString *label1 = [NSString stringWithFormat:@"%lu", (unsigned long)item];
        NSString *label2 = [NSString stringWithFormat:@"%f", y];
        return [LineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
    };
    
    self.lineChartView.yMin = 0;
    self.lineChartView.yMax = powf(2, 31 / 7) + 0.5;
    self.lineChartView.ySteps = @[@"0.0",
                         [NSString stringWithFormat:@"%.02f", self.lineChartView.yMax / 2],
                         [NSString stringWithFormat:@"%.02f", self.lineChartView.yMax]];
    self.lineChartView.data = @[actualData, goalData];
}

#pragma mark UIViewController

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [UIView animateWithDuration:duration animations:^{
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            self.topView.frameBottom = 70.0;
            CGRect frame = self.view.bounds;
            frame.origin.y = 64;
            frame.size.height -= 64;
            self.lineChartView.frame = frame;
        } else {
            self.topView.frameY = 0;
            self.lineChartView.frame = CGRectMake(0, self.topView.frameHeight,
                                                  self.view.frameWidth, self.view.frameHeight-self.topView.frameHeight);
        }
    }];
}

@end
