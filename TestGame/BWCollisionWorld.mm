//
//  BWCollisionWorld.m
//  TestGame
//
//  Created by Brandon Withrow on 7/5/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//
#import "BWGraphObject.h"
#import "BWModelObject.h"

#import "BWCollisionWorld.h"
#include "btBulletCollisionCommon.h"
#include <map>
typedef std::map<BWGraphObject *, btCollisionObject*>
  BWModelShapeMap;
typedef std::map<btCollisionObject*, BWGraphObject *>
  BWReverseModelShapeMap;

@interface BWCollisionWorld () {
  btDefaultCollisionConfiguration *collisionConfiguration;
  btCollisionDispatcher *dispatcher;
  btCollisionWorld *collisionWorld;
  btAxisSweep3 *broadPhase;
  NSMutableArray *collisionObjects_;
  BWModelShapeMap modelMap_;
  BWReverseModelShapeMap reverseMap_;
}

@end

@implementation BWCollisionWorld

- (void)dealloc {
  [collisionObjects_ release];
  [super dealloc];
}

- (id)init {
  self = [super init];
  if (self) {
    collisionObjects_ = [[NSMutableArray alloc] init];
    collisionConfiguration = new
      btDefaultCollisionConfiguration();
    dispatcher = new
      btCollisionDispatcher(collisionConfiguration);
    btVector3 worldMin (-1000, -1000, -1000);
    btVector3 worldMax (1000, 1000, 1000);
    broadPhase = new btAxisSweep3(worldMin, worldMax);
    collisionWorld = new btCollisionWorld(dispatcher, broadPhase, collisionConfiguration);
  }
  return self;
}

- (void)addCollisionObject:(BWGraphObject *)object {
  [collisionObjects_ addObject:object];
  object.collisionWorld = self;
  btCollisionObject *btObject = new btCollisionObject();
  //temporarily set BB to unit box. TODO add boundingbox into the header file.
  btBoxShape* box = new btBoxShape(btVector3(0.5,0.5,0.5));
  btObject->setCollisionShape(box);
  btTransform worldTransform;
  worldTransform.setFromOpenGLMatrix(object.worldTransform.m);
  btObject->setWorldTransform(worldTransform);

  collisionWorld->addCollisionObject(btObject);
  modelMap_[object] = btObject;
  reverseMap_[btObject] = object;
}

- (void)removeCollisionObject:(BWGraphObject *)object {
  if(modelMap_[object])
  {
    btCollisionObject *obj = modelMap_[object];
//    btCollisionShape* shape = obj->getCollisionShape();
//    delete shape;
    collisionWorld->removeCollisionObject(obj);
		delete obj;
    object.collisionWorld = nil;
    [collisionObjects_ removeObject:object];
    modelMap_[object] = 0;
  }
}

- (void)updateGraphObject:(BWGraphObject *)object {
  if (1 == modelMap_.count(object)) {
    btCollisionObject *colObj = modelMap_[object];
    btTransform worldTransform;
    worldTransform.setFromOpenGLMatrix(object.worldTransform.m);
    colObj->setWorldTransform(worldTransform);
  }
}

- (NSArray *)stepCollisionWorld {
  collisionWorld->performDiscreteCollisionDetection();
  int numManifolds = collisionWorld->getDispatcher()->getNumManifolds();
  NSMutableArray *collisions = [NSMutableArray array];
  for (int i=0;i<numManifolds;i++)
	{
		btPersistentManifold* contactManifold =  collisionWorld->getDispatcher()->getManifoldByIndexInternal(i);
		btCollisionObject* obA = static_cast<btCollisionObject*>(contactManifold->getBody0());
		btCollisionObject* obB = static_cast<btCollisionObject*>(contactManifold->getBody1());

//    [(BWModelObject *)reverseMap_[obA] setDiffuseColor:GLKVector4Make(1, 0.25, 0.25, 1)];
//    [(BWModelObject *)reverseMap_[obB] setDiffuseColor:GLKVector4Make(1, 0.25, 0.25, 1)];
    [collisions addObject:(BWModelObject *)reverseMap_[obA]];
    [collisions addObject:(BWModelObject *)reverseMap_[obB]];
  }
  return collisions;
}

@end
