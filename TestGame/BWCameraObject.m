//
//  BWCameraObject.m
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWCameraObject.h"

@implementation BWCameraObject

- (GLKMatrix4)currentTransform {
  return GLKMatrix4Invert([super currentTransform], 0);
}

- (GLKMatrix4)rotationMatrix {
  GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.rotation.y), 0, 1, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(self.rotation.x), 1, 0, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(self.rotation.z), 0, 0, 1);
  return rotation;
}

@end
