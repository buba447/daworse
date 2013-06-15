//
//  BWAnimationTrack.m
//  TestGame
//
//  Created by Brandon Withrow on 6/15/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWAnimationTrack.h"
#import "BWWorldTimeManager.h"

@implementation BWAnimationTrack {
  BWKeyframe *currentKeyframe_;
}

- (void)dealloc {
  [currentKeyframe_ release];
  [super dealloc];
}

- (void)addKeyframe:(BWKeyframe *)keyframe {
  if (currentKeyframe_) {
    currentKeyframe_.nextKey = keyframe;
  } else {
    currentKeyframe_ = [keyframe retain];
    currentKeyframe_.startValue = [[_graphObject valueForKey:_property] floatValue];
    currentKeyframe_.startTime = [[BWWorldTimeManager sharedManager] currentTime];
  }
}

- (void)updatePropertyForKeyframe {
  if (!currentKeyframe_) return;
  if ([currentKeyframe_ phaseForTime:[[BWWorldTimeManager sharedManager] currentTime]] >= 1) {
    BWKeyframe *expiredKeyFrame = currentKeyframe_;
    currentKeyframe_ = [expiredKeyFrame.nextKey retain];
    expiredKeyFrame.previousKey = nil;
    if (!currentKeyframe_) {
      [_graphObject setValue:@(expiredKeyFrame.endValue) forKey:_property];
    }
    [expiredKeyFrame release];
  }
  if (currentKeyframe_)
    [_graphObject setValue:@([currentKeyframe_ valueForTime:[[BWWorldTimeManager sharedManager] currentTime]]) forKey:_property];
}

- (void)expireAllKeyframes {
  [currentKeyframe_ expireKeyframeChain];
  [currentKeyframe_ release];
  currentKeyframe_ = nil;
}
@end
