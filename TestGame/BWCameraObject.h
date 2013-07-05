//
//  BWCameraObject.h
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWGraphObject.h"

@interface BWCameraObject : BWGraphObject
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (nonatomic, assign) GLKMatrix4 invertedWorldTransform;
@end
