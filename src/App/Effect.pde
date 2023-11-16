/* 
  A component for the Sprite class, where it is called inside Sprite::render
*/
class Effect {
  int type;
  float duration;
  float vec4[];

  float birthTime;

  Effect(int type, float duration, float vec4[]) {
    this.type = type;
    this.duration = duration;
    this.vec4 = vec4;

    birthTime = millis() / 1000.0;
  }

  /*
  sets the type and its relating variables. Every effect will have a non zero
  type, and update the variables associating with the type, therefore, no need
  to reset uniforms after done when reusing the general shader.
  */
  void setUniforms() {
    float x = (millis() / 1000.0 - birthTime);
    switch(type) {

      // flash
    case 1:
      // f(x) = 1 - ((x-d/2) / (0.5d))²
      // where d is duration
      generalShader.set("type", 1);
      generalShader.set("y", 1.0 - pow((x - 0.5 * duration)/(0.5 * duration), 2));
      generalShader.set("target", vec4[0], vec4[1], vec4[2], vec4[3]);
      break;

      // flashInvert
    case 2:
      // f(x) = ((x-d/2) / (0.5d))²
      // where d is duration
      generalShader.set("type", 1);
      generalShader.set("y", pow((x - 0.5 * duration)/(0.5 * duration), 2));
      generalShader.set("target", vec4[0], vec4[1], vec4[2], vec4[3]);
      break;

      // pixelate
    case 3:
      generalShader.set("type", 2);
      // 0.1 → 10, int(0.1542 * 10) / 10.0 = 0.1
      generalShader.set("y", 1/vec4[0]);
      break;

    }
  }
}
