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
  GLKMatrix4 previousWorldMatrix_;
  GLKMatrix4 previousLocalMatrix_;
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
    _localTransform = GLKMatrix4Identity;
    _worldTransform = GLKMatrix4Identity;
    _movementVector = GLKVector3Make(0, 0, 0);
    previousLocalMatrix_ = GLKMatrix4Identity;
    previousWorldMatrix_ = GLKMatrix4Identity;
  }
  return self;
}

- (GLKVector3)worldTranslation {
  GLKMatrix4 worldXform = self.worldTransform;
  return GLKVector3Make(worldXform.m30, worldXform.m31, worldXform.m32);
}

- (void)moveAlongLocalNormal:(GLKVector3)direction {
  GLKMatrix4 rotation = [self rotationMatrix];
  GLKVector3 xMovement = GLKVector3MultiplyScalar(GLKVector3Make(rotation.m00, rotation.m01, rotation.m02), direction.x);
  GLKVector3 yMovement = GLKVector3MultiplyScalar(GLKVector3Make(rotation.m10, rotation.m11, rotation.m12), direction.y);
  GLKVector3 zMovement = GLKVector3MultiplyScalar(GLKVector3Make(rotation.m20, rotation.m21, rotation.m22), direction.z);
  _translation = GLKVector3Add(_translation, xMovement);
  _translation = GLKVector3Add(_translation, yMovement);
  _translation = GLKVector3Add(_translation, zMovement);
}

- (GLKMatrix4)rotationMatrix {
  GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_rotation.x), 1, 0, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(_rotation.y), 0, 1, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(_rotation.z), 0, 0, 1);
  return rotation;
}

- (GLKMatrix4)currentLocalTransform {
  GLKMatrix4 scale = GLKMatrix4ScaleWithVector3([self rotationMatrix], _scale);
  GLKMatrix4 xform = GLKMatrix4Multiply(GLKMatrix4TranslateWithVector3(GLKMatrix4Identity, _translation),
                                        scale);
  return xform;
}

- (GLKMatrix4)currentTransform {
  if (_parentObject)
    return GLKMatrix4Multiply(_parentObject.currentTransform, self.currentLocalTransform);
  return self.currentLocalTransform;
}

- (void)commitTransforms {
  previousWorldMatrix_ = _worldTransform;
  previousLocalMatrix_ = _localTransform;
  
  _localTransform = [self currentLocalTransform];
  if (_parentObject)
    _worldTransform = GLKMatrix4Multiply(_parentObject.worldTransform, _localTransform);
  else
    _worldTransform = _localTransform;
  
  GLKVector4 currentLocation = GLKMatrix4GetRow(_worldTransform, 3);
  GLKVector4 previousLocation = GLKMatrix4GetRow(previousWorldMatrix_, 3);
  GLKVector4 movementVector = GLKVector4Subtract(currentLocation, previousLocation);
  _movementVector = GLKVector3Make(movementVector.x, movementVector.y, movementVector.z);
  
  [self.children makeObjectsPerformSelector:@selector(commitTransforms)];
}

#pragma mark - Children Methods

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

#pragma mark - Animation Methods

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
