//
//  BWForce.h
//  TestGame
//
//  Created by Brandon Withrow on 6/19/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWGraphObject.h"

@interface BWForce : BWGraphObject

@property (nonatomic, assign) float magnitude;
@property (nonatomic, assign) float fallOff;
@property (nonatomic, assign) float radius;
- (void)stepForce:(float)timeStep;
@end
