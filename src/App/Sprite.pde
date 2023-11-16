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

  public PGraphics renderIntermediate;

  // Components
  Phyiscs phyiscs;
  Effect effect;

  Sprite(String name, PShape spriteShape, float posX, float posY, float rad) {
    this.name = name;
    this.spriteShape = spriteShape;
    this.pos = new PVector(posX, posY);
    this.rad = rad;

    renderIntermediate = name.equals("screen") ? createGraphics(width, height, P2D) : screen.renderIntermediate;
  }


  public void render() {
    generalShader.set("type", 0);

    if (effect != null) {
      if (millis() / 1000.0 - effect.birthTime > effect.duration) {
        effect = null;
        generalShader.set("type", 0);
      } else {
        effect.setUniforms();
      }
    }

    if (phyiscs != null) {
      phyiscs.update(this);
    }

    // screen
    if (name.equals("screen")) {
      
      shader(generalShader);
      background(backgroundColor);
      image(renderIntermediate, 0, 0);

      renderIntermediate.beginDraw();
      renderIntermediate.background(backgroundColor);
      renderIntermediate.endDraw();
      

      
    }
    // regular sprites
    else {
      renderIntermediate.beginDraw();
      // translations (don't need to push and pop matrix as maybe beginDraw resets the origin?)
      renderIntermediate.translate(pos.x, pos.y);
      renderIntermediate.rotate(rad);
      // draw
      renderIntermediate.shader(generalShader);
      renderIntermediate.shape(spriteShape, 0, 0);

      renderIntermediate.endDraw();
    }

  }
}
