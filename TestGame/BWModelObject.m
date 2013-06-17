//
//  BWModelObject.m
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWModelObject.h"

@implementation BWModelObject

- (void)dealloc {
  [_shader release];
  [super dealloc];
}

- (id)init {
  self = [super init];
  if (self) {
    _texture = 0;
    _diffuseColor = GLKVector4Make(0, 0, 0, 1);
    _uvOffset = CGPointZero;
  }
  return self;
}

- (GLKMatrix3)normalMatrix {
  return GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.currentTransform), NULL);
}

@end
