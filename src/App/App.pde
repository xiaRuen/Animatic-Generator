import org.gicentre.handy.*;

// ui
import uibooster.*;
import uibooster.model.*;
import uibooster.components.*;

import java.util.*; // for LinkedList
import java.awt.Toolkit; // for alert()
import java.util.Arrays; // for Arrays.copyOfRange()
import java.nio.*; // for buffers

// System variables
System system;
boolean playing;

//defaults
PShape defaultShape;
String instructionFilePath;

// view related
color themeColor;
int padding = 10;

int rightPanelWidth;
int rightPanelHeight;

int bottomPanelWidth;
int bottomPanelHeight;

color rightPannelBackground;
color bottomPannelBackground;

int textSize;
PFont textFont;

int buttonSize;
PFont buttonFont;


// other globals
float previousTime;
float elapsedTime;
PApplet app; // to pass into HandyRenderer while inside the Button class
Sprite screen;

/*
 Every function named render() relates to the render and update of
 itself, and is called externally, typically the System class.
 */
void setup() {
  // initialize globals
  app = this;
  previousTime = millis() / 1000;
  playing = false;
  
  // initialize main window
  size(600, 400);
  //fullScreen(P2D);
  pixelDensity(displayDensity());
  surface.setResizable(true);

  // defaults
  defaultShape = defaultShape();
  instructionFilePath = dataPath("Instructions.txt");

  // view
  themeColor = color(250, 230, 230);
  padding = 10;
  updateDynamicViewVars();
  textSize = 10;
  textFont = createFont(dataPath("fonts/WenHei.ttf"), textSize);
  buttonSize = 15;
  buttonFont = createFont(dataPath("fonts/WenHei.ttf"), buttonSize);
  
  system = new System();

  createUI();
  refreshView();
  
}


void draw() {
  if (focused) {
    // update elapsed time
    float time = millis() / 1000.0;
    elapsedTime = (time - previousTime);
    previousTime = time;

    if(playing){
      refreshView();
      system.runSprites();

      fill(color(0,0,0,150));
      textFont(textFont);
      textAlign(LEFT,BOTTOM);
      text("Time: " + (millis() / 1000.0 - system.playingOffsetTime), padding, height - bottomPanelHeight);

      system.runInstructions();
      
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
  refreshView();
}
