//
//  ViewController.m
//  LoggerDemo
//
//  Created by Phineas.Huang on 2019/8/15.
//  Copyright © 2019 Phineas. All rights reserved.
//

#import "ViewController.h"
#import "DebugLogger.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)actionAddLog:(id)sender {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *logMessage = [NSString stringWithFormat:@"hello world - %f", timeStamp];
    NSLog(@"%@", logMessage);
}

- (IBAction)actionExportLogFile:(id)sender {
    [[DebugLogger sharedInstance] exportLogFile];
}

@end
