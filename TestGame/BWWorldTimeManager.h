//
//  BWWorldTimeManager.h
//  TestGame
//
//  Created by Brandon Withrow on 6/15/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWWorldTimeManager : NSObject
@property (nonatomic, assign) float currentTime;
+ (id)sharedManager;
@end
