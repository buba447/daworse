//
//  Shader.fsh
//  TestGame
//
//  Created by Brandon Withrow on 6/8/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//
precision mediump float;
varying vec4 textureVarying;
varying lowp vec4 colorVarying;
uniform sampler2D texture;
uniform vec2 textureOffset;

void main()
{  
  vec4 mixed = colorVarying + texture2D(texture, textureVarying.xy);
    gl_FragColor = mixed;
}
