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
  vec2 mix = textureVarying.xy;
    mix.x += textureOffset.x;
    mix.y += textureOffset.y;
    if (mix.x > 1.0)
    mix.x = mix.x - floor(mix.x);
    if (mix.y > 1.0)
    mix.y = mix.y - floor(mix.y);
  vec4 textureCol = texture2D(texture, mix);
  
  vec4 mixed = colorVarying + textureCol;
    gl_FragColor = mixed;
}
