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

- (void)loadBoxNetContents;
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
        NSLog(@"download error with response code: %li", (long)response.statusCode);
    }];
}

#pragma mark data access

- (NSArray*)existingFiles;
{
    // build path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    
    // load file list
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentRootPath error:nil];
    return contents;
}

- (NSArray*)fileContentsOfFileNamed:(NSString*)fileName;
{
    // build path
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSData *fileData = [NSData dataWithContentsOfFile:[documentRootPath stringByAppendingPathComponent:fileName]];
    
    // remove empty data sets
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:nil];
    NSMutableArray *cleanedDataSet = [data[[data allKeys][0]] mutableCopy];
    for (NSInteger i=0; i<cleanedDataSet.count; i++) {
        if ([[cleanedDataSet[i] allKeys] count] != 2) {
            [cleanedDataSet removeObjectAtIndex:i];
            i--;
        }
    }
    
    return cleanedDataSet;
}

@end
