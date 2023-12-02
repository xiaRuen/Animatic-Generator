/*
  A Sprite class for sprite. A Sprite is defined as follows:
 - Only contian the basic attributes of name, shape, position, rotation
 - Any additional funcitonality like effects or animaiton will be done
 by adding components to the sprite
 - the speacial case of renderIntermediate is for rendering to a intermediate
 PGraphics object, which we can then apply an layer of whole screen shader effect
 
 */

class Sprite {
  public String name;
  private PShape spriteShape;
  private PVector pos;
  private Float rad;

  // Components
  Phyiscs phyiscs;
  Effect effect;

  Sprite(String name, PShape spriteShape, float posX, float posY, float rad) {
    this.name = name;
    this.spriteShape = spriteShape;
    this.pos = new PVector(posX, posY);
    this.rad = rad;
  }


  public void render() {
    // physics
    if (phyiscs != null) {
      phyiscs.update();
    }

    pushMatrix(); // perhaps switching to push (pushes style and translations) in the future?

    // translations
    translate(pos.x, pos.y);
    rotate(rad);

    // effect
     if (effect != null) {
      if (millis() / 1000.0 - effect.birthTime > effect.duration) {
        system.logMessage("Effect is removed for sprite " + name);
        effect = null;
      } else {
        effect.apply();
      }
    }
    shape(spriteShape);

    popMatrix();
  }
}


class Phyiscs {
  private Sprite s;

  private PVector vel; //velocity
  private PVector acc; //acceleration
  
  // angluar equivelants
  private float aVel;
  private float aAcc;

  private int derivativeOfPos; // how many deravitives of position are we going at?



  Phyiscs(Sprite s, PVector vel, float aVel) {
    this.s = s;
    derivativeOfPos = 1;
    this.vel = vel;
    this.aVel = aVel;
  }
  Phyiscs(Sprite s, PVector vel, float aVel, PVector acc, float aAcc) {
    this.s = s;
    derivativeOfPos = 2;
    this.vel = vel;
    this.aVel = aVel;
    this.acc = acc;
    this.aAcc = aAcc;
  }

  public void update() {
    if (derivativeOfPos >= 2) {
      vel.add(PVector.mult(acc, elapsedTime));
      aVel += aAcc * elapsedTime;
    }
    if (derivativeOfPos >= 1) {
      s.pos.add(PVector.mult(vel, elapsedTime));
      s.rad += aVel * elapsedTime;
    }
  }
}


/* 
  A component for the Sprite class, where it is called inside Sprite::render

  vec4 params:
    Scale: initial scale, end scale
*/
class Effect {
  Sprite sprite;
  int type;
  float duration;
  float vec4[];

  float birthTime;

  Effect(Sprite sprite, int type, float duration, float vec4[]) {
    this.sprite = sprite;
    this.type = type;
    this.duration = duration;
    this.vec4 = vec4;

    birthTime = millis() / 1000.0;
  }

  void apply(){
    float lerpFactor = (millis() / 1000.0 - birthTime) / duration;
    
    switch(type){
    case 1:
      // scale
       scale(lerp(vec4[0],vec4[1],lerpFactor));  
    break;
  }

  }
  
}
