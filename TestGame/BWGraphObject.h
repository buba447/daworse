//
//  BWGraphObject.h
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef enum {
  BWGraphObjectCollisionTypeRigid,
  BWGraphObjectCollisionTypeKinetic,
  BWGraphObjectCollisionTypePassive,
  BWGraphObjectCollisionTypeNone
}BWGraphObjectCollisionType;
@class BWCollisionWorld;
@class BWDynamicWorld;

@interface BWGraphObject : NSObject

@property (nonatomic, assign) BWGraphObjectCollisionType collisionType;
@property (nonatomic, retain) BWDynamicWorld *dynamicWorld;
@property (nonatomic, retain) BWCollisionWorld *collisionWorld;

@property (nonatomic, assign) GLKVector3 angularVelocity;
@property (nonatomic, assign) GLKVector3 linearVelocity;

@property (nonatomic, readonly) GLKVector3 movementVector;

@property (nonatomic, assign) GLKVector3 worldTranslation;
@property (nonatomic, assign) GLKVector3 translation;

@property (nonatomic, assign) GLKVector3 rotation;
@property (nonatomic, assign) GLKVector3 scale;

@property (nonatomic, assign) GLKMatrix4 worldTransform;
@property (nonatomic, assign) GLKMatrix4 localTransform;

@property (nonatomic, readonly) GLKMatrix4 currentTransform;
@property (nonatomic, readonly) GLKMatrix4 currentLocalTransform;

@property (nonatomic, assign) BWGraphObject *parentObject;
@property (nonatomic, retain) NSArray *children;

@property (nonatomic, readonly) BOOL hasMovedSinceLastFrame;

- (void)moveAlongLocalNormal:(GLKVector3)direction;

- (void)commitTransforms;

- (GLKMatrix4)rotationMatrix;

- (void)removeChild:(BWGraphObject *)child;
- (void)addChild:(BWGraphObject *)child;

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
