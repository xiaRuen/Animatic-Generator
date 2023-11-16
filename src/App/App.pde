import java.util.*; // for LinkedList
import java.awt.Toolkit; // for alert()
import java.util.Arrays; // for Arrays.copyOfRange()
import java.nio.*; // for buffers

// DebugConsole variables
DebugConsole debugConsole;
PSurface debugConsoleSurface;
boolean debugConsoleVisible;
String API[];
PFont CS;
PFont CS_B;

// System variables
System system;
String instructions[];

// other globals
float previousTime;
float elapsedTime;
PShader generalShader;
Sprite screen;
PGraphics screenGraphics;
PGL gl;
ParticleSystem particleSystem; // only one allowed

//defaults
PShape defaultShape;
color backgroundColor;




/*
  Files: API is for a list of commands that one can input dynamically
 into the console or write it into instrucitons.txt by putting a time
 before the command and the system will execute accordingly.
 
 Every function named render() relates to the render and update of
 itself, and is called externally, typically the System class.
 */
void setup() {
  // Load Files
  API = loadStrings("API.txt");
  instructions = loadStrings("Instructions.txt");

  // create the Debug Console window and debug console related
  String[] args = {"Debug Console"};
  DebugConsole debugConsole = new DebugConsole();
  //PApplet.runSketch(args, debugConsole);
  CS = createFont("ComicSansMS", 20);
  CS_B = createFont("ComicSansMS-Bold", 20);
  debugConsoleVisible = false;

  // load other classes
  system = new System();

  // initialize main window
  size(400, 400, P2D);
  //fullScreen(P2D);
  colorMode(HSB, 1);
  pixelDensity(displayDensity());
  surface.setResizable(true);
  screen = new Sprite("screen", null, 0, 0, 0);
  system.sprites.addFirst(screen);

  // initialize globals
  screenGraphics = this.g;
  gl = screenGraphics.beginPGL();
  previousTime = millis() / 1000;
  generalShader = loadShader("Shaders/generalFrag.glsl", "Shaders/generalVert.glsl");
  backgroundColor = color(0.05);
  defaultShape = defaultShape();

  particleSystem = new ParticleSystem();
  
}


void draw() {
  if (focused) {
    // update elapsed time
    float time = millis() / 1000.0;
    elapsedTime = (time - previousTime);
    previousTime = time;

    // start of render pipline
    system.runInstructions();
    system.runSprites();
    system.runParticles();
  }
}

void keyPressed() {
  if (int(keyCode) == 92 && debugConsoleSurface != null) {
    if (debugConsoleVisible) {
      debugConsoleSurface.setVisible(false);
      debugConsoleVisible = false;
      debugConsoleSurface.pauseThread();
    } else {
      debugConsole.update();
      debugConsoleSurface.setVisible(true);
      debugConsoleVisible = true;
      debugConsoleSurface.resumeThread();
    }
  }
}
