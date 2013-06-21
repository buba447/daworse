//
//  Shader.vsh
//  TestGame
//
//  Created by Brandon Withrow on 6/8/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec4 texture;

varying lowp vec4 colorVarying;
varying lowp vec4 textureVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 cameraMatrix;
uniform mat3 normalMatrix;
uniform vec2 textureOffset;
uniform vec4 diffuseColor;
void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(2.0, 1.0, 0.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
  nDotVP = nDotVP + 0.1;
    colorVarying = diffuseColor * nDotVP;
    colorVarying[3] = 1.0;
    
    textureVarying = texture ;
    gl_Position = cameraMatrix * modelViewProjectionMatrix * position;
}
