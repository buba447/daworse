attribute vec4 position;
attribute vec4 color;

varying lowp vec4 colorVarying;

uniform mat4 modelViewMatrix;
uniform mat4 cameraLocationMatrix;
uniform mat4 cameraProjectionMatrix;

void main()
{
  colorVarying = color;
  colorVarying[3] = 1.0;
  gl_Position = cameraProjectionMatrix * cameraLocationMatrix * modelViewMatrix * position;
}