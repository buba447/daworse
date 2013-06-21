//
//  BWLookAtCamera.h
//  TestGame
//
//  Created by Brandon Withrow on 6/19/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWGraphObject.h"
#import "BWCameraObject.h"
@interface BWLookAtCamera : BWCameraObject
@property (nonatomic, assign) GLKVector3 lookAtPoint;
@end
