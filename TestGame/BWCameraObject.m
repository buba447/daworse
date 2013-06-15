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

@end
