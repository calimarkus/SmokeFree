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
@property (nonatomic, copy) NSString *latestFileName;
@property (nonatomic, strong) NSArray *latestFileData;
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
    [self parseLatestFile];
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

#pragma mark data loading

- (void)loadBoxNetJSON;
{
    // load shared folder contents
    [[BoxSDK sharedSDK].foldersManager folderItemsWithID:SFDetailsSharedBoxFolderID requestBuilder:nil success:^(BoxCollection *collection) {
        NSMutableArray *files = [NSMutableArray array];
        for (NSUInteger i = 0; i < collection.numberOfEntries; i++) {
            [files addObject:[collection modelAtIndex:i]];
        }
        
        // save files, if not existing already
        for (BoxModel *model in files) {
            [self saveFileID:model.modelID filename:model.rawResponseJSON[@"name"]];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
        NSLog(@"folder items error: %@", error);
    }];
}

- (void)saveFileID:(NSString *)fileID filename:(NSString *)filename
{
    // build path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *path = [documentRootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", fileID, filename]];
    
    // check, if it exists already
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        return;
    }
    
    // start download
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [[BoxSDK sharedSDK].filesManager downloadFileWithID:fileID outputStream:outputStream requestBuilder:nil success:^(NSString *fileID, long long expectedTotalBytes) {
        NSLog(@"downloaded file - %@", fileID);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"download error with response code: %i", response.statusCode);
    }];
}

- (void)parseLatestFile;
{
    // build path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    
    // load file list
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentRootPath error:nil];
    if (contents.count > 0) {
        [contents sortedArrayUsingSelector:@selector(compare:)];
        NSString *fileName = contents[contents.count-1];
        NSData *fileData = [NSData dataWithContentsOfFile:[documentRootPath stringByAppendingPathComponent:fileName]];
        
        if (![self.latestFileName isEqualToString:fileName]) {
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil];
            NSMutableArray *contents = [data[[data allKeys][0]] mutableCopy];
            for (NSInteger i=0; i<contents.count; i++) {
                if ([[contents[i] allKeys] count] == 0) {
                    [contents removeObjectAtIndex:i];
                    i--;
                }
            }
            
            self.latestFileName = fileName;
            self.latestFileData = contents;
        }
    }
}

#pragma mark chart

- (void)reloadChartData;
{
    // read min/max & values
    CGFloat min=CGFLOAT_MAX, max=CGFLOAT_MAX;
    for (NSDictionary *data in self.latestFileData) {
        CGFloat value = [data[@"intensity"] floatValue];
        
        if (min == CGFLOAT_MAX) min = value;
        else min = MIN(min,value);
        
        if (max == CGFLOAT_MAX) max = value;
        else max = MAX(max,value);
    }
    
    // normalize data
    NSMutableArray *normalizedData = [NSMutableArray array];
    for (NSDictionary *data in self.latestFileData) {
        CGFloat value = [data[@"intensity"] floatValue];
        NSString *time = data[@"time"];
        
        value = 1.0 - ((value-min)/(max-min));
        [normalizedData addObject:@{@"time":time,@"intensity":@(value)}];
    }
    min = 0.0;
    max = 1.0;
    
    // init linechart
    LineChartData *actualData = [LineChartData new];
    actualData.xMin = 0;
    actualData.xMax = normalizedData.count;
    actualData.title = @"Smoke Amount";
    actualData.color = (self.value < 0) ? [UIColor smokeFreeGreen] : [UIColor smokeFreeRed];
    actualData.itemCount = normalizedData.count;
    actualData.getData = ^(NSUInteger item) {
        NSDictionary *data = normalizedData[item];
        float x = item;
        float y = [data[@"intensity"] floatValue];
        NSString *xLabel = data[@"time"];
        NSString *yLabel = [NSString stringWithFormat:@"%f", y];
        return [LineChartDataItem dataItemWithX:x y:y xLabel:xLabel dataLabel:yLabel];
    };
    
    self.lineChartView.yMin = min;
    self.lineChartView.yMax = max;
    self.lineChartView.ySteps = @[[NSString stringWithFormat:@"%.02f", self.lineChartView.yMin],
                                  [NSString stringWithFormat:@"%.02f", self.lineChartView.yMax / 2],
                                  [NSString stringWithFormat:@"%.02f", self.lineChartView.yMax]];
    self.lineChartView.data = @[actualData];
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
