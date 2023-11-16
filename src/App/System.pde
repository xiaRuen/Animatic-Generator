class System {
  LinkedList<Sprite> sprites;
  private int instructionsIndex;
  private float nextInstructionTime;

  System() {
    sprites = new LinkedList<Sprite>();

    if(instructions.length > 0){
      instructionsIndex = 0;
    nextInstructionTime = Float.parseFloat(instructions[instructionsIndex].split(" ")[0]);
    } else {
      instructionsIndex = 0x3f3f3f3f;
    }
    
  }

  public void handleMessage(String msg) {
    String parsedMsg[] = msg.split(" ");
    String args[] = Arrays.copyOfRange(parsedMsg, 1, parsedMsg.length);
    switch(parsedMsg[0].toLowerCase()) {
    case "#":
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
    case "particles":
      toggleParticles(args);
      break;
    case "print":
      printFunc(args);
      break;
    default:
      logError("Invalid Command: " + msg);
      println("Invalid Command: " + msg);
    }
  }

  public void runInstructions() {

    if (instructionsIndex < instructions.length && nextInstructionTime < millis() / 1000.0) {
      String parsedLine[] = instructions[instructionsIndex].split(" ");
      String msg = "";
      for (int i = 1; i < parsedLine.length; i++) {
        msg += parsedLine[i];
        msg += " ";
      }
      handleMessage(msg);
      instructionsIndex++;
      while (instructionsIndex <  instructions.length
        && instructions[instructionsIndex].equals("")) {
        instructionsIndex++;
      }
      if (instructionsIndex < instructions.length) {
        nextInstructionTime = Float.parseFloat(
          instructions[instructionsIndex].split(" ")[0]
          );
      }
    }
  }

  public void runSprites() {
    ListIterator list_Iter = sprites.listIterator(0);
    while (list_Iter.hasNext()) {
      Sprite s = Sprite.class.cast(list_Iter.next());
      s.render();
    }
  }

  public void runParticles(){
    if(particleSystem != null){
      particleSystem.render();
    }
  }

  public void logMessage(String msg) {

    if (debugConsoleSurface != null && debugConsole != null) {
      if (!debugConsoleVisible) {
        debugConsoleSurface.resumeThread();
        debugConsole.addMsg("    ~ " + msg);
        debugConsoleSurface.pauseThread();
      } else {
        debugConsole.addMsg("    ~ " + msg);
      }
    } else {
      println("    ~ " + msg);
    }
  }

  public void logError(String msg) {
    if (debugConsoleSurface != null && debugConsole != null) {
      if (!debugConsoleVisible) {
        debugConsoleSurface.resumeThread();
        debugConsole.addMsg("    ! " + msg);
        debugConsoleSurface.setVisible(true);
        debugConsoleVisible = true;
      } else {
        debugConsole.addMsg("    ! " + msg);
      }
    } else {
      println("    ! " + msg);
    }
  }


  // private methods

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
    if (debugConsole != null) {
      logMessage("Succesful creation of object: " + name);
    }
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
    if(sprite == null){
      logError("Invalid sprite name");
      return;
    }
    if(sprite.effect != null){
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

  private void toggleParticles(String args[]){

    // // try converting to floats first
    // float params[] = new float[args.length];
    // try {
    //   for (int i = 0; i < params.length; i++) {
    //     params[i] = Float.parseFloat((args[i+1]));
    //   }
    // }
    // catch(Exception e) {
    //   logError("Type Conversion Error");
    //   println(e);
    //   return;
    // }

    // for now just switch it on and off
    if(particleSystem == null){
      particleSystem = new ParticleSystem();
    } else {
      particleSystem = null;
    }
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
    if(name.equals("screen")){
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
}
