//
//  BWKeyframe.h
//  TestGame
//
//  Created by Brandon Withrow on 6/15/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BWKeyframe : NSObject
@property (nonatomic, assign) float startTime;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) float startValue;
@property (nonatomic, assign) float endValue;
@property (nonatomic, retain) BWKeyframe *nextKey;
@property (nonatomic, retain) BWKeyframe *previousKey;
@property (nonatomic, readonly) float expireTime;
@property (nonatomic, assign) float delay;
- (float)valueForTime:(float)time;
- (float)phaseForTime:(float)time;
- (void)expireKeyframeChain;
@end
