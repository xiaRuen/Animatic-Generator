#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform int type;
uniform float y;
uniform vec4 target;
uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {

  // if texture is null, vertColor * texture will be 0
  if(texture2D(texture, vertTexCoord.st) == vec4(0, 0, 0, 1)) {
    gl_FragColor = vertColor;
    return;
  }

  // default do nothing
  if(type == 0) {
    gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
  }

  // fade
  else if(type == 1) {
    vec4 oldVertColor = texture2D(texture, vertTexCoord.st) * vertColor;
    gl_FragColor = oldVertColor + (target - oldVertColor) * y;
  }

  // pixelate
  else if(type == 2) {
    float s = float(int(vertTexCoord.x * y)) / y;
    float t = float(int(vertTexCoord.y * y)) / y;
    gl_FragColor = texture2D(texture, vec2(s, t)) * vertColor;
  }

}
