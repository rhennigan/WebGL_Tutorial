attribute vec4 aVertexPosition;
attribute vec4 aVertexColor;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;
uniform vec4 uTVector;

varying vec4 vColor;

void main(void) {
  gl_Position = uPMatrix * uMVMatrix * (aVertexPosition + uTVector);
  vColor = aVertexColor;
}