class Phyiscs {
  private PVector vel; //velocity
  private PVector acc; //acceleration
  
  // angluar equivelants
  private float aVel;
  private float aAcc;

  private int derivativeOfPos; // how many deravitives of position are we going at?



  Phyiscs(PVector vel, float aVel) {
    derivativeOfPos = 1;
    this.vel = vel;
    this.aVel = aVel;
  }
  Phyiscs(PVector vel, float aVel, PVector acc, float aAcc) {
    derivativeOfPos = 2;
    this.vel = vel;
    this.aVel = aVel;
    this.acc = acc;
    this.aAcc = aAcc;
  }

  public void update(Sprite s) {
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
