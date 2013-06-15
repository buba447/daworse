//
//  BWAnimationTrack.h
//  TestGame
//
//  Created by Brandon Withrow on 6/15/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BWKeyframe.h"
#import "BWGraphObject.h"

@interface BWAnimationTrack : NSObject

@property (nonatomic, retain) NSString *property;
@property (nonatomic, assign) BWGraphObject *graphObject;

- (void)addKeyframe:(BWKeyframe *)keyframe;
- (void)updatePropertyForKeyframe;
- (void)expireAllKeyframes;
@end
