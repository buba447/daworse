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
  GLKVector3 previousLocation_;
  GLKVector3 previousRotation_;
  GLKVector3 previousScale_;
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
    _translation = GLKVector3Make(0, 0, 0);
    _rotation = GLKVector3Make(0, 0, 0);
    _scale = GLKVector3Make(1, 1, 1);
    previousScale_ = _scale;
    previousRotation_ = _rotation;
    previousLocation_ = _translation;
    _facingVector = GLKVector3Make(0, 0, 1);
    _transformIdentity = GLKMatrix4Identity;
    _currentTransform = GLKMatrix4Identity;
  }
  return self;
}

- (GLKMatrix4)currentTransform {
  return _currentTransform;
}

- (BOOL)hasMovedSinceLastFrame {
  return (!GLKVector3AllEqualToVector3(_translation, previousLocation_) ||
          !GLKVector3AllEqualToVector3(_rotation, previousRotation_) ||
          !GLKVector3AllEqualToVector3(_scale, previousScale_));
  
}

- (void)commitTransforms {
  if (self.hasMovedSinceLastFrame) {
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_rotation.x), 1, 0, 0);
    rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(_rotation.y), 0, 1, 0);
    rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(_rotation.z), 0, 0, 1);
    rotation = GLKMatrix4ScaleWithVector3(rotation, _scale);
    GLKMatrix4 xform = GLKMatrix4Multiply(GLKMatrix4TranslateWithVector3(_transformIdentity, _translation),
                                          rotation);
    if (_parentObject)
      _currentTransform = GLKMatrix4Multiply(_parentObject.currentTransform, xform);
    else
      _currentTransform = xform;
  }
  previousScale_ = _scale;
  previousRotation_ = _rotation;
  previousLocation_ = _translation;
  [self.children makeObjectsPerformSelector:@selector(commitTransforms)];
}

- (void)removeChild:(BWGraphObject *)child {
  child.parentObject = nil;
  NSMutableArray *newChildren = [NSMutableArray arrayWithArray:_children];
  [newChildren removeObject:child];
  _children = newChildren;
}

- (void)addChild:(BWGraphObject *)child {
  if (child.parentObject) {
    [child.parentObject removeChild:child];
  }
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
