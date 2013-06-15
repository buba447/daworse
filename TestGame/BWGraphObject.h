//
//  BWGraphObject.h
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface BWGraphObject : NSObject
@property (nonatomic, assign) float posX;
@property (nonatomic, assign) float posY;
@property (nonatomic, assign) float posZ;
@property (nonatomic, assign) float rotX;
@property (nonatomic, assign) float rotY;
@property (nonatomic, assign) float rotZ;
@property (nonatomic, assign) float scaleX;
@property (nonatomic, assign) float scaleY;
@property (nonatomic, assign) float scaleZ;
@property (nonatomic, assign) BOOL relativeTransform;
@property (nonatomic, assign) GLKMatrix4 transformIdentity;
@property (nonatomic, readonly) GLKMatrix4 currentTransform;

@property (nonatomic, assign) BWGraphObject *parentObject;
@property (nonatomic, retain) NSArray *children;

- (void)removeChild:(BWGraphObject *)child;
- (void)addChild:(BWGraphObject *)child;

- (void)updateForAnimation;
- (void)addAnimationKeyForProperty:(NSString *)property
                           toValue:(float)value
                          duration:(float)duration;
- (void)addAnimationKeyForProperty:(NSString *)property
                           toValue:(float)value
                          duration:(float)duration
                             delay:(float)delay;
- (void)removeAnimationForProperty:(NSString *)property;
- (void)removeAllAnimationKeys;
@end
