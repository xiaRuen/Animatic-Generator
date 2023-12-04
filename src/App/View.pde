/*
This is where all the UI adjustments happen.
 */
interface UI {
  public void noInteration(); // when totally no mouse event have to do with the UI
  public void onHover();
  public void onMouseDown(); // when the first instance of mouse down is on this UI
  public void unSuccesfulClick(); // when mouseDown here, mouseUp elsewhere
  public void onMouseClick();
  public void render();
}

// for dynamic view vars
void updateDynamicViewVars() {
  rightPanelWidth = width / 6;
  bottomPanelHeight = 100;

  while(float(width - rightPanelWidth) / float(height - bottomPanelHeight) < (float(canvasWidth) / canvasHeight)){
    bottomPanelHeight += 1;
  }
  while(float(width - rightPanelWidth) / float(height - bottomPanelHeight) > (float(canvasWidth) / canvasHeight)){
    rightPanelWidth += 1;
  }

  rightPanelHeight = height;
  bottomPanelWidth = width - rightPanelWidth;
  

  rightPannelBackground = lerpColor(themeColor, shadingColor, 0.05);
  bottomPannelBackground =  lerpColor(themeColor, shadingColor, 0.08);

  canvasScaleX = float(width - rightPanelWidth) / width;
  canvasScaleY = float(height - bottomPanelHeight) / height;
}



void createUI() {
  int buttonCount = 5;
  float topOffset = height - bottomPanelHeight + padding; // basically where the y of button start
  float buttonWithPadding = bottomPanelWidth / buttonCount;
  float buttonWidth = buttonWithPadding - 2 * padding;
  float buttonHeight = bottomPanelHeight - 2 * padding;

  float currentPosX = padding;
  system.buttons.add(new Button(
    "Sprite",
    buttonColor,
    (currentPosX) / width,
    (topOffset) / height,
    (buttonWidth) / width,
    (buttonHeight) / height,
    () -> system.handleMessage("action sprite")
    ));

  currentPosX += buttonWithPadding;
  system.buttons.add(new Button(
    "Particles",
    buttonColor,
    (currentPosX) / width,
    (topOffset) / height,
    (buttonWidth) / width,
    (buttonHeight) / height,
    () -> system.handleMessage("action particles")
    ));

  currentPosX += buttonWithPadding;
  system.buttons.add(new Button(
    "Settings",
    buttonColor,
    (currentPosX) / width,
    (topOffset) / height,
    (buttonWidth) / width,
    (buttonHeight) / height,
    () -> system.handleMessage("action settings")
    ));

  currentPosX += buttonWithPadding;
  system.buttons.add(new Button(
    "Play",
    buttonColor,
    (currentPosX) / width,
    (topOffset) / height,
    (buttonWidth) / width,
    (buttonHeight) / height,
    () -> system.handleMessage("action play")
    ));

  currentPosX += buttonWithPadding;
  
  system.buttons.add(new Button(
    "X→",
    buttonColor,
    (currentPosX) / width,
    (topOffset) / height,
    (buttonWidth / 3 - padding/2) / width,
    (buttonHeight) / height,
    () -> system.handleMessage("action x")
    ));

  currentPosX += buttonWidth / 3;
  system.buttons.add(new Button(
    "↑",
    buttonColor,
    (currentPosX) / width,
    (topOffset) / height,
    (buttonWidth / 3 - padding/2) / width,
    (buttonHeight) / height,
    () -> system.handleMessage("action up")
    ));

  currentPosX += buttonWidth / 3;
   system.buttons.add(new Button(
    "↓",
    buttonColor,
    (currentPosX) / width,
    (topOffset) / height,
    (buttonWidth / 3 - padding/2)  / width,
    (buttonHeight) / height,
    () -> system.handleMessage("action down")
    ));


}

void refreshView() {
  background(themeColor);

  refreshBottomPanel();
  refreshRightPanel();
}

/*
 to be called when drawing or redrawing UIs, upon
 start of application, window resize...
 Basically recreates all the UIs
 */

void refreshBottomPanel() {
  fill(themeColor);
  rect(0, height - bottomPanelHeight, bottomPanelWidth, bottomPanelHeight);

  noStroke();
  fill(bottomPannelBackground);
  rect(0, height - bottomPanelHeight, bottomPanelWidth, bottomPanelHeight);

  stroke(shadingColor);
  strokeWeight(0.6);
  line(0, height-bottomPanelHeight, bottomPanelWidth, height-bottomPanelHeight);

  // buttons
  textFont(buttonFont);
  system.buttons.forEach((btn) -> btn.render());
}

void refreshRightPanel() {
  // first only clear the UI portion
  fill(themeColor);
  rect(width - rightPanelWidth, 0, rightPanelWidth, rightPanelHeight);

  // next draw the shade
  noStroke();
  fill(rightPannelBackground);
  rect(width - rightPanelWidth, 0, rightPanelWidth, rightPanelHeight);

  // draw border
  stroke(shadingColor);
  strokeWeight(0.6);
  line(width - rightPanelWidth, 0, width - rightPanelWidth, rightPanelHeight);

  // dynamic load
  textFont(textFont);
  {
    int panelLeft = width - rightPanelWidth + 1 * padding;
    int textBoxLeft = width - rightPanelWidth + 2 * padding;
    int textBoxWidth = rightPanelWidth - 4 * padding;
    int currentHeight = padding;

    for (int i = system.instructionIndex; i < system.instructions.size(); i++) {
      ArrayList<String> line = new ArrayList<String>(system.instructions.get(i));

      int textLineCount = int(textWidth(String.join(" ",line)) / textBoxWidth + 1);
      int textBoxHeight = textSize * textLineCount + 2 * padding;

      
      if(i == system.instructionIndex){
        fill(shadingColor, 20);
        noStroke();
        rect(panelLeft, currentHeight, textBoxWidth + 2 * padding, textBoxHeight);
      }
      fill(textColor);
      textAlign(LEFT, CENTER);
      text(String.join(" ", line), textBoxLeft, currentHeight, textBoxWidth, textBoxHeight);

      currentHeight += textBoxHeight;
    }

  }
}


/*
  A button object created from Button class will mostly represent the button on screen.
 For every frame, functions from system will run and basically if the mouse is hovering
 over this specific button object, its onHover function will be called, which it will then
 execute the onClickFun that was passed in as a constructor parameter when the object was
 created.
 */
public class Button implements UI {
  public String text;
  public float posXPercentage;
  public float posYPercentage;
  public float widthPercentage; // width is reserved keyword so w is used
  public float heightPercentage;
  public boolean mouseWasDown = false;

  private color baseColor;
  private color hoveringColor;
  private color clickingColor;
  private color renderColor;
  private boolean hovering;

  private HandyRenderer handy;
  private Function onClickFunc;

  Button(String t, color c, float xP, float yP, float wP, float hP, Function func) {

    text = t;
    posXPercentage = xP;
    posYPercentage = yP;
    widthPercentage = wP;
    heightPercentage = hP;

    baseColor = c;
    hoveringColor = lerpColor(baseColor, shadingColor, 0.05);
    clickingColor = lerpColor(baseColor, shadingColor, 0.1);
    renderColor = baseColor;

    onClickFunc = func;

    handy = new HandyRenderer(app);
    handy.setFillGap(4);
    handy.setFillWeight(2);
    handy.setBackgroundColour(color(0, 0, 0, 0));

    render();
  }
  public void noInteration() {
    if (renderColor != baseColor) {
      renderColor = baseColor;
      refreshBottomPanel();
    }
  }
  public void onHover() {
    if (renderColor != hoveringColor) {
      renderColor = hoveringColor;
      refreshBottomPanel();
    }
  }
  public void onMouseDown() {
    if (renderColor != clickingColor) {
      renderColor = clickingColor;
      refreshBottomPanel();
    }
  }
  public void unSuccesfulClick() {
    renderColor = baseColor;
    refreshBottomPanel();
  }
  public void onMouseClick() {
    renderColor = baseColor;
    refreshBottomPanel();

    onClickFunc.run();
  }
  public void render() {
    // we use handyRenderer's secondary color as primary color to
    // use the uneven edge of the secondary color tints
    noStroke();
    fill(renderColor);
    handy.rect(posXPercentage * width, posYPercentage * height, widthPercentage * width, heightPercentage * height);

    textAlign(CENTER, CENTER);
    fill(textColor);
    text(text, posXPercentage * width, posYPercentage * height, widthPercentage * width, heightPercentage * height);
  }
}


@FunctionalInterface
  interface Function {
  void run();
}
