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
    if (effect != null) {
      if (millis() / 1000.0 - effect.birthTime > effect.duration) {
        system.logMessage("Effect is removed for sprite " + name);
        effect = null;
      } else {
        // work to be done
      }
    }


    if (phyiscs != null) {
      phyiscs.update(this);
    }


    pushMatrix();

    // translations
    translate(pos.x, pos.y);
    rotate(rad);
    // draw
    shape(spriteShape, 0, 0);
    fill(0);

    popMatrix();
  }
}
