//
//  BWGraphObject.m
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWGraphObject.h"
#import "BWAnimationTrack.h"

@implementation BWGraphObject {
  NSMutableDictionary *keyframeTracks_;
}

- (void)dealloc {
  [self removeAllAnimationKeys];
  [keyframeTracks_ release];
  [_children release];
  [super dealloc];
}

- (id)init {
  self = [super init];
  if (self) {
    keyframeTracks_ = [[NSMutableDictionary alloc] init];
    _posX = 0;
    _posY = 0;
    _posX = 0;
    _rotX = 0;
    _rotY = 0;
    _rotZ = 0;
    _scaleX = 1;
    _scaleY = 1;
    _scaleZ = 1;
    _transformIdentity = GLKMatrix4Identity;
  }
  return self;
}

- (GLKMatrix4)currentTransform {
  GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_rotX), 1, 0, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(_rotY), 0, 1, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(_rotZ), 0, 0, 1);
  GLKMatrix4 xform = GLKMatrix4Multiply(GLKMatrix4Translate(_transformIdentity, _posX, _posY, _posZ),
                                        rotation);
  if (_parentObject) {
    return GLKMatrix4Multiply(_parentObject.currentTransform, xform);
  }
  return xform;
}

- (void)removeChild:(BWGraphObject *)child {
  child.parentObject = nil;
  NSMutableArray *newChildren = [NSMutableArray arrayWithArray:_children];
  [newChildren removeObject:child];
  _children = newChildren;
}

- (void)addChild:(BWGraphObject *)child {
  child.parentObject = self;
  if (_children) {
    NSArray *oldChildren = _children;
    _children = [[oldChildren arrayByAddingObject:child] retain];
    [oldChildren release];
  } else {
    _children = [@[child] retain];
  }
}

- (void)updateForAnimation {
  [keyframeTracks_.allValues makeObjectsPerformSelector:@selector(updatePropertyForKeyframe)];
}

- (void)addAnimationKeyForProperty:(NSString *)property
                           toValue:(float)value
                          duration:(float)duration {
  [self addAnimationKeyForProperty:property toValue:value duration:duration delay:0];
}

- (void)addAnimationKeyForProperty:(NSString *)property
                           toValue:(float)value
                          duration:(float)duration
                             delay:(float)delay {
  BWKeyframe *newKeyframe = [[BWKeyframe alloc] init];
  newKeyframe.endValue = value;
  newKeyframe.duration = duration;
  newKeyframe.delay = delay;
  BWAnimationTrack *animTrack = [keyframeTracks_ objectForKey:property];
  if (!animTrack) {
    animTrack = [[BWAnimationTrack alloc] init];
    animTrack.property = property;
    animTrack.graphObject = self;
    [keyframeTracks_ setObject:animTrack forKey:property];
  }
  [animTrack addKeyframe:newKeyframe];
  [newKeyframe release];
}

- (void)removeAnimationForProperty:(NSString *)property {
  BWAnimationTrack *animTrack = [keyframeTracks_ objectForKey:property];
  if (animTrack) {
    [animTrack expireAllKeyframes];
  }
}

- (void)removeAllAnimationKeys {
  [keyframeTracks_.allValues makeObjectsPerformSelector:@selector(expireAllKeyframes)];
}
@end
