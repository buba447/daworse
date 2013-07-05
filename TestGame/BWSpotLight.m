//
//  BWSpotLight.m
//  TestGame
//
//  Created by Brandon Withrow on 6/28/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWSpotLight.h"

@implementation BWSpotLight

- (id)init {
  self = [super init];
  if (self) {
    _coneAngle = 0.9;
    _intensity = 1;
    _fallOff = 100;
    _lightColor = GLKVector3Make(1, 1, 1);
  }
  return self;
}

- (void)commitTransforms {
  [super commitTransforms];
  _lightInfo = GLKMatrix4Make(self.worldTransform.m30, self.worldTransform.m31, self.worldTransform.m32, 0,
                              self.worldTransform.m20, self.worldTransform.m21, self.worldTransform.m22, 0,
                              _lightColor.x, _lightColor.y, _lightColor.z, 0,
                              self.intensity, self.coneAngle, self.fallOff, 0);
}
@end
