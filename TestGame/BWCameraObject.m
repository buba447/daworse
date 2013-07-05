//
//  BWCameraObject.m
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWCameraObject.h"

@implementation BWCameraObject

- (GLKMatrix4)rotationMatrix {
  GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.rotation.y), 0, 1, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(self.rotation.x), 1, 0, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(self.rotation.z), 0, 0, 1);
  return rotation;
}

- (void)commitTransforms {
  [super commitTransforms];
  self.invertedWorldTransform = GLKMatrix4Invert(self.worldTransform, 0);
}

@end
