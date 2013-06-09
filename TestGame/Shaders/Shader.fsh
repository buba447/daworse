//
//  Shader.fsh
//  TestGame
//
//  Created by Brandon Withrow on 6/8/13.
//  Copyright (c) 2013 Brandon Withrow. All rights reserved.
//

varying lowp vec4 colorVarying;
uniform sampler2D texture;

void main()
{
    gl_FragColor = colorVarying;
}
