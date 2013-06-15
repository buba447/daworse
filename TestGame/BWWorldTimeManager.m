//
//  BWWorldTimeManager.m
//  TestGame
//
//  Created by Brandon Withrow on 6/15/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWWorldTimeManager.h"
static BWWorldTimeManager *sharedManager = nil;

@implementation BWWorldTimeManager

#pragma mark - sharedManager singleton

+ (id)sharedManager {
  if (!sharedManager) {
    sharedManager = [[BWWorldTimeManager alloc] init];

  }
  return sharedManager;
}

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

- (id)retain {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;
}

- (oneway void)release {
  
}

- (id)autorelease {
	return self;
}


@end
