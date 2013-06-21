//
//  BWLookAtCamera.m
//  TestGame
//
//  Created by Brandon Withrow on 6/19/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWLookAtCamera.h"

@implementation BWLookAtCamera

- (id)init
{
  self = [super init];
  if (self) {
    _lookAtPoint = GLKVector3Make(0, 0, 0);
  }
  return self;
}

- (GLKMatrix4)currentTransform {
  GLKMatrix4 xform= GLKMatrix4MakeLookAt(self.translation.x, self.translation.y, self.translation.z,
                                         _lookAtPoint.x, _lookAtPoint.y, _lookAtPoint.z,
                                         0, 100, 0);
  if (self.parentObject) 
    return GLKMatrix4Multiply(self.parentObject.currentTransform, xform);
  return xform;
}

@end
