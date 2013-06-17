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

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define ARC4RANDOM_MAX      0x100000000

@interface ViewController () {
  BOOL anaglyph_;
  CGPoint _rotation;
  float _rotationDistance;
  float _textTrans;

  BWCameraObject *mainCamera_;
  BWShaderObject *currentShader_;
  NSMutableArray *meshes_;
  NSMutableArray *models_;
  NSDictionary *textures_;
  BWModelObject *heroModel_;
}

@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  anaglyph_ = NO;
  _rotation = CGPointZero;
  _rotationDistance = 0;
  meshes_ = [[NSMutableArray alloc] init];
  textures_ = [[NSMutableDictionary alloc] init];
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

  if (!self.context) {
      NSLog(@"Failed to create ES context");
  }
  
  GLKView *view = (GLKView *)self.view;
  view.context = self.context;
  view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
  UIPanGestureRecognizer *peterPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
  [self.view addGestureRecognizer:peterPan];
  
  [self setupGL];
  
  models_ = [[NSMutableArray alloc] init];
  mainCamera_ = [[BWCameraObject alloc] init];
//  mainCamera_.posZ = 10;
  mainCamera_.rotX = -90;
  mainCamera_.posY = 10;
  UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [newButton addTarget:self action:@selector(addCube) forControlEvents:UIControlEventTouchUpInside];
  newButton.frame = CGRectMake(0, 0, 100, 44);
  [self.view addSubview:newButton];
  heroModel_ = [[BWModelObject alloc] init];
  heroModel_.mesh = [meshes_ objectAtIndex:0];
  heroModel_.shader = currentShader_;
  heroModel_.texture = 0;
  heroModel_.scaleX = 1.5;
  heroModel_.scaleY = 1.5;
  heroModel_.scaleZ = 1.5;
  heroModel_.diffuseColor = GLKVector4Make(0.3, 0.45, 0.6, 1);
  heroModel_.uvOffset = CGPointZero;
  [heroModel_ addChild:mainCamera_];
  [models_ addObject:heroModel_];
  
  BWModelObject *leftJet = [[BWModelObject alloc] init];
  leftJet.shader = currentShader_;
  leftJet.mesh = [meshes_ objectAtIndex:2];
  leftJet.uvOffset = CGPointZero;
  leftJet.hidden = YES;

  [heroModel_ addChild:leftJet];
  [models_ addObject:leftJet];
  
  BWModelObject *rightJet = [[BWModelObject alloc] init];
  rightJet.shader = currentShader_;
  rightJet.mesh = [meshes_ objectAtIndex:3];
  rightJet.uvOffset = CGPointZero;
  rightJet.hidden = YES;
  [heroModel_ addChild:rightJet];
  [models_ addObject:rightJet];
  
  [leftJet release];
  [rightJet release];
  
  [self setupWorld];
  BWWorldTimeManager *time = [BWWorldTimeManager sharedManager];
  time.currentTime = 0;
}



- (void)dealloc
{    
    [self tearDownGL];
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

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
  glBufferData(GL_ARRAY_BUFFER, sizeof(floatArray), floatArray, GL_STATIC_DRAW);
  
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
  [meshes_ addObject:newMesh];
  [newMesh release];
}

- (void)setupGL {
  [EAGLContext setCurrentContext:self.context];

  [self loadShaders];

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D);
  [self loadMeshAtFile:@"ship3"];
  [self loadMeshAtFile:@"testExport2"];
  [self loadMeshAtFile:@"leftJet"];
  [self loadMeshAtFile:@"rightJet2"];
  glEnable(GL_BLEND);
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glShadeModel (GL_SMOOTH);
  [self loadTextureNamed:@"photo_selected.png"];

}

- (void)tearDownGL
{
  [EAGLContext setCurrentContext:self.context];
  for (BWMesh *mesh in meshes_) {
    GLuint vertexBuffer = mesh.vertexBuffer;
    GLuint vertexArray = mesh.vertexArray;
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteVertexArraysOES(1, &vertexArray);
    [meshes_ removeObject:mesh];
  }
  if (currentShader_.shaderProgram) {
      glDeleteProgram(currentShader_.shaderProgram);
      currentShader_.shaderProgram = 0;
  }
}

- (void)setupWorld {
  for (int i = 0; i < 200; i ++) {
    BWModelObject *newModel = [[BWModelObject alloc] init];
//    newMod el.vertexArray = _vertexArray;
    newModel.mesh = [meshes_ objectAtIndex:1];
    newModel.shader = currentShader_;
    newModel.rotX = i * 2;
    newModel.rotY = i - 10;
    newModel.scaleX = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 2.0f) + 0.5;
    newModel.scaleY = newModel.scaleX;
    newModel.scaleZ = newModel.scaleX;
    newModel.diffuseColor = GLKVector4Make(0.5, 0.4, 0.3, 1);
    newModel.uvOffset = CGPointZero;
    newModel.posX = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 80.0f) - 40;
    newModel.posZ = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 80.0f) - 40;
    [models_ addObject:newModel];
  }
}

- (void)addCube {
  BWModelObject *newCube = [models_ objectAtIndex:0];
  [newCube removeAllAnimationKeys];
  [newCube addAnimationKeyForProperty:@"posY" toValue:6 duration:2];
  [newCube addAnimationKeyForProperty:@"posY" toValue:-6 duration:2];
  [newCube addAnimationKeyForProperty:@"posY" toValue:0 duration:1];
  //  [newCube addAnimationKeyForProperty:@"posY" toValue:6 duration:2];
  //  [newCube addAnimationKeyForProperty:@"posY" toValue:-6 duration:2];
  //  [newCube addAnimationKeyForProperty:@"posY" toValue:0 duration:1];
  //  [newCube addAnimationKeyForProperty:@"rotX" toValue:180 duration:2 delay:1];
  //  [newCube addAnimationKeyForProperty:@"rotX" toValue:0 duration:2];
  [newCube addAnimationKeyForProperty:@"rotZ" toValue:90 duration:0.3 delay:0];
  [newCube addAnimationKeyForProperty:@"rotZ" toValue:0 duration:2 delay:1];
//  BWModelObject *newCube2 = [models_ objectAtIndex:1];
//  [newCube2 addAnimationKeyForProperty:@"posX" toValue:4.2 duration:2.5];
//  [newCube2 addAnimationKeyForProperty:@"posX" toValue:1.2 duration:1.5];
}


- (void)handlePan:(UIPanGestureRecognizer *)gesture {
  CGPoint translation = [gesture translationInView:self.view];
  _rotation.y = translation.y / (self.view.bounds.size.height * 0.5);
  _rotation.x = translation.x / (self.view.bounds.size.width * 0.5);
  _rotationDistance = sqrtf(pow(translation.x, 2) + pow(translation.y, 2)) / 100;
  if (gesture.state == UIGestureRecognizerStateEnded ||
      gesture.state == UIGestureRecognizerStateCancelled) {
    _rotation = CGPointZero;
  }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
  BWWorldTimeManager *time = [BWWorldTimeManager sharedManager];
  time.currentTime += self.timeSinceLastUpdate;
  float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
  mainCamera_.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), aspect, 0.1f, 100.0f);
  [models_ makeObjectsPerformSelector:@selector(updateForAnimation)];
//  NSLog(@"Gesture %f %f", _rotation.y, _rotation.x);
  for (BWModelObject *mocel in models_) {
    if (mocel != heroModel_ && ![heroModel_.children containsObject:mocel]) {
      mocel.rotZ += 3;
      mocel.rotY -= 5;
      mocel.rotX += 3;
    }
  }
  heroModel_.rotY -= (_rotation.x * 2);
  GLKVector3 vector = GLKVector3Make(0, 0, _rotation.y);
  GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(heroModel_.rotX), 1, 0, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(heroModel_.rotY), 0, 1, 0);
  rotation = GLKMatrix4Rotate(rotation, GLKMathDegreesToRadians(heroModel_.rotZ), 0, 0, 1);

  GLKVector3 transformed_direction = GLKMatrix4MultiplyVector3(rotation, vector);
  heroModel_.posZ += transformed_direction.z;
  heroModel_.posY += transformed_direction.y;
  heroModel_.posX += transformed_direction.x;
  

    if (fabs(_rotation.x) < 0.3 && (_rotation.y < 0)) {
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setHidden:NO];
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setScaleZ:(1 + _rotation.y * -1)];
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setDiffuseColor:GLKVector4Make((0.75 + _rotation.y * -0.75), (0.5 + _rotation.y * -0.25), fabsf(_rotation.y) - 0.5, fabsf(_rotation.y))];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setHidden:NO];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setDiffuseColor:GLKVector4Make((0.75 + _rotation.y * -0.75), (0.5 + _rotation.y * -0.25), fabsf(_rotation.y) - 0.5, fabsf(_rotation.y))];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setScaleZ:(1 + _rotation.y * -1)];
    } else if (_rotation.x < 0) {
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setHidden:YES];
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setScaleZ:1];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setHidden:NO];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setScaleZ:(1 + fabs(_rotation.x))];
    } else if (_rotation.x > 0) {
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setHidden:NO];
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setScaleZ:(1 + fabs(_rotation.x))];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setHidden:YES];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setScaleZ:1];
    } else {
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setHidden:YES];
      [(BWModelObject *)[heroModel_.children objectAtIndex:1] setScaleZ:1];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setHidden:YES];
      [(BWModelObject *)[heroModel_.children objectAtIndex:2] setScaleZ:1];
    }
  _textTrans += self.timeSinceLastUpdate *0.2f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
  glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  for (BWModelObject *model in models_) {
    if (model.hidden) {
      continue;
    }
    glBindVertexArrayOES(model.mesh.vertexArray);
    glUseProgram(model.shader.shaderProgram);
    glBindTexture(GL_TEXTURE_2D, model.texture);
    glUniformMatrix4fv(model.shader.uniformModelMatrix, 1, 0, GLKMatrix4Multiply(mainCamera_.currentTransform, model.currentTransform).m);
    glUniformMatrix3fv(model.shader.uniformNormalMatrix, 1, 0, model.normalMatrix.m);
    glUniformMatrix4fv(model.shader.uniformCameraMatrix, 1, 0, mainCamera_.projectionMatrix.m);
    glUniform2f(model.shader.uniformTextureUV, model.uvOffset.x, model.uvOffset.y);
    glUniform4f(model.shader.uniformDiffuse, model.diffuseColor.x, model.diffuseColor.y, model.diffuseColor.z, model.diffuseColor.w);
    glDrawArrays(GL_TRIANGLES, 0, model.mesh.vertexCount);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindVertexArrayOES(0);
  }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    currentShader_ = [[BWShaderObject alloc] init];
    // Create shader program.
    currentShader_.shaderProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
  
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(currentShader_.shaderProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(currentShader_.shaderProgram, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(currentShader_.shaderProgram, GLKVertexAttribPosition, "position");
    glBindAttribLocation(currentShader_.shaderProgram, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(currentShader_.shaderProgram, GLKVertexAttribTexCoord0, "texture");
  
    // Link program.
    if (![self linkProgram:currentShader_.shaderProgram]) {
        NSLog(@"Failed to link program: %d", currentShader_.shaderProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (currentShader_.shaderProgram) {
            glDeleteProgram(currentShader_.shaderProgram);
            currentShader_.shaderProgram = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
  currentShader_.uniformModelMatrix = glGetUniformLocation(currentShader_.shaderProgram, "modelViewProjectionMatrix");
  currentShader_.uniformNormalMatrix = glGetUniformLocation(currentShader_.shaderProgram, "normalMatrix");
  currentShader_.uniformTextureUV = glGetUniformLocation(currentShader_.shaderProgram, "textureOffset");
  currentShader_.uniformCameraMatrix = glGetUniformLocation(currentShader_.shaderProgram, "cameraMatrix");
  currentShader_.uniformDiffuse = glGetUniformLocation(currentShader_.shaderProgram, "diffuseColor");
  // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(currentShader_.shaderProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(currentShader_.shaderProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
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
