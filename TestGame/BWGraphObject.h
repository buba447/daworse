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
@property (nonatomic, readonly) GLKVector3 facingVector;
@property (nonatomic, readonly) GLKVector3 movementVector;
@property (nonatomic, readonly) GLKVector3 worldTranslation;

@property (nonatomic, assign) GLKVector3 translation;
@property (nonatomic, assign) GLKVector3 rotation;
@property (nonatomic, assign) GLKVector3 scale;

@property (nonatomic, assign) GLKMatrix4 transformIdentity;
@property (nonatomic, assign) GLKMatrix4 currentTransform;

@property (nonatomic, assign) BWGraphObject *parentObject;
@property (nonatomic, retain) NSArray *children;

@property (nonatomic, readonly) BOOL hasMovedSinceLastFrame;

- (void)commitTransforms;

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
