int nPredators = 50;
int nPrey = 100;
int maxPredators = 500;
int maxPrey = 500;
float seconds = 0, minutes = 0;

Predator [] invaders;
Prey [] defenders; 
Predator [] placeholder = new Predator[1];
Prey [] preyceholder = new Prey[1];

void setup() {
  size(1800, 1000);
  noStroke();
  invaders = new Predator[nPredators]; 
  defenders = new Prey[nPrey];
  for (int i = 0; i < invaders.length; i++) { 
    invaders[i] = new Predator();
  }
  for (int i = 0; i < defenders.length; i++) { 
    defenders[i] = new Prey();
  }
}


void draw() {
  background(255);
  
  for (int i = 0; i < defenders.length; i++) { // loop food functions if alive
    if (defenders[i].dead == false) { // only run these if the bacteria is either alive or running its death animation
      if (defenders[i].alive) { // don't move while running death animation
        defenders[i].move();
        defenders[i].beEaten();
      }
      defenders[i].show();
      defenders[i].die();
      defenders[i].debug();
    } else {
      preyceholder[0] = defenders[defenders.length - 1];
      defenders[defenders.length - 1] = defenders[i];
      defenders[i] = preyceholder[0];
      defenders = (Prey[])shorten(defenders);
    }
  }
  
  for (int i = 0; i < invaders.length; i++) {
    if (invaders[i].dead == false) { // only run these if the bacteria is either alive or running its death animation
      if (invaders[i].alive) { // don't move while running death animation
        invaders[i].move();
      }
      invaders[i].show();
      invaders[i].die();
    } else {
      placeholder[0] = invaders[invaders.length - 1];
      invaders[invaders.length - 1] = invaders[i];
      invaders[i] = placeholder[0];
      invaders = (Predator[])shorten(invaders); 
    }
  }
  
  seconds += 1 / frameRate;
  minutes = (int)(seconds / 60);
  fill(0);
  text("Predators: " + nPredators, 10, 20);
  text("Prey: " + nPrey, 10, 30);
  if (seconds % 60 < 10) {
    text((int)minutes + ":0" + (int)seconds % 60, 10, 40);
  } else {
    text((int)minutes + ":" + (int)seconds % 60, 10, 40);
  }
}

void mouseClicked() {
  //Predator filler = new Predator(mouseX, mouseY, 300 + 150 * (float)Math.random(), 1 + (float)(0.8 * Math.random()), 0.001);
  //invaders = (Predator[])append(invaders, filler);
  //nPredators += 1;
  for (Prey lostKid : defenders) {
    System.out.println("(" + lostKid.x + ", " + lostKid.y + ")   ");
  }
}

class Predator {
  float x, y, a, fDist1, fDist2, foodX, foodY, lifetime, initialLife, diameter, initDiameter, angleToFood, moveSpeed, xBump, yBump, distance, duplicationFactor;
  color colour;
  int randomnessMult, timeSinceDuplication, foodTargeted, eatTick, starveTick, snackNum;
  boolean alive, dead;
  int diam2; // not directly related to bacteria but used for cosmetic purposes later
  Prey [] dOverlappers;
  Predator [] aOverlappers;

  void move() {
    findNearestFood();
    countOverlaps();
    eating();
    angleToFood = acos((foodX - x) / fDist2); // calculate angle towards food
    if (foodY >= y) {
      angleToFood = -1 * angleToFood; // inverse trigs are annoying
    }
    x += moveSpeed*cos(angleToFood);
    y -= moveSpeed*sin(angleToFood); // negative here b/c cartesian coords in math are different from programmer coords
    x += xBump * 0.15;
    y += yBump * 0.15;
    //x += ((Math.random() - 0.5) * randomnessMult); // random walk
    //y += ((Math.random() - 0.5) * randomnessMult);
    locationRollover();
    digest();
  }

  void show() {
    fill(colour);
    ellipse(x, y, diameter, diameter); // show bacteria
    if (alive) { // diameter decreases with lifetime to a minimum
      diameter = 10 * lifetime / initialLife + initDiameter;
    }
  }

  void digest() {
    if (snackNum > 0 && lifetime <= 2 * initialLife) { // lose life if not eating, gain if eating
      lifetime += 2 * snackNum;
      eatTick += 1;
    } else {
      lifetime -= 1;
      starveTick += 1;
    }
    duplicate();
  }
  
  void findNearestFood() {
    float deltaX, deltaY;
    int foodTargeted = -1;
    for (int i = 0; i < defenders.length; i++) {
      deltaX = defenders[i].x - x;
      deltaY = defenders[i].y - y;
      if (defenders[i].alive == true) {
        if (abs(deltaX) > width/2) {
          if (deltaX > 0) {
            deltaX -= width;
          } else {
            deltaX += width;
          }
        }

        if (abs(deltaY) > height/2) {
          if (deltaY > 0) {
            deltaY -= height;
          } else {
            deltaY += height;
          }
        }

        if (sqrt(deltaX * deltaX + deltaY * deltaY) < fDist1) { // pythagorean theorem for distance btwn food and bacteria
          fDist1 = sqrt(deltaX * deltaX + deltaY * deltaY);
          foodX = deltaX + x;
          foodY = deltaY + y;
          foodTargeted = i;
        }
      }
      fDist2 = fDist1; // save distance value to be used elsewhere
    }
    fDist1 = 99999; // reset for next loop
  }

  void countOverlaps() {
    xBump = yBump = 0;
    aOverlappers = new Predator[0];
    dOverlappers = new Prey[0];
    for (int i = 0; i < invaders.length; i++) {
      distance = sqrt((invaders[i].x - x) * (invaders[i].x - x) + (invaders[i].y - y) * (invaders[i].y - y));
      if (distance <= (diameter + invaders[i].diameter)/2) {
        aOverlappers = (Predator[])append(aOverlappers, invaders[i]);
      }
    }
    for (int i = 0; i < aOverlappers.length; i++) {
      xBump += (x - aOverlappers[i].x) * 0.1;
      yBump += (y - aOverlappers[i].y) * 0.1;
    }

    for (int i = 0; i < defenders.length; i++) {
      distance = sqrt((defenders[i].x - x) * (defenders[i].x - x) + (defenders[i].y - y) * (defenders[i].y - y));
      if (distance <= (diameter + defenders[i].diameter)/2) {
        dOverlappers = (Prey[])append(dOverlappers, defenders[i]);
      }
    }
    for (int i = 0; i < dOverlappers.length; i++) {
      xBump += (x - dOverlappers[i].x) * 0.01;
      yBump += (y - dOverlappers[i].y) * 0.01;
    }
  }

  void die() {
    if (lifetime <= 0 && alive) {
      alive = false;
      nPredators -= 1;
    }
    if (diam2 <= diameter && alive == false) { // end death animation when the bacteria is covered
      diameter += 1;
      diam2 += 2;
      fill(255);
      ellipse(x, y, diam2, diam2); // death animation
      fill(colour);
    }

    if (diam2 > diameter) {
      dead = true; // different value from alive so bacteria only disappears once death animation finishes
    }
  }

  void locationRollover() {
    if (x > width || x < 0) {
      x -= width;
      x = abs(x);
    }
    if (y > height || y < 0) {
      y -= height;
      y = abs(y);
    }
  }

  void duplicate() {
    if (eatTick + starveTick == 50 || lifetime >= initialLife * 1.5) {
      if ((eatTick >= 35 || lifetime >= initialLife * 1.5) && timeSinceDuplication >= frameRate * duplicationFactor && invaders.length < maxPredators) {
        Predator filler = new Predator(x, y, lifetime / 2, moveSpeed, duplicationFactor);
        invaders = (Predator[])append(invaders, filler);
        nPredators += 1;
        lifetime = lifetime / 2;
        timeSinceDuplication = 0;
      } else {
        timeSinceDuplication += 1;
      }
    }
  }

  void eating() { // check if bacteria in contact with food (which is when it eats)
    snackNum = 0;
    for (int i = 0; i < defenders.length; i++) {
      distance = sqrt((defenders[i].x - x) * (defenders[i].x - x) + (defenders[i].y - y) * (defenders[i].y - y));
      if (distance < (diameter + defenders[i].diameter)/2) {
        snackNum += 1;
      }
    }
  }

  Predator() {
    x = (int)(width * Math.random());
    y = (int)(height * Math.random());
    a = 255;
    colour = color(150 + (float)Math.random() * 105, 60, 100, a);
    initDiameter = 15;
    diameter = 10 * lifetime / initialLife + initDiameter;
    randomnessMult = 7;
    initialLife = 300;
    lifetime = initialLife + 150 * (float)Math.random();
    alive = true;
    dead = false;
    fDist1 = fDist2 = 99999; // arbitrarily chosen large number
    timeSinceDuplication = 0;
    moveSpeed = 1 + (float)(0.8 * Math.random());
    aOverlappers = new Predator[0];
    dOverlappers = new Prey[0];
    xBump = yBump = 0;
    snackNum = 0;
    duplicationFactor = 1;
  }

  Predator(float x_, float y_, float lifetime_, float moveSpeed_, float duplicationFactor_) {
    this();
    x = x_;
    y = y_;
    lifetime = lifetime_;
    moveSpeed = moveSpeed_ + 0.1 + (float)((Math.random() - 0.5) * 0.4);
    duplicationFactor = duplicationFactor_ * ((float)Math.random() - 0.5) * 0.25;
  }
}
