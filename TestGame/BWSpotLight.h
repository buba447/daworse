//
//  BWSpotLight.h
//  TestGame
//
//  Created by Brandon Withrow on 6/28/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWGraphObject.h"

@interface BWSpotLight : BWGraphObject
@property (nonatomic, assign) float coneAngle;
@property (nonatomic, assign) float intensity;
@property (nonatomic, assign) float fallOff;
@property (nonatomic, assign) GLKVector3 lightColor;
@property (nonatomic, readonly) GLKMatrix4 lightInfo;
@end
