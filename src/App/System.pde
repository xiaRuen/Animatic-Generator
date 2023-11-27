class System {
  // flow control
  ArrayList<Button> buttons;
  LinkedList<Sprite> sprites;

  // dynamic vars
  ArrayList<ArrayList<String>> instructions;
  SoundFile music;

  // view control
  private boolean mouseWasPressed;
  private int instructionIndex;

  private float playingOffsetTime;

  System() {

    // Buttons
    buttons = new ArrayList<Button>();
    sprites = new LinkedList<Sprite>();
    instructions = loadInstructions(instructionFilePath);
    music = loadMusic(musicFilePath);

    instructionIndex = 0;

    // other control variables
    mouseWasPressed = false;
  }

  public void handleMessage(String msg) {
    String parsedMsg[] = msg.split(" ");
    String args[] = Arrays.copyOfRange(parsedMsg, 1, parsedMsg.length);
    switch(parsedMsg[0].toLowerCase()) {
    case "#":
      break;
    case "action":
      handleButtonAction(args);
      break;
    case "create":
      createSprite(args);
      break;
    case "add":
      addComponents(args);
      break;
    case "remove":
      deleteSprite(args);
      break;
    case "print":
      printFunc(args);
      break;
    default:
      logError("Invalid Command: " + msg);
      println("Invalid Command: " + msg);
    }
  }

  // for App
  public void runView() {
    if (!mouseWasPressed) {
      // e for element
      buttons.forEach((btn) -> {
        if (mouseAtButton(btn)) {
          if (mousePressed) {
            mouseWasPressed = true;
            btn.mouseWasDown = true;
            btn.onMouseDown();
          } else {
            btn.onHover();
          }
        } else if (!btn.mouseWasDown) {
          btn.noInteration();
        }
      }
      );
    }

    // render buttons
    // fill color suppose to be same as background color to hide primary,
    //  but that will create a bug and make the whole thing disappear
  }

  public void runInstructions() {
    // if the time is there
    if(Float.parseFloat(instructions.get(instructionIndex).get(0)) + playingOffsetTime < millis() / 1000.0){
      ArrayList<String> msg = new ArrayList<String>(instructions.get(instructionIndex));
      msg.remove(0);
      handleMessage(String.join(" ", msg));
      if(++instructionIndex < instructions.size()){
         
      }
      // if last element
      else {
        playing = false;
        instructionIndex = 0;
        refreshView();
      }
      refreshRightPanel();
    }

  }

  public void runSprites() {
    ListIterator list_Iter = sprites.listIterator(0);
    while (list_Iter.hasNext()) {
      Sprite s = Sprite.class.cast(list_Iter.next());
      s.render();
    }
  }

  // for View
  public void handleButtonAction(String args[]) {
    if (args.length != 1) {
      logError("internal button action message Error");
      return;
    }

    switch(args[0]) {
    case "create":
      Form form = new UiBooster()
        .createForm("Create Sprites")
        .addText("Timing")
        .addText("Sprite Name")
        .addSelection("Sprite Shape", "default", "cpu")
        .addSlider("Position X %", 0, 100, 1, 20, 10)
        .addSlider("Position Y %", 0, 100, 1, 20, 10)
        .show();

      String timeString = form.getByIndex(0).asString();
      try {
        form.getByIndex(0).asFloat();
      }
      catch (Exception e) {
        println(e);
        new UiBooster().showErrorDialog("Please input a timing in seconds", "Action Now Allowed");
        break;
      }
      String name = form.getByIndex(1).asString();
      if(name.length() == 0){
        name = "unnamed";
      }
      String shapeString = form.getByIndex(2).asString();
      Float posX = form.getByIndex(3).asFloat() / 100.0 * width;
      Float posY = form.getByIndex(4).asFloat() / 100.0 * height;

      

      ArrayList<String> line = new ArrayList<String>();
      line.add(timeString);
      line.add("create");
      line.add(name);
      line.add(shapeString);
      line.add(posX.toString());
      line.add(posY.toString());
      
      addInstruction(line);

      break;

    case "play":
      instructionIndex = 0;
      playingOffsetTime = millis() / 1000.0;
      playing = true;
      music.play();
      break;

    case "x":
      if(instructionIndex == -1){
        Toolkit.getDefaultToolkit().beep();
        break;
      }
      instructions.remove(instructionIndex);
      saveInstructions(instructions);
      refreshRightPanel();
      break;

    case "up":
      if (instructionIndex > 0) {
        instructionIndex--;
        refreshRightPanel();
      } else {
        Toolkit.getDefaultToolkit().beep();
      }
      break;
    case "down":
      if (instructionIndex < instructions.size() - 1) {
        instructionIndex++;
        refreshRightPanel();
      } else {
        Toolkit.getDefaultToolkit().beep();
      }
      break;
    }
  }

  // for general use
  public void logMessage(String msg) {
    println("    ~ " + msg);
  }

  public void logError(String msg) {
    new UiBooster().showException(
      msg,
      "Exception message",
      new Exception("Something went wrong ...")
      );
    println("    ! " + msg);
  }



  // private methods
  private void addInstruction(ArrayList<String> line) {
    if(instructions.size() == 0){
      instructions.add(line);
      instructionIndex = 0;
      saveInstructions(instructions);
      refreshRightPanel();
      return;
    }

    float time = Float.parseFloat(line.get(0));
    int i = 0;
    while(Float.parseFloat(instructions.get(i).get(0)) < time){
      if(++i == instructions.size()) break;
    }
    if(i == instructions.size()){
      instructions.add(line);
    } else{
      instructions.add(i, line);
    }
    saveInstructions(instructions);
    refreshRightPanel();
  }


  private void createSprite (String args[]) {
    // Sprite constructor arguments
    String name;
    PShape spriteShape;
    float posX;
    float posY;
    float rad;


    name = args.length > 0 ? args[0] : "unnamed";

    // try load image
    if (args.length > 1 && !args[1].equals("null")) {
      switch(args[1]) {
      case "cpu":
        spriteShape = cpuShape();
        break;
      case "default":
        spriteShape = defaultShape;
        break;
      default:
        logError("not a valid shape, using defaultshape instead");
        spriteShape = defaultShape;
      }
    } else {
      spriteShape = defaultShape;
    }

    // try parsing string to float
    try {
      posX = args.length > 2 ? Float.parseFloat(args[2]) : 0;
      posY = args.length > 3 ? Float.parseFloat(args[3]) : 0;
      rad = args.length > 4 ? Float.parseFloat(args[4]) : 0;
    }
    catch(Exception e) {
      logError("Type Conversion Error");
      println(e);
      return;
    }
    sprites.add(new Sprite(name, spriteShape, posX, posY, rad));

    logMessage("Succesful creation of object: " + name);
  }

  private void deleteSprite(String args[]) {
    if (args.length != 1) {
      logError("Object name takes one argument only");
    }

    ListIterator list_Iter = sprites.listIterator(0);
    while (list_Iter.hasNext()) {
      Sprite s = Sprite.class.cast(list_Iter.next());
      if (s.name.equals(args[0])) {
        list_Iter.remove();
        logMessage(s.name + " removed");
      }
    }
  }

  private void addComponents(String args[]) {
    if (args.length == 1) {
      logError("Specify sprite name");
      return;
    }

    String params[] = Arrays.copyOfRange(args, 1, args.length);
    switch(args[0]) {
    case "physics":
      addPhyisics(params);
      break;
    case "effect":
      addEffects(params);
      break;
    default:
      logError("Invalid add type");
    }
  }

  private void addEffects(String args[]) {
    // try converting to float
    float params[] = new float[args.length > 1 ? args.length - 2 : 0];
    try {
      for (int i = 0; i < params.length; i++) {
        params[i] = Float.parseFloat((args[i + 2]));
      }
    }
    catch (Exception e) {
      logError("Type Conversion Error");
      println(e);
      return;
    }

    Sprite sprite = findSprite(args[0]);
    if (sprite == null) {
      logError("Invalid sprite name");
      return;
    }
    if (sprite.effect != null) {
      logError("Sprite " + args[0] + " has an existing effect already");
      return;
    }

    // default: fade black one second

    int type;
    switch(args[1]) {
    case "flash":
      type = 1;
      break;
    case "flashInvert":
      type = 2;
      break;
    case "pixelate":
      type = 3;
      break;
    default:
      logError("Invalid effect type");
      return;
    }
    float duration = params.length > 0 ? params[0] : 1;
    float vec4[] = {
      params.length > 1 ? params[1] : 0,
      params.length > 2 ? params[2] : 0,
      params.length > 3 ? params[3] : 0,
      params.length > 4 ? params[4] : 1
    };
    logMessage("Added Effect to " + sprite.name);
    sprite.effect = new Effect(type, duration, vec4);
  }

  private void addPhyisics(String args[]) {

    if (args.length == 1) {
      logError("Where are the physics parameters?");
      return;
    }

    // find sprite
    Sprite sprite = findSprite(args[0]);
    if (sprite == null) {
      logError("Sprite named " + args[0] + " does not exists");
      return;
    }

    if (sprite.phyiscs != null) {
      logError("sprite already had a phyiscs system");
      return;
    }

    // try converting to float
    float params[] = new float[args.length - 1];
    try {
      for (int i = 0; i < params.length; i++) {
        params[i] = Float.parseFloat((args[i+1]));
      }
    }
    catch(Exception e) {
      logError("Type Conversion Error");
      println(e);
      return;
    }

    // check for velocity and angular velocity
    PVector vel = params.length > 0
      ? new PVector(params[0], params.length > 1 ? params[1] : 0)
      : null;
    Float aVel = params.length > 2 ? params[2] : null;

    if (vel == null) {
      logError("Al least enter one parameter for velocity.x");
      return;
    }
    // if they did not input angular velocity
    else if (aVel == null) {
      aVel = 0.0;
    }

    // check for acceleration and angular acceleration
    PVector acc = params.length > 3
      ? new PVector(params[3], params.length > 4 ? params[4] : 0)
      : null;
    Float aAcc = params.length > 5 ? params[5] : null;

    if (acc == null) {
      sprite.phyiscs = new Phyiscs(vel, aVel);
      logMessage("Succesful Creation of " + args[0] + " phyiscs system with dy/dx of one");
      return;
    } else if (aAcc == null) {
      aAcc = 0.0;
    }

    // the third derivative of position, jerk, is not supported
    sprite.phyiscs = new Phyiscs(vel, aVel, acc, aAcc);
    logMessage("Succesful Creation of " + args[0] + " phyiscs system with dy/dx of two");
  }

  // print
  private void printFunc(String args[]) {
    if (args.length != 1) {
      logError("Print only has one argument associate with it");
    }

    switch(args[0]) {
    case "sprite-names":
      ListIterator list_Iter = sprites.listIterator(0);
      while (list_Iter.hasNext()) {
        Sprite s = Sprite.class.cast(list_Iter.next());
        logMessage(s.name);
      }
    case "\n":
      break;
    default:
      logError("invalid print functionality");
    }
  }

  private Sprite findSprite(String name) {
    if (name.equals("screen")) {
      //return screen;
    }

    ListIterator list_Iter = sprites.listIterator(0);
    while (list_Iter.hasNext()) {
      Sprite s = Sprite.class.cast(list_Iter.next());
      if (s.name.equals(name)) {
        return s;
      }
    }
    return null;
  }

  // mouse functions
  private boolean mouseAtButton(Button btn) {
    if (mouseX >= btn.posXPercentage * width
      && mouseX <= btn.posXPercentage * width + btn.widthPercentage * width) {
      if (mouseY >= btn.posYPercentage * height
        && mouseY <= btn.posYPercentage * height + btn.heightPercentage * width) {
        return true;
      }
    }
    return false;
  }
}