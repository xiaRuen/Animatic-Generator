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

  // for effect
  private float scaleFactor;
  private color renderColor;

  // Components
  Phyiscs phyiscs;
  ArrayList<Effect> effects;

  Sprite(String name, PShape spriteShape, float posX, float posY, float rad) {
    this.name = name;
    this.spriteShape = spriteShape;
    this.pos = new PVector(posX, posY);
    this.rad = rad;
    effects = new ArrayList<Effect>();

    scaleFactor = 1;
    renderColor = color(4,0,4); // some magic value

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
    if (effects.size() != 0) {
      for(int i = 0; i < effects.size(); i++){
        Effect effect = effects.get(i);
        if (effect.duration != -1 && millis() / 1000.0 - effect.birthTime > effect.duration) {
        system.logMessage("Effect is removed for sprite " + name);
        effects.remove(i);
        scaleFactor = 1;
        renderColor = color(4,0,4);
        i--; // don't skip an effect due to deletion
      } else {
        effect.apply();
      }
      }
      
    }

    if(spriteShape != null){
      
      if(renderColor != color(4,0,4)){
        spriteShape.setFill(renderColor);
      }
      scale(scaleFactor);
      shape(spriteShape);
    } else {
      textSize(10 * scaleFactor);
      if(renderColor != color(4,0,4)){
        fill(renderColor);
      }
      text(name.replace('_', ' '), 0, 0);
      fill(textColor);
    }


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
  float params[];

  float birthTime;

  // it is the system's job to ensure that all required params are provided
  Effect(Sprite sprite, int type, float duration, float params[]) {
    this.sprite = sprite;
    this.type = type;
    this.duration = duration;
    this.params = params;

    birthTime = millis() / 1000.0;
  }

  void apply() {
    float lerpFactor;
    if(duration != -1){
      lerpFactor = (millis() / 1000.0 - birthTime) / duration;
    } else {
      lerpFactor = 0;
    }
    

    switch(type) {
    case 1:
      // scale
      sprite.scaleFactor = (lerp(params[0], params[1], lerpFactor));
      break;
    case 2:
      // color
      sprite.renderColor = lerpColor(
        color(params[0], params[1], params[2]),
        color(params[3], params[4], params[5]),
        lerpFactor);
      break;
    }
  }
}
