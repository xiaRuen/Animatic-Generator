/*
  Bypassing processing and directly using OpenGL to GPU compute the particles
 
 gl is defined to be the OpenGL interface in setup, similar to webGL
 */
class ParticleSystem {
  int shaderProgram;
  float birthTime;
  int totalVertices;

  ParticleSystem() {
    birthTime = millis() / 1000.0;

    // prepear vertexShader
    int vertexShader = gl.createShader(PGL.VERTEX_SHADER);
    gl.shaderSource(vertexShader, loadFile("shaders/particleVert.glsl"));
    gl.compileShader(vertexShader);

    // prepear fragmentShader
    int fragShader = gl.createShader(PGL.FRAGMENT_SHADER);
    gl.shaderSource(fragShader, loadFile("shaders/particleFrag.glsl"));
    gl.compileShader(fragShader);

    // createProgram
    int program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragShader);
    gl.linkProgram(program);

    // remove shaders
    gl.deleteShader(vertexShader);
    gl.deleteShader(fragShader);

    // check
    IntBuffer success = IntBuffer.allocate(1);
    gl.getProgramiv(program, PGL.LINK_STATUS, success);
    if (success.get() != 1) {
      //println("vertex shader: " + gl.getShaderInfoLog(vertexShader));
      println("fragment shader: " + gl.getShaderInfoLog(fragShader));
      exit();
    } else {
      // on successful creation of shader
      shaderProgram = program;
    }

    gl.useProgram(program);
    gl.clearColor(0, 0, 0, 0);


    // generate data (all maped to -1, 1)

    int particleCount = 50000;
    totalVertices = particleCount * 6;

    float particleSize = 0.001;
    float deltaParticleSize = 0.0004;

    PVector particleLocation = new PVector(0, 0);
    PVector deltaParticleLocaiton = new PVector(0.2, 0.2);

    PVector particleVelocity = new PVector(0, 0);
    PVector deltaParticleVelocity = new PVector(0.05, 0.05);

    PVector particleAcceleration = new PVector(0, 0);
    PVector deltaParticleAcceleration = new PVector(0.5, 0.5);

    PVector particleRotation = new PVector(0, 0, 0);
    PVector deltaParticleRotation = new PVector(0.5, 0.5, 0.5);

    PVector particleAngularVel = new PVector(0, 0, 0);
    PVector deltaParticleAngularVel = new PVector(0.2, 0.2, 0.2);

    PVector particleAngularAcc = new PVector(0, 0, 0);
    PVector deltaParticleAngularAcc = new PVector(0, 0, 0);


    // other boring datas
    int stride = 19; // how many float attributes per vertex
    // each particles is made up of two triangles, six vertex
    // six vertex because this version does not support drawInstances
    float bufferDataArray[] = new float[particleCount * stride * 6];
    int arrayIndex = 0;
    // for each particle, and each particle has six vertex
    for (int i = 0; i < particleCount; i++) {
      float size = particleSize + deltaParticleSize * randomGaussian();
      PVector pos = new PVector(particleLocation.x + deltaParticleLocaiton.x * randomGaussian(),
        particleLocation.y + deltaParticleLocaiton.y * randomGaussian());

      PVector vel = new PVector(particleVelocity.x + deltaParticleVelocity.x * randomGaussian(),
        particleVelocity.y + deltaParticleVelocity.y * randomGaussian());

      PVector acc = new PVector(particleAcceleration.x + deltaParticleAcceleration.x * randomGaussian(),
        particleAcceleration.y + deltaParticleAcceleration.y * randomGaussian());


      PVector rot = new PVector(particleRotation.x + deltaParticleRotation.x * randomGaussian(),
        particleRotation.y + deltaParticleRotation.y * randomGaussian());

      PVector aVel = new PVector(particleAngularVel.x + deltaParticleAngularVel.x * randomGaussian(),
        particleAngularVel.y + deltaParticleAngularVel.y * randomGaussian());

      PVector aAcc = new PVector(particleAngularAcc.x + deltaParticleAngularAcc.x * randomGaussian(),
        particleAngularAcc.y + deltaParticleAngularAcc.y * randomGaussian());



      // origin(2), texCoord(2), pos(2), vel(2), acc(2), rot(3), aVel(3), aAcc(3)
      for (int j = 0; j < 6; j++) {
        // origin(2)
        bufferDataArray[arrayIndex++] = pos.x;
        bufferDataArray[arrayIndex++] = pos.y;

        switch(j) {
          // texCoord(2), pos(2)
          // 1,-1,  -1,-1  -1,1  1,-1  -1,1  1,1
        case 0:
          bufferDataArray[arrayIndex++] = 1;
          bufferDataArray[arrayIndex++] = 0;
          bufferDataArray[arrayIndex++] = pos.x + size;
          bufferDataArray[arrayIndex++] = pos.y - size;
          break;
        case 1:
          bufferDataArray[arrayIndex++] = 0;
          bufferDataArray[arrayIndex++] = 0;
          bufferDataArray[arrayIndex++] = pos.x - size;
          bufferDataArray[arrayIndex++] = pos.y - size;
          break;
        case 2:
          bufferDataArray[arrayIndex++] = 0;
          bufferDataArray[arrayIndex++] = 1;
          bufferDataArray[arrayIndex++] = pos.x - size;
          bufferDataArray[arrayIndex++] = pos.y + size;
          break;
        case 3:
          bufferDataArray[arrayIndex++] = 1;
          bufferDataArray[arrayIndex++] = 0;
          bufferDataArray[arrayIndex++] = pos.x + size;
          bufferDataArray[arrayIndex++] = pos.y - size;
          break;
        case 4:
          bufferDataArray[arrayIndex++] = 0;
          bufferDataArray[arrayIndex++] = 1;
          bufferDataArray[arrayIndex++] = pos.x - size;
          bufferDataArray[arrayIndex++] = pos.y + size;
          break;
        case 5:
          bufferDataArray[arrayIndex++] = 1;
          bufferDataArray[arrayIndex++] = 1;
          bufferDataArray[arrayIndex++] = pos.x + size;
          bufferDataArray[arrayIndex++] = pos.y + size;
          break;
        }

        // vel(2)
        bufferDataArray[arrayIndex++] = vel.x;
        bufferDataArray[arrayIndex++] = vel.y;

        // acc(2)
        bufferDataArray[arrayIndex++] = acc.x;
        bufferDataArray[arrayIndex++] = acc.y;


        // rot(3)
        bufferDataArray[arrayIndex++] = rot.x;
        bufferDataArray[arrayIndex++] = rot.y;
        bufferDataArray[arrayIndex++] = rot.z;

        // aVel(3)
        bufferDataArray[arrayIndex++] = aVel.x;
        bufferDataArray[arrayIndex++] = aVel.y;
        bufferDataArray[arrayIndex++] = aVel.z;

        // aAcc(3)
        bufferDataArray[arrayIndex++] = aAcc.x;
        bufferDataArray[arrayIndex++] = aAcc.y;
        bufferDataArray[arrayIndex++] = aAcc.z;
      }
    }


    // create buffer and write data
    FloatBuffer arrayBufferData = FloatBuffer.wrap(bufferDataArray);
    IntBuffer arraybuffers = IntBuffer.allocate(1);
    gl.genBuffers(1, arraybuffers);
    gl.bindBuffer(PGL.ARRAY_BUFFER, arraybuffers.get(0));
    gl.bufferData(PGL.ARRAY_BUFFER, arrayIndex * 4, arrayBufferData, PGL.STATIC_DRAW);

    // vertexAttributePointers
    int aOriginLoc = gl.getAttribLocation(program, "aOrigin");
    int aTexCoordLoc = gl.getAttribLocation(program, "aTexCoord");
    int aPosLoc = gl.getAttribLocation(program, "aPos");
    int aVelLoc = gl.getAttribLocation(program, "aVel");
    int aAccLoc = gl.getAttribLocation(program, "aAcc");
    int aRadLoc = gl.getAttribLocation(program, "aRad");
    int aRadVelLoc = gl.getAttribLocation(program, "aRadVel");
    int aRadAccLoc = gl.getAttribLocation(program, "aRadAcc");

    // origin(2), texCoord(2), pos(2), vel(2), acc(2), rot(3), aVel(3), aAcc(3)
    gl.vertexAttribPointer(aOriginLoc, 2, PGL.FLOAT, false, stride*4, 0);
    gl.vertexAttribPointer(aTexCoordLoc, 2, PGL.FLOAT, false, stride*4, 2*4);
    gl.vertexAttribPointer(aPosLoc, 2, PGL.FLOAT, false, stride*4, 4*4);
    gl.vertexAttribPointer(aVelLoc, 2, PGL.FLOAT, false, stride*4, 6*4);
    gl.vertexAttribPointer(aAccLoc, 2, PGL.FLOAT, false, stride*4, 8*4);
    gl.vertexAttribPointer(aRadLoc, 3, PGL.FLOAT, false, stride*4, 10*4);
    gl.vertexAttribPointer(aRadVelLoc, 3, PGL.FLOAT, false, stride*4, 13*4);
    gl.vertexAttribPointer(aRadAccLoc, 3, PGL.FLOAT, false, stride*4, 16*4);

    gl.enableVertexAttribArray(aOriginLoc);
    gl.enableVertexAttribArray(aTexCoordLoc);
    gl.enableVertexAttribArray(aPosLoc);
    gl.enableVertexAttribArray(aVelLoc);
    gl.enableVertexAttribArray(aAccLoc);
    gl.enableVertexAttribArray(aRadLoc);
    gl.enableVertexAttribArray(aRadVelLoc);
    gl.enableVertexAttribArray(aRadAccLoc);


    // textures
    ByteBuffer textureData = ByteBuffer.wrap(loadBytes("blue-crystal.bin"));
    IntBuffer textureBuffers = IntBuffer.allocate(1);
    gl.genTextures(1, textureBuffers);

    // need to go before texImage2D to tell it where to write to
    gl.uniform1i(gl.getUniformLocation(program, "textureSampler"), 5);
    gl.activeTexture(PGL.TEXTURE0 + 5);

    gl.bindTexture(PGL.TEXTURE_2D, textureBuffers.get(0));
    gl.texImage2D(PGL.TEXTURE_2D, 0, PGL.RGBA, 1000, 1000, 0, PGL.RGBA, PGL.UNSIGNED_BYTE, textureData);
    gl.generateMipmap(PGL.TEXTURE_2D);

    // final settings
    gl.enable(PGL.DEPTH_TEST);
    //gl.enable(PGL.BLEND);
    //gl.blendFunc(PGL.SRC_ALPHA, PGL.ONE_MINUS_SRC_ALPHA);
  }

  void render() {
    gl.useProgram(shaderProgram);
    gl.uniform1f(gl.getUniformLocation(shaderProgram, "x"), millis() / 1000.0 - birthTime);
    gl.drawArrays(PGL.TRIANGLES, 0, totalVertices);
  }
}

void printBuffer(int bufferType) {
  FloatBuffer b = gl.mapBuffer(bufferType, PGL.READ_WRITE).asFloatBuffer();
  while (b.remaining() > 0) {
    print(b.get() + " ");
  }
  println();
}

String loadFile(String path) {
  return String.join("\n", loadStrings(path));
}
