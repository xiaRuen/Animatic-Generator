/*
  The Particle System was originaly made to be used with openGL, therefore data
  is sotred in buffer array.
 */
class ParticleSystem {
  float birthTime;
  float previousTime;
  float bufferDataArray[];
  float duration;
  int stride; // how many floats per particle

  ParticleSystem() {
    birthTime = millis() / 1000.0;
    previousTime = birthTime; 

    // parameters
    duration = 10.0;
    int particleCount = 5000;

    float particleSize = 10;
    float deltaParticleSize = 1;

    PVector particleLocation = new PVector(960, 540);
    PVector deltaParticleLocaiton = new PVector(200, 100); //location range 

    PVector particleVelocity = new PVector(100, 100);
    PVector deltaParticleVelocity = new PVector(40, 40);

    PVector particleAcceleration = new PVector(-20, -20);
    PVector deltaParticleAcceleration = new PVector(20, 20);


    stride = 7;
    bufferDataArray = new float[particleCount * stride];

    int arrayIndex = 0;
    for (int i = 0; i < particleCount; i++) {

      // pos(2)
      bufferDataArray[arrayIndex++] = particleLocation.x + deltaParticleLocaiton.x * randomGaussian();
      bufferDataArray[arrayIndex++] = particleLocation.y + deltaParticleLocaiton.y * randomGaussian();

      // vel(2)
      bufferDataArray[arrayIndex++] = particleVelocity.x + deltaParticleVelocity.x * randomGaussian();
      bufferDataArray[arrayIndex++] = particleVelocity.y + deltaParticleVelocity.x * randomGaussian();

      // acc(2)
      bufferDataArray[arrayIndex++] = particleAcceleration.x + deltaParticleAcceleration.x * randomGaussian();
      bufferDataArray[arrayIndex++] = particleAcceleration.y + deltaParticleAcceleration.y * randomGaussian();

      // size(1)
      bufferDataArray[arrayIndex++] = particleSize + deltaParticleSize * randomGaussian();
    }


  }

  void run() {
    float elapsedTime = millis() / 1000.0 - previousTime;
    float cap = bufferDataArray.length * (millis() / 1000.0 - birthTime) / duration;

    for(int i = 0; i < cap; i += stride){
      // update velocity
      bufferDataArray[i+2] += bufferDataArray[i+4] * elapsedTime;
      bufferDataArray[i+3] += bufferDataArray[i+5] * elapsedTime;

      // update position
      bufferDataArray[i+0] += bufferDataArray[i+2] * elapsedTime;
      bufferDataArray[i+1] += bufferDataArray[i+3] * elapsedTime;

      // draw
      circle(bufferDataArray[i],bufferDataArray[i+1],bufferDataArray[i+6]);
    }

    previousTime = millis() / 1000.0;
  }
}
