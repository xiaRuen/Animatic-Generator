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


PShape tvBlur() {
  PShape group = createShape(GROUP);
  
  float rectWidth = 10;
  float rectHeight = 5;

  noStroke();

  // background
  fill(0);
  PShape background = createShape(RECT, 0, 0, canvasWidth, canvasHeight);
  group.addChild(background);

  // rects
  noiseDetail(3, 0.5);
  for (int i = 0; i < canvasWidth; i+= rectWidth) {
    for (int j = 0; j < canvasHeight; j+= rectHeight) {
      fill(255 * noise(i + randomGaussian(), j) * random(0.5, 1.5));
      PShape rect = createShape(RECT, i + rectWidth / 2 * randomGaussian(), j, rectWidth, rectHeight);
      group.addChild(rect);
    }
  }

   // beams
  for (int y = 0; y < 3; y++) {
    float greyScale = 200 + 50 * randomGaussian();
    fill(color(greyScale, greyScale, greyScale, greyScale-50));
    float h = 50 + 40 * randomGaussian();
    PShape beam = createShape(RECT, 0, random(canvasHeight - h), canvasWidth, h);
    group.addChild(beam);
  }
  
  return group;
}


//--------------------------S3 clock-----------------------
//clock body 
PShape mycircle(){
  //S3 - clock1
  noStroke();
  fill(255);
  PShape clock;
  clock = createShape(ELLIPSE, canvasWidth/2, canvasHeight/2, 300,300);
  return clock;
}

//first needle
PShape clockneedle1(){ //pointing at 2
  //S3 - clock1
  PShape timerect;
  int x = canvasWidth/2;
  int y = canvasHeight/2;
  stroke(0);
  strokeWeight(7);
  float l = 100; //length for clock needle
  float t = 2;
  float time = map(t, 0, 12, 0, TWO_PI)-HALF_PI;
  timerect = createShape(LINE, x, y, cos(time)*l + x, sin(time)*l + y);
  return timerect;
}

//second needle scene
PShape clockneedle2(){ // pointing at 1
  //S3 - clock1
  PShape timerect;
  int x = canvasWidth/2;
  int y = canvasHeight/2;
  stroke(0);
  strokeWeight(7);
  float l = 100; //length for clock needle
  float t = 1;
  float time = map(t, 0, 12, 0, TWO_PI)-HALF_PI;
  timerect = createShape(LINE, x, y, cos(time)*l + x, sin(time)*l + y);
  return timerect;
}

//third needle scene
PShape clockneedle3(){ //pointing at 0
  //S3 - clock1
  PShape timerect;
  int x = canvasWidth/2;
  int y = canvasHeight/2;
  stroke(0);
  strokeWeight(7);
  float l = 100; //length for clock needle
  float t = 0;
  float time = map(t, 0, 12, 0, TWO_PI)-HALF_PI;
  timerect = createShape(LINE, x, y, cos(time)*l + x, sin(time)*l + y);
  return timerect;
}

//eye
PShape eyebody(){
  PShape eyebody;
  fill(255);
  eyebody = createShape(ELLIPSE, canvasWidth/2, canvasHeight/2, 500, 250);
  return eyebody;
}

PShape eyeball1(){
  PShape eyeball1;
  fill(0, 0, 255);
  eyeball1 = createShape(ELLIPSE, canvasWidth/2, canvasHeight/2, 200, 200);
  return eyeball1;
}

PShape eyeball2(){
  PShape eyeball2;
  fill(0);
  eyeball2 = createShape(ELLIPSE, canvasWidth/2, canvasHeight/2, 100, 100);
  return eyeball2;
}

//building
PShape building(){
  PShape building;
  int quantity = 20;
  PShape [] b = new PShape[quantity];
  building = createShape(GROUP);
  int[] rectHeights = new int[quantity];
  int[] rectWidth = new int[quantity];
  //int rectSize = 50;
  int margin = 210;
  rectMode(CENTER);
  
  // Generate random heights for all squares at the beginning
  for (int i = 0; i < rectHeights.length; i++) {
    rectHeights[i] = (int) random(330, 600);
    rectWidth[i] = (int) random(100, 300);
  }
  
  for (int i = 0, x = 50; i < rectHeights.length; i++, x += margin) {
    fill(150);
    stroke(0);
    strokeWeight(2);
    b[i] = createShape(RECT, x, canvasHeight / 2, rectWidth[i], rectHeights[i]);
    building.addChild(b[i]);
  }
  rectMode(CORNER);
  return building;
}

PShape rectangle(){
  PShape r1;
  fill(100);
  r1 = createShape(RECT, 0, canvasHeight/2+150, canvasWidth, canvasHeight/2);
  return r1;
}

PShape mycircle2(){
  noStroke();
  fill(255);
  PShape mycircle2;
  mycircle2 = createShape(ELLIPSE, 0, 0, 200,200);
  return mycircle2;
}

PShape colorcircle(){
  float color1 = random(255);
  float color2 = random(255);
  float color3 = random(255);
  PShape all, inner, middle, outer1, outer2;
  all = createShape(GROUP);
  fill(color3, 0, color1);
  outer1 = createShape(ELLIPSE, 0, 0, 900, 900);
  fill(color1, color2, 0);
  outer2 = createShape(ELLIPSE, 0, 0, 700, 700);
  fill(0, 0, color1);
  middle = createShape(ELLIPSE, 0 ,0, 500, 500);
  fill(color2, 0, color3);
  inner = createShape(ELLIPSE, 0, 0, 300, 300);
  all.addChild(outer1); all.addChild(outer2); all.addChild(middle); all.addChild(inner);
  return all;
}


PShape linearWeb() {
  PShape group = createShape(GROUP);

  fill(255, 255, 255);
  noStroke();

  // Shape → lineGroups → lines

  int lineRadius = int(pow(canvasWidth * canvasWidth
    + canvasHeight * canvasHeight, 0.5) / 2);

  int lineGroupsCount = int(random(5, 15));
  PVector offset = new PVector(
    lineRadius / 8 * randomGaussian(),
    lineRadius / 8 * randomGaussian(),
    random(TWO_PI)
  );

  for (int i = 0; i < lineGroupsCount; i++) {
    int linesInGroup = int(random(1, 6));
    PVector groupOffset = new PVector(
      lineRadius / 4 * randomGaussian(),
      lineRadius / 4 * randomGaussian(),
      randomGaussian()
    );
    for (int j = 0; j < linesInGroup; j++) {
      PVector lineOffset = new PVector(
        lineRadius / 8 * randomGaussian(),
        lineRadius / 8 * randomGaussian(),
        0.1 * randomGaussian()
      );

      PShape line = createShape();

      pushMatrix();

      line = createShape(QUAD, 
        -1.5 * lineRadius, random(-4, 0), 
        0, random(0, 5),
        lineRadius, random(-3, 0), 
        1.5 * lineRadius, random(0, 2)
      );
      line.translate(canvasWidth / 2 + offset.x + groupOffset.x + lineOffset.x, 
        canvasHeight / 2  + offset.y + groupOffset.y + lineOffset.y);
      line.rotate(offset.z + groupOffset.z + lineOffset.z);

      popMatrix();

      line.endShape();
      group.addChild(line);
    }
  }

  return group;
}
