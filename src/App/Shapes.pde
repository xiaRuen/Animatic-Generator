PShape defaultShape() {
  PShape s;


  // the only complete compelex shape for this formula is a star
  // x: r*sin(PI*4/5*v+a)
  // y: r*cos(PI*4/5*v+a)
  // where r is radius, v is vertex count, a is angle offset
  s = createShape();
  s.beginShape();
  s.noStroke();
  s.fill(color(0,0,255,200));
  float r = 30;
  float a = 0;
  for (int v = 0; v < 5; v++) {
    float x = r*sin(PI*4/5*v+a);
    float y = r*cos(PI*4/5*v+a);
    s.vertex(x, y);
  }
  s.endShape(CLOSE);

  return s;
}


PShape cpuShape() {
  // control variables
  float coreRadius = 40; // radius of the cpu core
  float coreGap = 8; // used for density of the points
  float turningThreshold = 0.4; // the lower the less likely to turn
  int lineLength = 20; // length of each segment
  float turnRad = PI/4; // if turned, what's the turn angle
  float posTurnPosWeight = 4; // how much do we take account of the point's position



  // initialize points as in their starting positions
  float corePerimeter = coreRadius * 8;
  int totalLines = int(corePerimeter/coreGap);
  float points[][] = new float[totalLines][4];
  int index = 0;
  for (float x = -coreRadius; x < coreRadius; x += coreGap) {
    // up
    points[index][0] = x;
    points[index][1] = coreRadius;
    points[index][2] = x/coreRadius;
    points[index][3] = 0;
    // down
    points[index + totalLines/2][0] = -x;
    points[index + totalLines/2][1] = -coreRadius;
    points[index + totalLines/2][2] = x/coreRadius;
    points[index + totalLines/2][3] = 2;

    index++;
  }
  index = totalLines/4;
  for (float y = -coreRadius; y < coreRadius; y += coreGap) {
    //left
    points[index + totalLines/2][0] = -coreRadius;
    points[index + totalLines/2][1] = y;
    points[index + totalLines/2][2] = y/coreRadius;
    points[index + totalLines/2][3] = 1;
    // right
    points[index][0] = coreRadius;
    points[index][1] = -y;
    points[index][2] = y/coreRadius;
    points[index][3] = 3;

    index++;
  }
  
  // draw CPU sqaure
  stroke(color(255,0,0));
  PShape coreOuter = createShape(RECT, -coreRadius, -coreRadius, coreRadius * 2, coreRadius * 2);
  coreOuter.setFill(color(0, 1, 0, 0)); // black with zero alpha is not allowed
  

  float padding = coreRadius * 0.1;
  PShape coreInner = createShape(RECT, -coreRadius + padding, -coreRadius + padding,
    coreRadius * 2 - padding * 2, coreRadius * 2 - 2 * padding);
  coreInner.setFill(color(200,0,0));

  PShape lines[] = new PShape[totalLines];


  // draw lines
  for  (int i = 0; i < points.length; i++) {
    lines[i] = createShape();
    lines[i].beginShape();
    lines[i].noFill();
    lines[i].stroke(250, 0,0);

    // point: xPos, yPos, likelyness to left or right turn, which side is it facing
    for (int run = 0; run < width / lineLength; run++) {
      PVector add = new PVector(0, lineLength);
      switch(int(points[i][3])) {
      case 0:
        break;
      case 1:
        add.rotate(HALF_PI);
        break;
      case 2:
        add.rotate(PI);
        break;
      case 3:
        add.rotate(-HALF_PI);
        break;
      }

      // turn left or right or stay on track?
      float w = (randomGaussian() + points[i][2] * posTurnPosWeight)/(1+posTurnPosWeight);
      if (abs(w) > 1 - turningThreshold) {
        // turn left
        if (w < 0) {
          add.rotate(turnRad);
        }
        // turn right
        else {

          add.rotate(-turnRad);
        }
      }

      // draw
      lines[i].vertex(points[i][0], points[i][1]);
      lines[i].vertex(points[i][0] + add.x, points[i][1] + add.y);

      // update points
      points[i][0] += add.x;
      points[i][1] += add.y;
    }

    lines[i].endShape();
  }

  PShape p = createShape(GROUP);
  p.addChild(coreOuter);
  p.addChild(coreInner);
  for (int i = 0; i < lines.length; i++) {
    p.addChild(lines[i]);
  }
  return p;
}
