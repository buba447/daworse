//
//  ViewController.m
//  TestGame
//
//  Created by Brandon Withrow on 6/8/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

#import "ViewController.h"
#import "BWShaderObject.h"
#import "BWGraphObject.h"
#import "BWModelObject.h"
#import "BWCameraObject.h"
#import "BWWorldTimeManager.h"
#import "BWMesh.h"
#import "BWLookAtCamera.h"
#import "BWForce.h"
#import "BWSpotLight.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define ARC4RANDOM_MAX      0x100000000

GLfloat normalVertices[36] = {
  0.f, 0.f, 1.f, 0.f, 0.f, 1.f,
  0.f, 0.f, 0.f, 0.f, 0.f, 1.f,
  0.f, 1.f, 0.f, 0.f, 1.f, 0.f,
  0.f, 0.f, 0.f, 0.f, 1.f, 0.f,
  1.f, 0.f, 0.f, 1.f, 0.f, 0.f,
  0.f, 0.f, 0.f, 1.f, 0.f, 0.f,
};

GLfloat gridLine [264] = {
  -5.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, -4.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, -4.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, -3.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, -3.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, -2.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, -2.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, -1.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, -1.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, 0.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, 0.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, 5.f, 1.f, 0.f, 0.f,
  5.f, 0.f, 5.f, 1.f, 0.f, 0.f,
  -5.f, 0.f, 4.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, 4.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, 3.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, 3.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, 2.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, 2.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, 1.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, 1.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  -5.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  -4.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  -4.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  -3.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  -3.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  -2.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  -2.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  -1.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  -1.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  0.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  0.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  5.f, 0.f, -5.f, 0.f, 0.f, 1.f,
  5.f, 0.f, 5.f, 0.f, 0.f, 1.f,
  4.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  4.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  3.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  3.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  2.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  2.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f,
  1.f, 0.f, -5.f, 0.5f, 0.5f, 0.5f,
  1.f, 0.f, 5.f, 0.5f, 0.5f, 0.5f
};


@interface ViewController () {
  BOOL debugMode_;
  NSMutableArray *debugGeometry_;
  BWCameraObject *mainCamera_;
  NSMutableArray *models_;
  NSMutableDictionary *textures_;
  NSMutableDictionary *shaders_;
  NSMutableDictionary *meshes_;
  BWGraphObject *heroParent_;
  BWModelObject *heroModel_;
  BWGraphObject *graphTree_;
  NSMutableArray *cameraSteps_;
  NSMutableArray *cameraStartTimes_;
  float shipRotation_;
  float shipVelocity_;
  BWSpotLight *spotLight_;
  BWSpotLight *worldLight_;
}

@property (strong, nonatomic) EAGLContext *context;
- (void)setupGL;
- (void)tearDownGL;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ViewController

- (void)dealloc {
  [self tearDownGL];
  if ([EAGLContext currentContext] == self.context) {
    [EAGLContext setCurrentContext:nil];
  }
  [worldLight_ release];

  [spotLight_ release];
  [heroParent_ release];
  [debugGeometry_ release];
  [mainCamera_ release];
  [models_ release];
  [textures_ release];
  [shaders_ release];
  [meshes_ release];
  [heroModel_ release];
  [graphTree_ release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if ([self isViewLoaded] && ([[self view] window] == nil)) {
    self.view = nil;
    [self tearDownGL];
    if ([EAGLContext currentContext] == self.context) {
      [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  cameraStartTimes_ = [[NSMutableArray alloc] init];
  cameraSteps_ = [[NSMutableArray alloc] init];
  debugMode_ = YES;
  BWWorldTimeManager *time = [BWWorldTimeManager sharedManager];
  time.currentTime = 0;
  shaders_ = [[NSMutableDictionary alloc] init];
  debugGeometry_ = [[NSMutableArray alloc] init];
  meshes_ = [[NSMutableDictionary alloc] init];
  textures_ = [[NSMutableDictionary alloc] init];
  graphTree_ = [[BWGraphObject alloc] init];
  models_ = [[NSMutableArray alloc] init];
  mainCamera_ = [[BWCameraObject alloc] init];
  spotLight_ = [[BWSpotLight alloc] init];
  worldLight_ = [[BWSpotLight alloc] init];
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

  if (!self.context) {
      NSLog(@"Failed to create ES context");
  }
  
  GLKView *view = (GLKView *)self.view;
  view.context = self.context;
  view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
  [self setupGL];
  
  UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [newButton addTarget:self action:@selector(switchDebugMode) forControlEvents:UIControlEventTouchUpInside];
  newButton.frame = CGRectMake(0, 0, 100, 44);
  [self.view addSubview:newButton];
   
  [self setupWorld];
  
  UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
  press.cancelsTouchesInView = NO;
  press.minimumPressDuration = 0;
//  press.numberOfTapsRequired = 2;
  [self.view addGestureRecognizer:press];
  [press release];

}

- (void)logTransform:(GLKMatrix4)transform {
  NSLog(@"\r\rMatrix:\r      X         Y         Z         W        \r XVec %f, %f, %f, %f \r YVec %f, %f, %f, %f \r ZVec %f, %f, %f, %f \r PVec %f, %f, %f, %f \r\r",
        transform.m00, transform.m01, transform.m02, transform.m03,
        transform.m10, transform.m11, transform.m12, transform.m13,
        transform.m20, transform.m21, transform.m22, transform.m23,
        transform.m30, transform.m31, transform.m32, transform.m33);
}

- (void)switchDebugMode {
  debugMode_ = !debugMode_;
}

- (void)handlePress:(UILongPressGestureRecognizer *)press {
  CGPoint location = [press locationInView:self.view];
  GLKVector2 loc = GLKVector2Make(location.x, location.y);
  GLKVector2 origin = GLKVector2Make(self.view.bounds.size.width / 2, self.view.bounds.size.height * 0.75);
  shipVelocity_ = GLKVector2Distance(loc, origin) / 280;
  
  origin = GLKVector2Subtract(loc, origin);
  origin = GLKVector2Normalize(origin);
  GLKVector2 normal = GLKVector2Make(1, 0);
  float angle = GLKVector2DotProduct(normal, origin);
//  NSLog(@"Length %f Angle %f", shipVelocity_, angle);
  shipRotation_ = angle * 2;
  if (press.state == UIGestureRecognizerStateEnded) {
    shipVelocity_ = 0;
    shipRotation_ = 0;
  }
}

- (void)setupWorld {
  
  [self loadMeshAtFile:@"fixedHornet"];
  [self loadMeshAtFile:@"thruster"];
  [self loadMeshAtFile:@"testExport2"];
  [self loadMeshAtFile:@"sphere"];
  
  worldLight_.translation = GLKVector3Make(0, 5, 5);
  worldLight_.intensity = 2;
  worldLight_.coneAngle = -100;
  [graphTree_ addChild:worldLight_];
  
  heroParent_ = [[BWGraphObject alloc] init];
  heroParent_.translation = GLKVector3Make(0, 0, 0);
  heroParent_.rotation = GLKVector3Make(0, 45, 0);
  [graphTree_ addChild:heroParent_];
  
  heroModel_ = [[BWModelObject alloc] init];
  heroModel_.mesh = [meshes_ objectForKey:@"fixedHornet"];
  heroModel_.shader = [shaders_ objectForKey:@"Shader"];
//  heroModel_.texture = [[textures_ valueForKey:@"test.png"] intValue];
  heroModel_.diffuseColor = GLKVector4Make(0.7, 0.85, 1, 1);
  heroModel_.uvOffset = CGPointZero;
  
  [heroModel_ addChild:spotLight_];
  spotLight_.coneAngle = 0.8;
  spotLight_.intensity = 1;
  spotLight_.fallOff = 30;
  spotLight_.lightColor = GLKVector3Make(1, 0.9, 0.6);
  spotLight_.translation = GLKVector3Make(0, 0, 0.5);
  
  BWModelObject *rightJet = [[BWModelObject alloc] init];
  rightJet.mesh = [meshes_ objectForKey:@"thruster"];
  rightJet.shader = [shaders_ objectForKey:@"Shader"];
  rightJet.diffuseColor = heroModel_.diffuseColor;
  rightJet.translation = GLKVector3Make(-0.431, 0.131, -0.531);
  [heroModel_ addChild:rightJet];
  [models_ addObject:rightJet];
  [rightJet release];
  rightJet = nil;
  
  rightJet = [[BWModelObject alloc] init];
  rightJet.mesh = [meshes_ objectForKey:@"thruster"];
  rightJet.shader = [shaders_ objectForKey:@"Shader"];
  rightJet.diffuseColor = heroModel_.diffuseColor;
  rightJet.translation = GLKVector3Make(-0.6111, -0.117, 0.232);
  [heroModel_ addChild:rightJet];
  [models_ addObject:rightJet];
  [rightJet release];
  rightJet = nil;
  
  rightJet = [[BWModelObject alloc] init];
  rightJet.mesh = [meshes_ objectForKey:@"thruster"];
  rightJet.shader = [shaders_ objectForKey:@"Shader"];
  rightJet.diffuseColor = heroModel_.diffuseColor;
  rightJet.translation = GLKVector3Make(0.431, 0.131, -0.531);
  rightJet.scale = GLKVector3Make(-1, 1, 1);
  [heroModel_ addChild:rightJet];
  [models_ addObject:rightJet];
  [rightJet release];
  rightJet = nil;
  
  rightJet = [[BWModelObject alloc] init];
  rightJet.mesh = [meshes_ objectForKey:@"thruster"];
  rightJet.shader = [shaders_ objectForKey:@"Shader"];
  rightJet.diffuseColor = heroModel_.diffuseColor;
  rightJet.translation = GLKVector3Make(0.6111, -0.117, 0.232);
  rightJet.scale = GLKVector3Make(-1, 1, 1);
  [heroModel_ addChild:rightJet];
  [models_ addObject:rightJet];
  [rightJet release];
  rightJet = nil;
  
  [heroParent_ addChild:heroModel_];
  
  BWGraphObject *cameraParent = [[BWGraphObject alloc] init];
  [cameraParent addChild:mainCamera_];
  heroParent_.translation = GLKVector3Make(20, 0, 20);
  
  
  [graphTree_ addChild:cameraParent];
  mainCamera_.rotation = GLKVector3Make(-25, 180, 0);
  mainCamera_.translation = GLKVector3Make(0, 8, -11);
  float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
  mainCamera_.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), aspect, 0.1f, 100.0f);
  [models_ addObject:heroModel_];
  
  BWModelObject *sphere = [[BWModelObject alloc] init];
  sphere.mesh = [meshes_ objectForKey:@"sphere"];
  sphere.shader = [shaders_ objectForKey:@"Shader"];
  sphere.diffuseColor = GLKVector4Make(0.5, 0.5, 0.5, 1);
  sphere.scale = GLKVector3Make(2, 2, 2);
  sphere.translation = GLKVector3Make(5, 0, 5);
  [models_ addObject:sphere];
  [graphTree_ addChild:sphere];
  [sphere release];
  
  for (int i = 0; i < 200; i ++) {
    BWModelObject *newModel = [[BWModelObject alloc] init];
    newModel.mesh = [meshes_ objectForKey:@"sphere"];
    newModel.shader = [shaders_ objectForKey:@"Shader"];
    newModel.diffuseColor = GLKVector4Make(0.5, 0.5, 0.5, 1);
    newModel.uvOffset = CGPointZero;
    newModel.translation = GLKVector3Make(floorf(((double)arc4random() / ARC4RANDOM_MAX) * 80.0f) - 40,
                                          0,
                                          floorf(((double)arc4random() / ARC4RANDOM_MAX) * 80.0f) - 40);
    newModel.rotation = GLKVector3Make(floorf(((double)arc4random() / ARC4RANDOM_MAX) * 360.0f) - 180,
                                          0,
                                          floorf(((double)arc4random() / ARC4RANDOM_MAX) * 360.0f) - 180);
    [models_ addObject:newModel];
    [graphTree_ addChild:newModel];
  }
  [graphTree_ commitTransforms];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
  BWWorldTimeManager *time = [BWWorldTimeManager sharedManager];
  time.currentTime += self.timeSinceLastUpdate;
  

  for (BWModelObject *mocel in models_) {
    if (mocel != heroModel_ && ![heroModel_.children containsObject:mocel]) {
      [mocel moveAlongLocalNormal:GLKVector3Make((-cos(time.currentTime) * 0.01), (cos(time.currentTime + [models_ indexOfObject:mocel]) * 0.01), 0)];
      mocel.rotation = GLKVector3Add(mocel.rotation, GLKVector3Make(1, 1, 2));
    }
  }
  heroParent_.rotation =  GLKVector3Add(heroParent_.rotation, GLKVector3Make(0, shipRotation_, 0));
  [heroParent_ moveAlongLocalNormal:GLKVector3Make(0, 0, shipVelocity_)];
  GLKVector3 rotation = heroModel_.rotation;
  rotation.z = shipRotation_ * -5;
  heroModel_.rotation = GLKVector3Add(rotation, GLKVector3Make(-(cos(time.currentTime * 2 ) * 0.3), 0, -(cos(time.currentTime * 2) * 0.1)));
  
  [heroModel_ moveAlongLocalNormal:GLKVector3Make(0, (cos(time.currentTime * 2) * 0.01), 0)];
  mainCamera_.parentObject.translation = heroParent_.translation;
  GLKVector3 followRotation = heroParent_.rotation;
  [cameraSteps_ addObject:[NSValue valueWithBytes:&followRotation objCType:@encode(GLKVector3)]];
  [cameraStartTimes_ addObject:@([[BWWorldTimeManager sharedManager] currentTime] + 0.3)];
  if (cameraStartTimes_.count > 0) {
    float nextStep = [[cameraStartTimes_ objectAtIndex:0] floatValue];
    if (nextStep < [[BWWorldTimeManager sharedManager] currentTime]) {
      GLKVector3 storedVector;
      NSValue *value = [cameraSteps_ objectAtIndex:0];
      [value getValue:&storedVector];
      mainCamera_.parentObject.rotation = storedVector;
      
      [cameraStartTimes_ removeObjectAtIndex:0];
      [cameraSteps_ removeObjectAtIndex:0];
    }
  }
  GLKVector3 leftJetsRotation, rightJetsRotation, backJetsL, backJetsR;
  float jointRotation = -25 + (shipVelocity_ * 25);
  
  float rotationMultiplier = (shipRotation_ + 2) / 4;
  
  
  leftJetsRotation = GLKVector3Make((rotationMultiplier * -45), 0, 0);
  
  rightJetsRotation = GLKVector3Make((1 - rotationMultiplier) * -45, 0, 0);
  backJetsL = GLKVector3Make(jointRotation, 0, 0);
  backJetsR = GLKVector3Make(jointRotation, 0, 0);
  
  
  [(BWModelObject *)[heroModel_.children objectAtIndex:0] setRotation:backJetsR];
  [(BWModelObject *)[heroModel_.children objectAtIndex:1] setRotation:rightJetsRotation];
  [(BWModelObject *)[heroModel_.children objectAtIndex:2] setRotation:backJetsL];
  [(BWModelObject *)[heroModel_.children objectAtIndex:3] setRotation:leftJetsRotation];
  [graphTree_ commitTransforms];
  
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
  glClearColor(0.15f, 0.15f, 0.15f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glUseProgram([[shaders_ objectForKey:@"Shader"] shaderProgram]);
  GLKVector3 cameraFacing = GLKVector3Make(mainCamera_.worldTransform.m20, mainCamera_.worldTransform.m21, mainCamera_.worldTransform.m22);
  float drawCalls = 0;
  for (BWModelObject *model in models_) {
    if (model.hidden) {
      continue;
    }
    GLKVector3 toCameraNormal = GLKVector3Normalize( GLKVector3Subtract(model.worldTranslation, mainCamera_.worldTranslation));
    float dotP = GLKVector3DotProduct(cameraFacing, toCameraNormal);
//    [self logTransform:mainCamera_.worldTransform];
//    [self logTransform:model.worldTransform];
        if (dotP > -0.85)
      continue;
//    NSLog(@"Camera Normal, %f %f %f \rModel Normal %f %f %f \rDotP %f", cameraFacing.x, cameraFacing.y, cameraFacing.z, toCameraNormal.x, toCameraNormal.y, toCameraNormal.z, dotP);

    drawCalls ++;
    glBindVertexArrayOES(model.mesh.vertexArray);
    glBindTexture(GL_TEXTURE_2D, model.texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniformMatrix4fv(model.shader.uniformModelMatrix, 1, 0, model.worldTransform.m);
    glUniformMatrix3fv(model.shader.uniformNormalMatrix, 1, 0, model.normalMatrix.m);
    glUniformMatrix4fv(model.shader.uniformCameraLocationMatrix, 1, 0, mainCamera_.invertedWorldTransform.m);
    glUniformMatrix4fv(model.shader.uniformCameraProjectionMatrix, 1, 0, mainCamera_.projectionMatrix.m);
    glUniform2f(model.shader.uniformTextureUV, model.uvOffset.x, model.uvOffset.y);
    glUniform4f(model.shader.uniformDiffuse, model.diffuseColor.x, model.diffuseColor.y, model.diffuseColor.z, model.diffuseColor.w);
    glUniformMatrix4fv(model.shader.uniformLight1, 1, 0, spotLight_.lightInfo.m);
    glUniform1i(model.shader.uniformLight1On, 1);
    glUniformMatrix4fv(model.shader.uniformLight2, 1, 0, worldLight_.lightInfo.m);
    glUniform1i(model.shader.uniformLight2On, 1);
    glDrawArrays(GL_TRIANGLES, 0, model.mesh.vertexCount);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindVertexArrayOES(0);
  }
//  NSLog(@"Draw Calls %f", drawCalls);
  if (debugMode_) {
    BWShaderObject *debugShader = [shaders_ objectForKey:@"LineShader"];
    BWMesh *normalMesh = [debugGeometry_ objectAtIndex:0];
//    Draw normals TO DO Draw actual normals. Shhhhhhh. Dont Tell
    glBindVertexArrayOES(normalMesh.vertexArray);
    glUseProgram(debugShader.shaderProgram);
    for (BWModelObject *model in models_) {
      glUniformMatrix4fv(debugShader.uniformModelMatrix, 1, 0, model.worldTransform.m);
      glUniformMatrix4fv(debugShader.uniformCameraLocationMatrix, 1, 0, mainCamera_.invertedWorldTransform.m);
      glUniformMatrix4fv(debugShader.uniformCameraProjectionMatrix, 1, 0, mainCamera_.projectionMatrix.m);
      glDrawArrays(GL_LINES, 0, normalMesh.vertexCount);
    }
    glBindVertexArrayOES(0);
    
//    Draw X grid lines
    BWMesh *gridMesh = [debugGeometry_ objectAtIndex:1];
    glBindVertexArrayOES(gridMesh.vertexArray);
    glUseProgram(debugShader.shaderProgram);
    glUniformMatrix4fv(debugShader.uniformModelMatrix, 1, 0, GLKMatrix4Identity.m);
    glUniformMatrix4fv(debugShader.uniformCameraLocationMatrix, 1, 0, mainCamera_.invertedWorldTransform.m);
    glUniformMatrix4fv(debugShader.uniformCameraProjectionMatrix, 1, 0, mainCamera_.projectionMatrix.m);
    glDrawArrays(GL_LINES, 0, gridMesh.vertexCount);
    glBindVertexArrayOES(0);
  }
}

#pragma mark - load up Open GL methods

- (GLuint)loadTextureNamed:(NSString *)file {
  if ([textures_ objectForKey:file]) {
    return [[textures_ objectForKey:file] integerValue];
  }
  CGImageRef image = [UIImage imageNamed:file].CGImage;
  GLuint returnTexture;
  GLuint width = CGImageGetWidth(image);
  GLuint height = CGImageGetHeight(image);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  void *imageData = malloc( height * width * 4 );
  CGContextRef imgcontext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
  CGColorSpaceRelease( colorSpace );
  CGContextClearRect( imgcontext, CGRectMake( 0, 0, width, height ) );
  CGContextTranslateCTM( imgcontext, 0, height - height );
  CGContextDrawImage( imgcontext, CGRectMake( 0, 0, width, height ), image );
  
  
  glGenTextures(1, &returnTexture);
  glBindTexture(GL_TEXTURE_2D, returnTexture);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height,
               0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	glBindTexture(GL_TEXTURE_2D, 0);
  
  free(imageData);
  CGContextRelease(imgcontext);
  
  [textures_ setValue:@(returnTexture) forKey:file];
  
  return returnTexture;
}

- (void)loadMeshAtFile:(NSString *)file {
  NSString* path = [[NSBundle mainBundle] pathForResource:file
                                                   ofType:@"mdl"];
  NSData* fileData = [NSData dataWithContentsOfFile:path];
  double *vertexBuffer = (double *)fileData.bytes;
  int arrayCount = ceilf(fileData.length / (float)sizeof(double));
  GLfloat floatArray[arrayCount];
  for (int i = 0 ; i < arrayCount; i++)
  {
    floatArray[i] = (float) vertexBuffer[i];
  }
  
  //  To Do!
  //  Add dynamic header to file export.
  //  Number of components, lenght, ect.
  
  GLuint newVertexArray;
  GLuint newVertexBuffer;
  
  glGenVertexArraysOES(1, &newVertexArray);
  glBindVertexArrayOES(newVertexArray);
  
  glGenBuffers(1, &newVertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, newVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(floatArray), &floatArray, GL_STATIC_DRAW);
  
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(GLfloat), BUFFER_OFFSET(0));
  glEnableVertexAttribArray(GLKVertexAttribNormal);
  glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(GLfloat), BUFFER_OFFSET(12));
  glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
  glVertexAttribPointer(GLKVertexAttribTexCoord0, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(GLfloat), BUFFER_OFFSET(24));
  
  glBindVertexArrayOES(0);
  
  BWMesh *newMesh = [[BWMesh alloc] init];
  newMesh.name = file;
  newMesh.vertexArray = newVertexArray;
  newMesh.vertexBuffer = newVertexBuffer;
  newMesh.vertexCount = arrayCount / 9;
  [meshes_ setObject:newMesh forKey:file];
  [newMesh release];
}

- (void)setupGL {
  [EAGLContext setCurrentContext:self.context];
  
  //Load Up Shaders. This is clunky, but hopefully will change.
  NSDictionary *uniforms = @{@"modelViewMatrix": @"uniformModelMatrix",
                             @"normalMatrix" : @"uniformNormalMatrix",
                             @"textureOffset" : @"uniformTextureUV",
                             @"cameraLocationMatrix" : @"uniformCameraLocationMatrix",
                             @"cameraProjectionMatrix" : @"uniformCameraProjectionMatrix",
                             @"diffuseColor" : @"uniformDiffuse",
                             @"light1" : @"uniformLight1",
                             @"light1On" : @"uniformLight1On",
                             @"light2" : @"uniformLight2",
                             @"light2On" : @"uniformLight2On"};
  
  NSDictionary *attributes = @{@"position": @(GLKVertexAttribPosition),
                               @"normal" : @(GLKVertexAttribNormal),
                               @"texture" : @(GLKVertexAttribTexCoord0)};
  
  [self loadShaderNamed:@"Shader" withVertexAttributes:attributes andUniforms:uniforms];
  
  [self loadShaderNamed:@"LineShader" withVertexAttributes:@{@"position" : @(GLKVertexAttribPosition), @"color" : @(GLKVertexAttribColor)}
            andUniforms:@{@"modelViewMatrix": @"uniformModelMatrix", @"cameraLocationMatrix" : @"uniformCameraLocationMatrix", @"cameraProjectionMatrix" : @"uniformCameraProjectionMatrix"}];
  
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D);
  [self loadDebugMesh:normalVertices withSize:sizeof(normalVertices)];
  [self loadDebugMesh:gridLine withSize:sizeof(gridLine)];
  
  
  glEnable(GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glShadeModel (GL_SMOOTH);
  [self loadTextureNamed:@"test.png"];
  
}

- (void)loadDebugMesh:(GLfloat[])mesh withSize:(size_t)size {
  //  return;
  GLuint newVertexArray;
  GLuint newVertexBuffer;
  
  glGenVertexArraysOES(1, &newVertexArray);
  glBindVertexArrayOES(newVertexArray);
  
  glGenBuffers(1, &newVertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, newVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, size, mesh, GL_STATIC_DRAW);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), BUFFER_OFFSET(0));
  glEnableVertexAttribArray(GLKVertexAttribColor);
  glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), BUFFER_OFFSET(12));
  
  BWMesh *normalMesh = [[BWMesh alloc] init];
  normalMesh.vertexArray = newVertexArray;
  normalMesh.vertexBuffer = newVertexBuffer;
  normalMesh.vertexCount = ((size / sizeof(GLfloat)) / 2) / 3;
  [debugGeometry_ addObject:normalMesh];
  [normalMesh release];
  
  glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
  [EAGLContext setCurrentContext:self.context];
  for (NSString *key in meshes_) {
    BWMesh *mesh = [meshes_ objectForKey:key];
    GLuint vertexBuffer = mesh.vertexBuffer;
    GLuint vertexArray = mesh.vertexArray;
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteVertexArraysOES(1, &vertexArray);
    [meshes_ removeObjectForKey:key];
  }
  for (BWShaderObject *shader in shaders_.allValues) {
    if (shader.shaderProgram) {
      glDeleteProgram(shader.shaderProgram);
      shader.shaderProgram = 0;
    }
  }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaderNamed:(NSString *)name withVertexAttributes:(NSDictionary *)attributes andUniforms:(NSDictionary *)uniforms {
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
  
    BWShaderObject *newShader = [[BWShaderObject alloc] init];
    // Create shader program.
    newShader.shaderProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
  
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(newShader.shaderProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(newShader.shaderProgram, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
  for (NSString *attribue in attributes) {
    glBindAttribLocation(newShader.shaderProgram, [[attributes valueForKey:attribue] integerValue], [attribue UTF8String]);
  }
    
    
    // Link program.
    if (![self linkProgram:newShader.shaderProgram]) {
        NSLog(@"Failed to link program: %d", newShader.shaderProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (newShader.shaderProgram) {
            glDeleteProgram(newShader.shaderProgram);
            newShader.shaderProgram = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
  
  for (NSString *uniformKey in uniforms.allKeys) {
    int uniform = glGetUniformLocation(newShader.shaderProgram, [uniformKey UTF8String]);
    [newShader setValue:@(uniform) forKey:[uniforms objectForKey:uniformKey]];
  }
  
    if (vertShader) {
        glDetachShader(newShader.shaderProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(newShader.shaderProgram, fragShader);
        glDeleteShader(fragShader);
    }
  [shaders_ setObject:newShader forKey:name];
  [newShader release];
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
  
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
