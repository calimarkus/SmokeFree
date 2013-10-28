//
//  SFFileManager.m
//  SmokeFree
//
//  Created by Markus on 27.10.13.
//
//

#import <BoxSDK/BoxSDK.h>

#import "SFFileManager.h"

static NSString *const SFDetailsSharedBoxFolderID = @"1262497306";

@implementation SFFileManager

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark data loading

- (void)loadBoxNetContentsWithProgress:(void(^)(NSString *filename))progress
                            completion:(void (^)())completion;
{
    // load shared folder contents
    [[BoxSDK sharedSDK].foldersManager folderItemsWithID:SFDetailsSharedBoxFolderID requestBuilder:nil success:^(BoxCollection *collection) {
        NSMutableArray *files = [NSMutableArray array];
        for (NSUInteger i = 0; i < collection.numberOfEntries; i++) {
            [files addObject:[collection modelAtIndex:i]];
        }
        
        // save files, if not existing already
        __block NSInteger openDownloads = files.count;
        for (BoxModel *model in files) {
            NSString *filename = model.rawResponseJSON[@"name"];
            [self saveFileID:model.modelID
                    filename:filename
                    completion:^{
                        openDownloads--;
                        
                        // call progress
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (progress) {
                                progress(filename);
                            }
                        });
                        
                        // call completion
                        if (openDownloads <= 0 && completion) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion();
                            });
                        }
                    }];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSDictionary *JSONDictionary) {
        NSLog(@"folder items error: %@", error);
    }];
}

- (void)saveFileID:(NSString *)fileID filename:(NSString *)filename
        completion:(void(^)())completion;
{
    // build path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *path = [documentRootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", filename]];
    
    // check, if it exists already
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        if (completion) {
            completion();
        }
        return;
    }
    
    // start download
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    [[BoxSDK sharedSDK].filesManager downloadFileWithID:fileID outputStream:outputStream requestBuilder:nil success:^(NSString *fileID, long long expectedTotalBytes) {
        NSLog(@"downloaded file - %@", fileID);
        if (completion) {
            completion();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"download error with response code: %li", (long)response.statusCode);
        if (completion) {
            completion();
        }
    }];
}

#pragma mark data access

- (NSArray*)existingFiles;
{
    // build path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    
    // load files
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentRootPath error:nil];
    NSMutableArray *sfFiles = [NSMutableArray array];
    for (NSString *filename in [directoryContents reverseObjectEnumerator]) {
        SFFile *file = [[SFFile alloc] init];
        file.fileName = filename;
        [sfFiles addObject:file];
    }
    
    return sfFiles;
}

- (NSArray*)fileContentsOfFileNamed:(NSString*)fileName;
{
    // build path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSData *fileData = [NSData dataWithContentsOfFile:[documentRootPath stringByAppendingPathComponent:fileName]];
    
    // remove empty data sets
    NSError *error;
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];
    if (!data || error) {
        NSLog(@"JSON ERROR: %@", [error localizedDescription]);
        return nil;
    }
    
    // remove invalid datasets
    NSMutableArray *cleanedDataSet = [data[[data allKeys][0]] mutableCopy];
    for (NSInteger i=0; i<cleanedDataSet.count; i++) {
        if ([[cleanedDataSet[i] allKeys] count] != 2 ||
            [cleanedDataSet[i][@"intensity"] floatValue] == 0) {
            [cleanedDataSet removeObjectAtIndex:i];
            i--;
        }
    }
    
    return cleanedDataSet;
}

@end


@implementation SFFile

- (id)init
{
    self = [super init];
    if (self) {
        self.value = (arc4random()%1000)/100.0-5.0; // random value between -5% to +5%
    }
    return self;
}

- (NSString *)formattedName;
{
    NSString *cleanedName = [self.fileName stringByReplacingOccurrencesOfString:@".txt" withString:@""];
    NSDate *date = [[SFFile parsingDateFormatter] dateFromString:cleanedName];
    if (!date) return cleanedName;
    
    return [[SFFile outputDateFormatter] stringFromDate:date];
}

+ (NSDateFormatter*)parsingDateFormatter;
{
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyMMdd_HHmm"; // 131026_2200
    });
    
    return _dateFormatter;
}

+ (NSDateFormatter*)outputDateFormatter;
{
    static NSDateFormatter *_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterShortStyle;
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
    });
    
    return _dateFormatter;
}

@end


