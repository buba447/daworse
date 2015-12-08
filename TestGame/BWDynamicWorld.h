//
//  BWDynamicWorld.h
//  TestGame
//
//  Created by Brandon Withrow on 7/5/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@class BWGraphObject;

@interface BWDynamicWorld : NSObject

- (void)physicsUpdateWithElapsedTime:(NSTimeInterval)seconds;
- (void)addPhysicsObject:(BWGraphObject *)object;
- (void)addKineticPhysicsObject:(BWGraphObject *)object;
- (void)updateKineticObject:(BWGraphObject *)object;
- (GLKMatrix4)physicsTransformForObject:(BWGraphObject *)anObject;
@end
