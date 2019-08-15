//
//  DebugLogger.m
//  motorize
//
//  Created by Phineas.Huang on 2019/7/1.
//  Copyright © 2019 SunXiaoShan. All rights reserved.
//

#import "DebugLogger.h"

#import <UIKit/UIKit.h>
#import <SSZipArchive/SSZipArchive.h>

#define ZIP_FILE_SUFFIX @"LOG.zip"

#define TIME_FORMAT @"yyyy-MM-dd HH_mm_ss"

#define LOG_EXTENSION @"log"

@interface DebugLogger()

@end

@implementation DebugLogger

#pragma mark - Setup initial settings

+ (instancetype)sharedInstance {
    static DebugLogger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DebugLogger alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self handleExpiredLogFile];
        [self setupDDLog];
    }
    return self;
}

- (void)setupDDLog {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIME_FORMAT];
    NSDate *date = [[NSDate alloc] init];
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", [dateFormatter stringFromDate:date], LOG_EXTENSION]; // file name format: yyyy-MM-dd.log
    NSString *logPath = [[self getLogFileDocumentDirectory] stringByAppendingPathComponent:fileName];
    freopen([logPath fileSystemRepresentation],"a+",stderr);
    freopen([logPath fileSystemRepresentation],"a+",stdout);
}

#pragma mark - Expired log file

- (void)handleExpiredLogFile {
    [self deleteExpiredLogFile];
}

- (void)deleteExpiredLogFile {
    NSArray *list = [self getExpiredLogFiles];
    for (NSString *filename in list) {
        NSString *folderPath = [self getLogFileDocumentDirectory];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", folderPath, filename];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
}

- (NSArray *)getExpiredLogFiles {
    NSArray* dirs = [[NSFileManager defaultManager]
                     contentsOfDirectoryAtPath:[self getLogFileDocumentDirectory]
                     error:NULL];
    NSMutableArray *logFiles = [[NSMutableArray alloc] init];
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:LOG_EXTENSION] == NO) {
            return;
        }

        NSString *name = [filename stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", LOG_EXTENSION]
                                                       withString:@""];
        if ([self isExpiredLogFile:name] == NO) {
            return;
        }

        [logFiles addObject:filename];
    }];

    return [logFiles copy];
}

- (BOOL)isExpiredLogFile:(NSString *)filename {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIME_FORMAT];
    NSDate *date = [dateFormatter dateFromString:filename];

    NSTimeInterval expiredDay = 7 * 24 * 60 * 60;
    return ([[NSDate date] timeIntervalSince1970] - [date timeIntervalSince1970] >= expiredDay );
}

#pragma mark - Export log file

- (void)exportLogFile {
    [self removeLastZipFiles];

    if ([self zipLogFile]) {
        [self shareZipFileViaAirdrop];
    }
}

#pragma mark - path function

- (NSString *)getDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentFolderPath = [paths firstObject];
    return documentFolderPath;
}

- (NSString *)getZipFileDocumentDirectory {
    return [self getDocumentDirectory];
}

- (NSString *)getIosZipFilePath {
    return [[self getZipFileDocumentDirectory] stringByAppendingPathComponent:@"/iOS_LOG.zip"];
}

- (NSString *)getZipFilePath {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:TIME_FORMAT];
    NSDate *date = [[NSDate alloc] init];
    NSString *fileName = [NSString stringWithFormat:@"/%@_%@", [dateFormatter stringFromDate:date], ZIP_FILE_SUFFIX];

    return [[self getZipFileDocumentDirectory] stringByAppendingPathComponent:fileName];
}

- (NSString *)getLogFileDocumentDirectory {
    NSString *path = [self getZipFileDocumentDirectory];
    NSString *documentsDirectory = [path stringByAppendingPathComponent:@"/LOG/"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return documentsDirectory;
}

#pragma mark - uiview function

- (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }

    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }

    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

#pragma mark - zip function

- (BOOL)zipLogFile {
    BOOL result = [SSZipArchive createZipFileAtPath:[self getZipFilePath]
                             withContentsOfDirectory:[self getLogFileDocumentDirectory]
                                 keepParentDirectory:NO
                                    compressionLevel:-1
                                            password:nil
                                                 AES:YES
                                     progressHandler:nil];

    return result;
}

#pragma mark - airdrop share function

- (void)shareZipFileViaAirdrop {
    NSURL *url = [NSURL fileURLWithPath:[self getZipFilePath]];
    NSArray *objectsToShare = @[url];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    // Exclude all activities except AirDrop.
    NSArray *excludedActivities = @[
                                    UIActivityTypePostToTwitter,
                                    UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage,
                                    UIActivityTypeMail,
                                    UIActivityTypePrint,
                                    UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact,
                                    UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo,
                                    UIActivityTypePostToTencentWeibo
                                    ];
    controller.excludedActivityTypes = excludedActivities;

    // Present the controller
    [[self topViewController] presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Remove the last zip files

- (void)removeLastZipFiles {
    // Path to the Documents directory
    NSString *path = [self getZipFileDocumentDirectory];

    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // For each file in the directory, create full path and delete the file
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:path error:&error]) {
        if ([file containsString:ZIP_FILE_SUFFIX] == NO) {
            continue;
        }

        NSString *filePath = [path stringByAppendingPathComponent:file];
        [fileManager removeItemAtPath:filePath error:&error];
    }
}

#pragma mark -

@end
