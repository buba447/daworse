//
//  BWShaderObject.h
//  TestGame
//
//  Created by Brandon Withrow on 6/12/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface BWShaderObject : NSObject
@property (nonatomic, assign) GLuint shaderProgram;
@property (nonatomic, assign) GLint uniformModelMatrix;
@property (nonatomic, assign) GLint uniformNormalMatrix;
@property (nonatomic, assign) GLint uniformCameraMatrix;
@property (nonatomic, assign) GLint uniformTextureUV;

@end
