# DebugLogger


### How to use it
First step, you need to add SSZipArchive library to your project.<br />
This library is for the method compressing the log file.
```
pod 'SSZipArchive'
```

<br />

Folloewed, initial setup in AppDelegate.m
 
```
AppDelegate.m

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [DebugLogger sharedInstance];

    return YES;
}
```

<br />

Last one, just use NSLog & [[DebugLogger sharedInstance] exportLogFile]

```
ViewController.m

- (IBAction)actionAddLog:(id)sender {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *logMessage = [NSString stringWithFormat:@"hello world - %f", timeStamp];
    NSLog(@"%@", logMessage);
}

- (IBAction)actionExportLogFile:(id)sender {
    [[DebugLogger sharedInstance] exportLogFile];
}
```

<br />

### ![#f03c15](https://placehold.it/15/f03c15/000000?text=+) Warning
```
All of the log in the console will be disappear.
So, only enable it when you want to use it.
```

<br />

### Demo

![image](https://github.com/SunXiaoShan/DebugLogger/blob/master/ScreenShot/ExportLogFile.gif)

<br />

![image](https://github.com/SunXiaoShan/DebugLogger/blob/master/ScreenShot/ReadLogFile.gif)
