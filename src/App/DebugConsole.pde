//GUI of message bus, aka the console
//instead of using msg, to avoid
//confusion, command will be used

public class DebugConsole extends PApplet {
  // the most recent command will always be at the first position
  // therefore Linked List is the best data type
  private LinkedList<String> commands;
  // a separate variable for current inputing command as we don't
  // the sophisticated process of getting the fisrt element of
  // commands, then substring, then set the first element
  private String currentCmd;
  // for tracking the current trace backed commands
  private int traceBackIndex;
  // constants
  private static final int textHeight = 22;
  private static final int textPaddingX = 22;
  private static final int  textPaddingY = 5;
  private static final int maxCommandStorage = 100;

  public void settings() {
    size(600, 350, P2D);
  }
  public void setup() {
    // PApplet is created after settings
    debugConsole = this;
    debugConsoleSurface = surface;
    surface.setVisible(false);
    surface.setResizable(true);
    surface.pauseThread();

    // initialize variables

    commands = new LinkedList<String>();
    commands.addFirst("    ~ Type 'API' to get the Application Programming Interface");
    currentCmd = "";
    traceBackIndex = -1; // at -1, the only legal action is to increment to 0

    // deliberatly call it twice as some elements are accesing the console before call one finished
    windowResized();
    windowResized();
  }

  // leave blank as a console do not need to be updated every frame
  public void draw() {
  };

  public void keyPressed() {
    // if return (mac) or enter (windows) is pressed
    if (int(key) == 10) {
      // if the user tries to input new line with no input
      if (currentCmd.length() == 0) {
        Toolkit.getDefaultToolkit().beep();
      } else {
        commands.addFirst(currentCmd);
        executeCommand(currentCmd);
        currentCmd = "";
      }
    }
    // if delete is pressed
    else if (int(key) == 8) {

      if (currentCmd.length() > 0) {
        currentCmd = currentCmd.substring(0, currentCmd.length()-1);
      } else {
        Toolkit.getDefaultToolkit().beep();
      }
    }
    // letters or _ or - or ' ' or numbers
    else if (Character.isLetter(key) || int(key) == 95 || int(key) == 45
    || int(key) == 32 || Character.isDigit(key)) {
      currentCmd += key;
    }
    // \
    else if (int(key) == 92) {
      debugConsoleSurface.setVisible(false);
      debugConsoleVisible = false;
      debugConsoleSurface.pauseThread();
    }
    // up arrow
    else if (keyCode == 38) {
      if (traceBackIndex < commands.size() - 1) {
        traceBackIndex++;
        currentCmd = commands.get(traceBackIndex);
      } else {
        Toolkit.getDefaultToolkit().beep();
      }
    }
    // down arrow
    else if (keyCode == 40) {
      if (traceBackIndex > 0) {
        traceBackIndex--;
        currentCmd = commands.get(traceBackIndex);
      } else {
        // having reached the bottom, if they wanted to get and empty line
        if (currentCmd.length() != 0) {
          currentCmd = "";
        } else {
          Toolkit.getDefaultToolkit().beep();
        }
      }
    }
    // all the unsupported keys yet
    else {
      Toolkit.getDefaultToolkit().beep();
    }

    update();
  }

  public void addMsg(String msg){
    debugConsole.commands.addFirst(msg);
        debugConsole.checkCommandSize();
        debugConsole.update();

  }

  public void windowResized() {
    textAlign(LEFT, BOTTOM);
    textFont(CS);
    textSize(textHeight * 0.6);
    update();
  }


  // private methods
  private void update() {
    background(40);
    int currentHeight = height - textHeight - textPaddingY;
    for (int i = 0; currentHeight > 0 && i < commands.size(); i++) {
      String s = commands.get(i);
      text(commands.get(i), textPaddingX, currentHeight);
      currentHeight -= s.split("\n").length * textHeight;
    }
    text(">", textPaddingX/2, height - textPaddingY);
    text(currentCmd, textPaddingX, height - textPaddingY);
  }

  private void executeCommand(String command) {
    switch(command) {
    case "API":
      if (API.length > 0) {
        for (String line : API) {
          commands.addFirst(line);
        }
      } else {
        system.logError("API.txt missing, correct installation?");
      }

      break;
    default:
      system.handleMessage(command);
    }
  };

  private void checkCommandSize(){
    if (commands.size() > maxCommandStorage) {
      commands.removeLast();
    }
  }

  // end of Console class
}
