/*
  Sethumi Hapuarachchi
  January 10, 2024
  ICS 3U1
  This is my physics game
    
  This file contains all of the variables and main methods used in the game 
*/

// miscellaneous variables
int gameState = 0; // what state the game is in
int levelNumber = 1; // level number
int timer = 0; // tracks how long the player is playing for
int timeSinceLastTimerChange = 0; // used to make sure the timer has the correct values and can start when the game starts
PVector[] platformPositions = new PVector[6]; // tracks the positions of the level platforms
boolean playerWonGame = false; // whether the player won the game

// player variables
PVector PlayerPosition = new PVector(45, 30); // tracks the player's position
PVector PlayerVelocity = new PVector (0, -2); // tracks the player's velocity
PVector Gravity = new PVector(0, 1); // the gravity force on the player to make them fall down
float elasticity = 0.3; // the elasticity of the player
float airResistance = 0.05; // the air resistance

boolean playerTouchedObstacle = false; // whether the player touched an obstacle (monster, goo, fell into a hole)
boolean playerTouchedPortal = false; // whether the player touched a portal
boolean playerTouchedGround = false; // whether the player touched the ground

boolean playerGoingRight = false; // whether the player is going right 
boolean playerGoingLeft = false; // whether the player is going left
boolean playerJumping = false; // whether the player is jumping 
boolean playerLookingRight = true; // this determines where the player is facing. if it is true, the player is looking right. if false, it is looking left

color colourPlayerIsTouching; // colour that the player is touching, used for collision
int numberOfLives = 5; // number of lives the player has

// monster variables
PVector[] MonsterPosition = {new PVector(450, 520), new PVector(465, 445), new PVector(250, 295), new PVector(500, 320), new PVector(200, 520)}; // the monster's position in different levels
int monsterDirection = 1; // tracks the direction the monster is moving in. if positive, it is going right, if negative, it is going left
int itemToCallFromMonsterPositionArray = 0; // this tracks what position to get from the array
int numberOfStepsMonsterTook = 0; // tracks number of steps monster took, lets program know when to change monster's direction when it's at a certain value
boolean monsterOnScreen = false; // tracks whether the monster is on the screen

// photo variables
PImage BackgroundImage; // contains the image drawn in the background
PImage PortalImage; // contains the image of the portal
PImage HeartImage; // the hearts used to track the number of lives
PImage MainMenuImage; // the image used on menu screen
PImage WinningImage; // the image used on the winning end screen
PImage LosingImage; // the image used on the losing end screen

// sound variables
import processing.sound.*; // imports the tools needed to play sound
SoundFile jumpingSound; // jumping sound
SoundFile backgroundMusic; // background music 
int soundEffectsState = 1; // tracks whether to play sound effects. if it's one, they play. if it's 0, no sound plays
int musicState = 1; // tracks whether to play music. if it's one, it plays. if it's 0, no music plays


void setup() // does the settings, creates canvas, loads images and sounds 
{
  size(1000, 700);
  // settings
  textAlign(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);
  // loading images and sounds 
  BackgroundImage = loadImage("ForestBackground.jpg");
  BackgroundImage.resize(1000, 700);
  PortalImage = loadImage("PortalImage.png");
  PortalImage.resize(100, 100);
  HeartImage = loadImage("HeartImage.png");
  HeartImage.resize(40, 25);
  MainMenuImage = loadImage("MainMenuImage.png");
  MainMenuImage.resize(200, 300);
  WinningImage = loadImage("WinningImage.png");
  WinningImage.resize(200, 300);
  LosingImage = loadImage("LosingImage.png");
  LosingImage.resize(200, 300);
  jumpingSound = new SoundFile(this, "jumpingSound.wav");
  backgroundMusic = new SoundFile(this, "backgroundMusic.wav");
  backgroundMusic.loop(); // the music is being played here since it sounds better. This is looping the music
}

void draw() // generates the whole program
{
  switch(gameState) // different methods are called based on the game state 
  {
    case 0: // if it's 0
      generateMenuScreen(); // generates the menu screen
      break;
    case 1: // if it's 1
      generateInstructionsScreen(); // generates the instructions screen
      break;
    case 2: // if it's 2
      generateGame(); // generates the game 
      break;
    case 3: // if it's 3
      generatePauseScreen(); // generates the pause screen
      break;
    case 4: // if it's 4
      generateEndScreen(); // generates the end screen 
      break;
  }
}

void generateMenuScreen()
{
  image(BackgroundImage, width/2, height/2); // generates the background
  image(MainMenuImage, 200, 360); // image of character 
  fill(#FFFFFF);
  textSize(70);
  text("Out of the woods", width/2, 150); // title
  textSize(30);
  text("A simple platformer", width/2, 200); // sub-title
  
  textSize(70);
  // buttons
  fill(#000000);
  stroke(#FFFFFF);
  rect(500, 300, 200, 100);
  rect(500, 450, 200, 100);

  fill(#FFFFFF);
  textSize(35);
  text("Play", 500, 310);
  text("Instructions", 500, 460);
  
  drawSoundButton(950, 50); // creates the button to turn on and off sound
  drawMusicButton(875, 50); // creates the button to turn on and off music
}

void generateInstructionsScreen() 
{
  image(BackgroundImage, width/2, height/2);

  // back button
  fill(#000000);
  stroke(#FFFFFF);
  rect(200, 600, 200, 100);
  fill(#FFFFFF);
  textSize(40);
  text("Back", 200, 610);

  // instructions
  text("Play all of the levels in order to get to the end", 500, 200);
  text("There are 10 levels in total", 500, 250);
  text("Use the arrow keys to move", 500, 300);
  text("Avoid purple goo and monsters!", 500, 350);
  text("Don't fall into the ground!", 500, 400);
  text("Press p to pause, and r to reset", 500, 450);
  
  // drawing the sound and music buttons
  drawSoundButton(950, 50);
  drawMusicButton(875, 50); 
}

void generateGame()
{
  image(BackgroundImage, width/2, height/2); // generates the background 
  for (int i = 0; i < numberOfLives; i++) // generates the hearts representing lives
  {
    image(HeartImage, 950-i*50, 40); 
  }
  
  if (millis() - timeSinceLastTimerChange > 1000) // if it has been more than one second
  {
    timer++; // the timer changes by 1
    timeSinceLastTimerChange = millis(); // this variable tracking the changes is set to millis
  }
  
  drawPlayer(); // draws the still image of the player
  movePlayer(); // moves the player
  generateLevel(); // generates the level
  
  if (monsterOnScreen) // if the monster is on the screen 
  {
    moveMonster(); // the monster is moved 
  }
  
  checkPlayerCollisionWithObjects(); // checks whether the player hits the ground
  checkIfPlayerHitsEdges(); // checks whether the player hits the ground or edges of screen
  checkWinningConditions(); // checks whether the player has won or lost
}

void generatePauseScreen()
{
  image(BackgroundImage, width/2, height/2); // generates the background
  fill(#FFFFFF);
  textSize(60);
  text("Paused", width/2, 300);
  textSize(30);
  text("Press p to unpause", width/2, 400);
  text("Press r to reset", width/2, 450);
  drawSoundButton(950, 50); 
  drawMusicButton(875, 50); 
}

void generateEndScreen()
{
  image(BackgroundImage, width/2, height/2); // generates the background
  if (playerWonGame) // if the player won the game
  {
    fill(#FFFFFF);
    textSize(55);
    text("You finished!", 650, 300);
    textSize(30);
    text("Number of lives left: " + numberOfLives, 650, 350);
    image(WinningImage, 200, 400);
  } 
  else // if the player lost 
  {
    fill(#FFFFFF);
    textSize(55);
    text("You lost...", 650, 300);
    textSize(30);
    text("Level reached: " + levelNumber + "/10", 650, 350);
    image(LosingImage, 200, 400);
  }

  text("Time elapsed: " + timer + " seconds", 650, 400); // writes how much time has passed
  drawSoundButton(950, 50); 
  drawMusicButton(875, 50); 
  
  // restart button
  stroke(#FFFFFF);
  fill(#000000);
  rect(650, 500, 200, 100);
  textSize(40);
  fill(#FFFFFF);
  text("Restart", 650, 510);
}

void keyPressed() // for moving the player, pausing and restarting the game
{
  switch(gameState)
  {
  case 2:
    if (keyCode == 80 || keyCode == 112) // if the user presses p (pause)
    {
      gameState = 3; // the game goes to the pause screen
    } 
    else if (keyCode == 82 || keyCode == 114) // if the user presses r (reset)
    {
      gameState = 0; // the game goes back to the menu
      resetVariables(); // it also resets the variables
    }

    if (keyCode == 37) // if the user presses the left key
    {
      playerLookingRight = false; // the program knows the user is not looking to the right
      playerGoingLeft = true; // the program knows the user wants to go to the left
    }
    if (keyCode == 39) // the same principle is applied to the right arrow key
    {
      playerLookingRight = true; // the program knows the user is looking right
      playerGoingRight = true;
    }
    if (keyCode == 38 && !playerJumping) // and to the up right arrow
    {
      playerJumping = true; // the booleans changed their values so 
      playerTouchedGround = false;
      PlayerVelocity.y=-30;
      if (soundEffectsState == 1) // if sound effects are on
      {
        jumpingSound.play(); // the jumping sound will play 
      }
    }
    break;

  case 3:
    if (keyCode == 80 || keyCode == 112) // if the user presses p to unpause
    {
      gameState = 2; // the game goes back to the game
      timeSinceLastTimerChange = millis(); // better tracking
    }
    else if (keyCode == 82 || keyCode == 114) // if the user presses r (reset)
    {
      gameState = 0; // the game goes back to the menu
      resetVariables(); // it also resets the variables
    }
    break;
  }
}

void keyReleased() // used for movement
{
  if (gameState == 2)
  {
    if (keyCode == 37) // when the user lets go of the left arrow key
    {
      playerGoingLeft = false; // the program knows the user stops wanting to go to left
    }
    if (keyCode == 39) // same principle applies to the right arrow key
    {
      playerGoingRight = false;
    }
  }
}

void mousePressed() // checks whether the user presses any buttons
{
  switch(gameState)
  {
  case 0: // on the menu screen
    if (mouseX > 400 && mouseX < 600 && mouseY > 250 && mouseY < 350) // play button
    {
      gameState = 2; // switches to game
      timeSinceLastTimerChange = millis(); // this is set to when the player hits button so timer works properly
    } 
    else if (mouseX > 400 && mouseX < 600 && mouseY > 400 && mouseY < 500) // instructions screen button
    {
      gameState = 1; // switches to instructions screen
    }
    else if (mouseX > 925 && mouseX < 975 && mouseY > 25 && mouseY < 75) // sound effects button
    {
      soundEffectsState = (soundEffectsState+1)%2; // the variable is changed to 0 or 1; determines whether sound effects are used + costume change
    }
    if (mouseX > 850 && mouseX < 900 && mouseY > 25 && mouseY < 75) // music button
    {
      musicState = (musicState+1)%2; // the variable is changed to 0 or 1 for the costume change
      if (backgroundMusic.isPlaying()) // if the background music is playing
      {
        backgroundMusic.pause(); // it will pause
      }
      else
      {
        backgroundMusic.play(); // otherwise it plays 
      }
    }
    break;

  case 1: // on the instructions screen
    if (mouseX > 100 && mouseX < 300 && mouseY > 550 && mouseY < 650) // the back button
    {
      gameState = 0; // switches to menu screen
    }
    else if (mouseX > 925 && mouseX < 975 && mouseY > 25 && mouseY < 75) // sound effects button
    {
      soundEffectsState = (soundEffectsState+1)%2; 
    }
    if (mouseX > 850 && mouseX < 900 && mouseY > 25 && mouseY < 75) // sound effects button
    {
      musicState = (musicState+1)%2; 
      if (backgroundMusic.isPlaying())
      {
        backgroundMusic.pause();
      }
      else
      {
        backgroundMusic.play();
      }
    }
    break;

  case 3: // on the paused screen
    if (mouseX > 925 && mouseX < 975 && mouseY > 25 && mouseY < 75) // sound effects button
    {
      soundEffectsState = (soundEffectsState+1)%2; 
    }
    if (mouseX > 850 && mouseX < 900 && mouseY > 25 && mouseY < 75) // music button
    {
      musicState = (musicState+1)%2;
      if (backgroundMusic.isPlaying())
      {
        backgroundMusic.pause();
      }
      else
      {
        backgroundMusic.play();
      }
    }
    break;

  case 4:
    if (mouseX > 550 && mouseX < 750 && mouseY > 400 && mouseY < 500) // restart button
    {
      resetVariables(); // the variables are reset 
      gameState = 0; // switches to menu screen
    }
    if (mouseX > 925 && mouseX < 975 && mouseY > 25 && mouseY < 75) // sound effects button
    {
      soundEffectsState = (soundEffectsState+1)%2; 
    }
    if (mouseX > 850 && mouseX < 900 && mouseY > 25 && mouseY < 75) // music button
    {
      musicState = (musicState+1)%2; 
      if (backgroundMusic.isPlaying())
      {
        backgroundMusic.pause();
      }
      else
      {
        backgroundMusic.play();
      }
    }
    break;
  }
}

void resetVariables() // resets all neccesary variables whenever the user restarts the game 
{
  levelNumber = 1;
  numberOfLives = 5;
  timer = 0;
  timeSinceLastTimerChange = 0;
  colourPlayerIsTouching = #000000; // is set to black since this does not fufill any conditions for collision
  playerWonGame = false;

  PlayerPosition = new PVector(45, 30); // sets the player at the top left corner 
  PlayerVelocity = new PVector (0, -2);

  playerTouchedGround = false;
  playerTouchedPortal = false;
  playerTouchedObstacle = false;
  playerGoingRight = false;
  playerGoingLeft = false;
  playerJumping = false;
  playerLookingRight = true;
  
  MonsterPosition[0] = new PVector(450, 520);
  MonsterPosition[1] = new PVector(465, 445);
  MonsterPosition[2] = new PVector(250, 295);
  monsterDirection = 1;
  numberOfStepsMonsterTook = 0;
  itemToCallFromMonsterPositionArray = 0;
  monsterOnScreen = false;
}

void checkWinningConditions()
{
  // checking if the user has won
  if (levelNumber > 10) // if level number is greater than total number of levels
  {
    playerWonGame = true; // the boolean is set to true
    gameState = 4; // the game state changes to end screen
  }
  
  // checking if the user has lost
  if (numberOfLives <= 0) // if user has 0 lives or less
  {
    playerWonGame = false; // the boolean is set to false
    gameState = 4; // the game state changes to end screen
  }
}
