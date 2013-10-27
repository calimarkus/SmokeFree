//
//  SFFileManager.h
//  SmokeFree
//
//  Created by Markus on 27.10.13.
//
//

#import <Foundation/Foundation.h>

@interface SFFileManager : NSObject

+ (instancetype)sharedInstance;

- (void)loadBoxNetContents;

- (NSArray*)existingFiles;
- (NSArray*)fileContentsOfFileNamed:(NSString*)filename;

@end
