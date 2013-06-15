//
//  BWKeyframe.m
//  TestGame
//
//  Created by Brandon Withrow on 6/15/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWKeyframe.h"

@implementation BWKeyframe

- (id)init {
  self = [super init];
  if (self) {
    _delay = 0;
  }
  return self;
}

- (void)dealloc {
  NSLog(@"Dealloc of Keyframe");
  [_nextKey release];
  [_previousKey release];
  [super dealloc];
}

- (void)setNextKey:(BWKeyframe *)nextKey {
  if (_nextKey) {
    [_nextKey setNextKey:nextKey];
    return;
  }
  _nextKey = [nextKey retain];
  _nextKey.startTime = self.expireTime;
  _nextKey.startValue = _endValue;
  _nextKey.previousKey = self;
}

- (float)expireTime {
  return _delay + _startTime + _duration;
}

- (float)phaseForTime:(float)time {
  return MAX((time - (_startTime + _delay)) / (self.expireTime - _startTime), 0);
}

- (float)valueForTime:(float)time {
  float phase = [self phaseForTime:time];
  return _startValue + ((_endValue - _startValue) * phase);
}

- (void)expireKeyframeChain {
  self.previousKey = nil;
  [self.nextKey expireKeyframeChain];
}

@end
