//
//  BWForce.m
//  TestGame
//
//  Created by Brandon Withrow on 6/19/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWForce.h"

@implementation BWForce

- (id)init {
  self = [super init];
  if (self) {
    _magnitude = 0;
    _radius = 20;
    _fallOff = 20;
  }
  return self;
}
- (void)addChild:(BWGraphObject *)child {
  if (self.children) {
    NSArray *oldChildren = self.children;
    self.children = [oldChildren arrayByAddingObject:child];
  } else {
    self.children = @[child];
  }
}

- (void)stepForce:(float)timeStep {
  float distanceToTravel = _magnitude * timeStep;
  for (BWGraphObject *child in self.children) {
    GLKVector3 movementVector = GLKVector3Subtract(self.worldTranslation, child.worldTranslation);
    float length =GLKVector3Distance(self.worldTranslation, child.worldTranslation);
    if (length > _fallOff + _radius) {
      continue;
    }
    float newMagnitude = ((length - _radius > 0 ?
                           (length - _radius) / _fallOff :
                           1 +  ((_radius - length) / _radius))) * distanceToTravel;
    float scale = 1 / length;
    
    movementVector = GLKVector3Normalize(movementVector);
    movementVector = GLKVector3MultiplyScalar(movementVector, newMagnitude * scale);
    child.translation = GLKVector3Add(child.translation, movementVector);
    [child commitTransforms];
  }
}
@end
