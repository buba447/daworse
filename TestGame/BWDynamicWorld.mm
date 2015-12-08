//
//  BWDynamicWorld.m
//  TestGame
//
//  Created by Brandon Withrow on 7/5/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWDynamicWorld.h"
#import "BWGraphObject.h"
#import "BWModelObject.h"
#include "btBulletDynamicsCommon.h"
#include <map>

typedef std::map<BWGraphObject *, btCollisionObject*>
  BWModelShapeMap;
typedef std::map<btCollisionObject*, BWGraphObject *>
  BWReverseModelShapeMap;

@implementation BWDynamicWorld {
  btDefaultCollisionConfiguration *collisionConfiguration;
  btCollisionDispatcher *dispatcher;
  btAxisSweep3 *broadPhase;
  btSequentialImpulseConstraintSolver *solver;
  btDiscreteDynamicsWorld *dynamicsWorld;
  BWModelShapeMap modelShapeMap;
  BWReverseModelShapeMap reverseModelShapeMap;
  NSMutableArray *physicsObjects_;
}

- (void)dealloc {
  [physicsObjects_ release];
  [super dealloc];
}

- (id)init {
  self = [super init];
  if (self) {
    physicsObjects_ = [[NSMutableArray alloc] init];
    collisionConfiguration = new btDefaultCollisionConfiguration();
    dispatcher = new btCollisionDispatcher(collisionConfiguration);
    btVector3 worldMin (-1000, -1000, -1000);
    btVector3 worldMax (1000, 1000, 1000);
    broadPhase = new btAxisSweep3(worldMin, worldMax);
    solver = new btSequentialImpulseConstraintSolver;
    dynamicsWorld =
        new btDiscreteDynamicsWorld(dispatcher,
                                    broadPhase,
                                    solver,
                                    collisionConfiguration);
    dynamicsWorld->setGravity(btVector3(0, 0, 0));
  }
  return self;
}

- (void)physicsUpdateWithElapsedTime:(NSTimeInterval)seconds {
  dynamicsWorld->stepSimulation(seconds, 32, 1/120.0f);
  for (BWGraphObject *object in physicsObjects_) {
    if (object.collisionType == BWGraphObjectCollisionTypeKinetic) {
      continue;
    }
    GLKMatrix4 newWorldTransform = [self physicsTransformForObject:object];
    object.worldTransform = newWorldTransform;
    object.worldTranslation = GLKVector3Make(newWorldTransform.m30, newWorldTransform.m31, newWorldTransform.m32);

    if ([object isKindOfClass:[BWModelObject class]]) {
      [(BWModelObject *)object setNormalMatrix:GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(object.worldTransform), NULL)];
    }
  }
}

- (void)updateKineticObject:(BWGraphObject *)object {
  if(1 == modelShapeMap.count(object)) {
    btCollisionObject *obj = modelShapeMap[object];
    btRigidBody *body = btRigidBody::upcast(obj);
    btTransform worldTransform;
    worldTransform.setFromOpenGLMatrix(object.worldTransform.m);
    body->getMotionState()->setWorldTransform(worldTransform);
  }
}

- (void)addKineticPhysicsObject:(BWGraphObject *)object {
  object.collisionType = BWGraphObjectCollisionTypeKinetic;
  object.dynamicWorld = self;
  [physicsObjects_ addObject:object];
  btCollisionShape* colShape =
    new btSphereShape(btScalar(1));
  
  // Create Dynamic Objects
  btTransform startTransform;
  startTransform.setFromOpenGLMatrix(object.worldTransform.m);
  
  btScalar	mass(0.0f);
  btVector3 localInertia(0,0,0);
  if(mass > 0.0f)
  {
    colShape->calculateLocalInertia(mass,localInertia);
  }
  
  btDefaultMotionState* myMotionState =
  new btDefaultMotionState(startTransform);
  btRigidBody::btRigidBodyConstructionInfo rbInfo(mass,
                                                  myMotionState,
                                                  colShape,
                                                  localInertia);
  rbInfo.m_restitution = 0.0f;
  rbInfo.m_friction = 0.99f;
  
  btRigidBody* body = new btRigidBody(rbInfo);
  
  body->setCollisionFlags( body->getCollisionFlags() |
                          btCollisionObject::CF_KINEMATIC_OBJECT);
  body->setActivationState(DISABLE_DEACTIVATION);
  dynamicsWorld->addRigidBody(body);
  modelShapeMap[object] = body;
}

- (void)addPhysicsObject:(BWGraphObject *)object {
  [physicsObjects_ addObject:object];
  object.collisionType = BWGraphObjectCollisionTypeRigid;
  btCollisionShape* colShape =
    new btSphereShape(btScalar(1));
  
  // Create Dynamic Objects
  btTransform startTransform;
  startTransform.setFromOpenGLMatrix(object.worldTransform.m);
  
  btScalar	mass(0.5);
  btVector3 localInertia(0,0,0);
  if(mass > 0.0f)
  {
    colShape->calculateLocalInertia(mass,localInertia);
  }
  
  btDefaultMotionState* myMotionState =
    new btDefaultMotionState(startTransform);
  btRigidBody::btRigidBodyConstructionInfo rbInfo(mass,
                                                  myMotionState,
                                                  colShape,
                                                  localInertia);
  rbInfo.m_restitution = 0.0f;
  rbInfo.m_friction = 0.99f;
  
  btRigidBody* body = new btRigidBody(rbInfo);
//  body->setDamping(0.1, 0.1);
  btVector3 angularVector = btVector3(object.angularVelocity.x, object.angularVelocity.y, object.angularVelocity.z);
  body->setAngularVelocity(angularVector);
  
  btVector3 linearVector = btVector3(object.linearVelocity.x, object.linearVelocity.y, object.linearVelocity.z);
  body->setLinearVelocity(linearVector);
  dynamicsWorld->addRigidBody(body);
  modelShapeMap[object] = body;
}

- (GLKMatrix4)physicsTransformForObject:(BWGraphObject *)anObject {
  GLKMatrix4 result = GLKMatrix4Identity;
  
  if(1 == modelShapeMap.count(anObject))
  {
    btCollisionObject *obj = modelShapeMap[anObject];
    btRigidBody *body = btRigidBody::upcast(obj);

    if(NULL != body)
    {
      btTransform trans;
      body->getMotionState()->getWorldTransform(trans);
      
      result.m00 = trans.getBasis()[0].x();
      result.m01 = trans.getBasis()[0].y();
      result.m02 = trans.getBasis()[0].z();
      result.m10 = trans.getBasis()[1].x();
      result.m11 = trans.getBasis()[1].y();
      result.m12 = trans.getBasis()[1].z();
      result.m20 = trans.getBasis()[2].x();
      result.m21 = trans.getBasis()[2].y();
      result.m22 = trans.getBasis()[2].z();
      result.m30 = trans.getOrigin().x();
      result.m31 = trans.getOrigin().y();
      result.m32 = trans.getOrigin().z();
    }
  }
  
  return result;
}


@end
