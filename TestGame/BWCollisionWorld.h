//
//  BWCollisionWorld.h
//  TestGame
//
//  Created by Brandon Withrow on 7/5/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BWGraphObject;

@interface BWCollisionWorld : NSObject

- (void)addCollisionObject:(BWGraphObject *)object;
- (void)removeCollisionObject:(BWGraphObject *)object;
- (void)updateGraphObject:(BWGraphObject *)object;
- (NSArray *)stepCollisionWorld;
@end
