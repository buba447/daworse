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
  GLKVector3 normalMovement_;
  GLKVector3 previousTranslation_;
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
    _localTransform = GLKMatrix4Identity;
    _worldTransform = GLKMatrix4Identity;
    _movementVector = GLKVector3Make(0, 0, 0);
    previousLocalMatrix_ = GLKMatrix4Identity;
    previousWorldMatrix_ = GLKMatrix4Identity;
  }
  return self;
}

- (void)moveAlongLocalNormal:(GLKVector3)direction {
  normalMovement_ = direction;
}

- (GLKMatrix4)rotationMatrix {
  GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_rotation.x), 1, 0, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(_rotation.y), 0, 1, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(_rotation.z), 0, 0, 1);
  return rotation;
}

- (GLKMatrix4)currentLocalTransform {
  GLKMatrix4 scale = GLKMatrix4ScaleWithVector3([self rotationMatrix], _scale);
  scale.m30 = _translation.x;
  scale.m31 = _translation.y;
  scale.m32 = _translation.z;
  return scale;
}

- (GLKMatrix4)currentTransform {
  if (_parentObject)
    return GLKMatrix4Multiply(_parentObject.currentTransform, self.currentLocalTransform);
  return self.currentLocalTransform;
}

- (void)commitTransforms {
  previousWorldMatrix_ = _worldTransform;
  previousLocalMatrix_ = _localTransform;
  
  if (normalMovement_.x != 0 || normalMovement_.y != 0 || normalMovement_.z != 0) {
    GLKVector3 xMovement = GLKVector3MultiplyScalar(GLKVector3Make(previousLocalMatrix_.m00, previousLocalMatrix_.m01, previousLocalMatrix_.m02), normalMovement_.x);
    GLKVector3 yMovement = GLKVector3MultiplyScalar(GLKVector3Make(previousLocalMatrix_.m10, previousLocalMatrix_.m11, previousLocalMatrix_.m12), normalMovement_.y);
    GLKVector3 zMovement = GLKVector3MultiplyScalar(GLKVector3Make(previousLocalMatrix_.m20, previousLocalMatrix_.m21, previousLocalMatrix_.m22), normalMovement_.z);
    _translation = GLKVector3Add(_translation, xMovement);
    _translation = GLKVector3Add(_translation, yMovement);
    _translation = GLKVector3Add(_translation, zMovement);
    normalMovement_ = GLKVector3Make(0, 0, 0);
  }
  
  _localTransform = [self currentLocalTransform];

  if (_parentObject)
    _worldTransform = GLKMatrix4Multiply(_parentObject.worldTransform, _localTransform);
  else
    _worldTransform = _localTransform;
  
  _worldTranslation = GLKVector3Make(self.worldTransform.m30, self.worldTransform.m31, self.worldTransform.m32);
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
