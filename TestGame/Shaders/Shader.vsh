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

uniform mat4 modelViewMatrix;
uniform mat4 cameraLocationMatrix;
uniform mat4 cameraProjectionMatrix;
uniform mat3 normalMatrix;


varying lowp vec4 colorVarying;
varying lowp vec4 lightVarying;
varying lowp vec4 textureVarying;
precision mediump float;
uniform int light1On;
uniform int light2On;
uniform int light3On;
uniform int light4On;
uniform int hasTexture;
uniform mat4 light1;
uniform mat4 light2;
uniform mat4 light3;
uniform mat4 light4;
uniform vec2 textureOffset;
uniform vec4 diffuseColor;

void main() {
  vec3 eyeNormal = normalize(normalMatrix * normal);
  
  vec3 worldPointPosition = (modelViewMatrix * position).xyz;
  
  //Light 1
  vec3 lightVector1 =  light1[0].xyz - worldPointPosition;
  vec3 normalLight1 = normalize(lightVector1);
  float coneDot1 = dot(light1[1].xyz, -normalLight1);
  float inCone1 = min(ceil(coneDot1 - light1[3].y), 1.0);
  float anglePercent1 =  max(min((coneDot1 - light1[3].y) / 0.05, 1.0), 0.0);
  float nDotL1 = (max(0.0, dot(eyeNormal, normalLight1)) * light1[3].x *
                  max(((light1[3].z - length(lightVector1)) / light1[3].z), 0.0) *
                  anglePercent1 * inCone1 * float(light1On));
  vec4 light1Color = (nDotL1 * light1[2]);

  //Light 2
  vec3 lightVector2 =  light2[0].xyz - worldPointPosition;
  vec3 normalLight2 = normalize(lightVector2);
  float coneDot2 = dot(light2[1].xyz, -normalLight2);
  float inCone2 = min(ceil(coneDot2 - light2[3].y), 1.0);
  float anglePercent2 =  max(min((coneDot2 - light2[3].y) / 0.05, 1.0), 0.0);
  float nDotL2 = (max(0.0, dot(eyeNormal, normalLight2)) * light2[3].x *
                  max(((light2[3].z - length(lightVector2)) / light2[3].z), 0.0) *
                  anglePercent2 * inCone2 * float(light2On));
  vec4 light2Color = (nDotL2 * light2[2]);
  
  lightVarying = (light1Color + light2Color);
  lightVarying[3] = 1.0;
  colorVarying = diffuseColor;
  colorVarying[3] = 1.0;
  
  textureVarying = texture;
  gl_Position = cameraProjectionMatrix * cameraLocationMatrix * modelViewMatrix * position;
}
