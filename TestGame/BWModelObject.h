//
//  BWModelObject.h
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "BWGraphObject.h"
#import "BWShaderObject.h"

@interface BWModelObject : BWGraphObject
@property (nonatomic, assign) GLuint vertexArray;
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, retain) BWShaderObject *shader;

@property (nonatomic, readonly) GLKMatrix3 normalMatrix;
@property (nonatomic, assign) CGPoint uvOffset;
@property (nonatomic, assign) BOOL hidden;
@end
