//-----include libraries------------------
// sound
import processing.sound.*;

// ui
import org.gicentre.handy.*;
import uibooster.*;
import uibooster.model.*;
import uibooster.components.*;

// other
import java.nio.file.*; // for checking paths
import java.util.*; // for LinkedList
import java.awt.Toolkit; // for alert()
import java.util.Arrays; // for Arrays.copyOfRange()
//-----end of include libraries------------------

// System variables
System system;
boolean playing;

//defaults
String instructionFilePath;
String musicFilePath;

// view related
color themeColor;
int padding;

int rightPanelWidth;
int rightPanelHeight;

int bottomPanelWidth;
int bottomPanelHeight;

color rightPannelBackground;
color bottomPannelBackground;

color shadingColor;

int textSize;
color textColor;
PFont textFont;

int buttonSize;
color buttonColor;
PFont buttonFont;

int canvasWidth;
int canvasHeight;
float canvasScaleX;
float canvasScaleY;

// other globals
float previousTime;
float elapsedTime;
PApplet app; // to pass into HandyRenderer while inside the Button class

/*
 Every function named render() relates to the render and update of
 itself, and is called externally, typically the System class.
 */
void setup() {
  // initialize globals
  app = this;
  previousTime = millis() / 1000;
  playing = false;

  instructionFilePath = dataPath("Instructions.txt"); 
  musicFilePath = dataPath("echo.wav");

  // initialize main window
  size(800, 400);
  //fullScreen(P2D);
  pixelDensity(displayDensity());
  surface.setResizable(true);

  // view
  themeColor = color(30, 40, 50);
  padding = 10;
  
  shadingColor = (red(themeColor) + green(themeColor) + blue(themeColor)) / 765 > 0.5 ? color(0,0,0) : color(255,255,255);
  textSize = 10;
  textColor = color(shadingColor, 150);
  textFont = createFont(dataPath("fonts/WenHei.ttf"), textSize);

  buttonSize = 15;
  buttonColor = color(shadingColor, 20);
  buttonFont = createFont(dataPath("fonts/WenHei.ttf"), buttonSize);
  
  canvasWidth = 1920;
  canvasHeight = 1080;

  system = new System();

  updateDynamicViewVars();
  createUI();
  refreshView();

}


void draw() {
  if (focused) {
    // update elapsed time
    float time = millis() / 1000.0;
    elapsedTime = (time - previousTime);
    previousTime = time;

    if (playing) {
      background(themeColor);
      
      pushMatrix();
      scale(canvasScaleX * width / canvasWidth, canvasScaleY * height / canvasHeight);
      system.runParticles(); // draw particles
      system.runSprites(); // draw sprites
      popMatrix();

      fill(textColor);
      textFont(textFont);
      textAlign(LEFT, BOTTOM);
      text("Time: " + (millis() / 1000.0 - system.playingOffsetTime), padding, height - bottomPanelHeight);

      system.runInstructions(); // update instructions

      refreshBottomPanel();
      refreshRightPanel();

      
    }
    system.runView();
  }
}

void keyPressed() {
}

// if the user mouseDown on element, but dragged mouse
// somewhere else before releasing, then it doesn't count as a click
void mouseReleased() {
  system.mouseWasPressed = false;
  system.buttons.forEach((e) -> {
    if (e.mouseWasDown) {
      if (system.mouseAtButton(e)) {
        e.onMouseClick();
      } else {
        e.unSuccesfulClick();
      }
      e.mouseWasDown = false;
    }
  }
  );
}

void windowResized() {
  updateDynamicViewVars();
  system.buttons.clear();
  createUI();
  refreshView();
}
