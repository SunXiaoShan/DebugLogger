//
//  DebugLogger.h
//  motorize
//
//  Created by Phineas.Huang on 2019/7/1.
//  Copyright © 2019 SunXiaoShan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugLogger : NSObject

+ (instancetype)sharedInstance;

- (void)exportLogFile;

@end

NS_ASSUME_NONNULL_END
