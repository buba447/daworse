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

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define ARC4RANDOM_MAX      0x100000000
GLfloat gCubeVertexData[324] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,    textcoor x y z
  
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,        1.0f, 1.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,        1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.0f, 1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,        0.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,        1.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,       0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,         1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,        0.0f, 0.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,         1.0f, 1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,        1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,        0.0f, 1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,        1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,        0.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,        1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,      1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,        0.0f, 1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,       0.0f, 1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,        1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,        0.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,         1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,         0.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,         1.0f, 1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        1.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,        0.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,        0.0f, 1.0f, 0.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,         1.0f, 1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,         0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,       0.0f, 1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,         1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f,        0.0f, 0.0f, 0.0f
};

@interface ViewController () {
  BOOL anaglyph_;
  CGPoint _rotation;
  float _rotationDistance;
  float _textTrans;
  GLuint _texture;
  GLuint _texture2;
  GLuint _vertexArray;
  GLuint _vertexBuffer;
  
  BWCameraObject *mainCamera_;
  BWShaderObject *currentShader_;
  NSMutableArray *models_;
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
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
  _rotation = CGPointZero;
  _rotationDistance = 0;
  
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
  mainCamera_.posY = 20;
  UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [newButton addTarget:self action:@selector(addCube) forControlEvents:UIControlEventTouchUpInside];
  newButton.frame = CGRectMake(0, 0, 100, 44);
  [self.view addSubview:newButton];
  heroModel_ = [[BWModelObject alloc] init];
  heroModel_.vertexArray = _vertexArray;
  heroModel_.shader = currentShader_;
//  heroModel_.texture = _texture;
  heroModel_.uvOffset = CGPointZero;
  [heroModel_ addChild:mainCamera_];
  [models_ addObject:heroModel_];
  [self setupWorld];
  BWWorldTimeManager *time = [BWWorldTimeManager sharedManager];
  time.currentTime = 0;
}

- (void)setupWorld {
  for (int i = 0; i < 100; i ++) {
    BWModelObject *newModel = [[BWModelObject alloc] init];
    newModel.vertexArray = _vertexArray;
    newModel.shader = currentShader_;
    newModel.texture = _texture;
    newModel.rotX = i * 2;
    newModel.rotY = i - 10;
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
  BWModelObject *newCube2 = [models_ objectAtIndex:1];
  [newCube2 addAnimationKeyForProperty:@"posX" toValue:4.2 duration:2.5];
  [newCube2 addAnimationKeyForProperty:@"posX" toValue:1.2 duration:1.5];
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

- (void)loadTexture:(CGImageRef)image {
  
  GLuint width = CGImageGetWidth(image);
  GLuint height = CGImageGetHeight(image);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  // Allocate memory for image
  void *imageData = malloc( height * width * 4 );
  CGContextRef imgcontext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
  CGColorSpaceRelease( colorSpace );
  CGContextClearRect( imgcontext, CGRectMake( 0, 0, width, height ) );
  CGContextTranslateCTM( imgcontext, 0, height - height );
  CGContextDrawImage( imgcontext, CGRectMake( 0, 0, width, height ), image );
  
  
  glGenTextures(1, &_texture);
  glBindTexture(GL_TEXTURE_2D, _texture);
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
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
  
    [self loadShaders];

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
  
    glEnable(GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glShadeModel (GL_SMOOTH);
  
  
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
  
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(GLfloat), BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(GLfloat), BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(GLfloat), BUFFER_OFFSET(24));
  
    glBindVertexArrayOES(0);
  
  [self loadTexture:[UIImage imageNamed:@"photo_selected.png"].CGImage];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    if (currentShader_.shaderProgram) {
        glDeleteProgram(currentShader_.shaderProgram);
        currentShader_.shaderProgram = 0;
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
    if (mocel != heroModel_) {
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
  _textTrans += self.timeSinceLastUpdate *0.2f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
  glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  for (BWModelObject *model in models_) {

    glBindVertexArrayOES(model.vertexArray);
    glUseProgram(model.shader.shaderProgram);
    glBindTexture(GL_TEXTURE_2D, model.texture);
    glUniformMatrix4fv(model.shader.uniformModelMatrix, 1, 0, GLKMatrix4Multiply(mainCamera_.currentTransform, model.currentTransform).m);
    glUniformMatrix3fv(model.shader.uniformNormalMatrix, 1, 0, model.normalMatrix.m);
    glUniformMatrix4fv(model.shader.uniformCameraMatrix, 1, 0, mainCamera_.projectionMatrix.m);
    glUniform2f(model.shader.uniformTextureUV, model.uvOffset.x, model.uvOffset.y);
    glDrawArrays(GL_TRIANGLES, 0, (sizeof(gCubeVertexData) / (9 * sizeof(GLfloat))));
    glBindTexture(GL_TEXTURE_2D, 0);
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
