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

}
