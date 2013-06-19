attribute vec4 position;
attribute vec4 color;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 cameraMatrix;

void main()
{
  colorVarying = color;
  colorVarying[3] = 1.0;
  gl_Position = cameraMatrix * modelViewProjectionMatrix * position;
}