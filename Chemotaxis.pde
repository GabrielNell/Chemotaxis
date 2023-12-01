int nBacteria = 500;
int nFood = 10;
int livingFood = nFood;
boolean foodLeft = true;
Bacterium [] colony;
Food [] noms; // don't question the name

void setup() {
  size(1200, 700);
  noStroke();
  colony = new Bacterium[nBacteria]; // array of bacteria & array of foods
  noms = new Food[nFood];
  for (int i = 0; i < colony.length; i++) { // make the bacteria
    colony[i] = new Bacterium();
  }
  for (int i = 0; i < noms.length; i++) { // make the foods
    noms[i] = new Food();
  }
}


void draw() {
  background(255);
  
  stroke(1);
  for (int i = 0; i < noms.length; i++) { // loop food functions if alive
    if (noms[i].alive) {
      noms[i].show();
      noms[i].beEaten();
      noms[i].die();
    }
  }
  
  noStroke();
  for (int i = 0; i < colony.length; i++) {
    if (colony[i].dead == false) { // only run these if the bacteria is either alive or running its death animation
      if (colony[i].alive) { // don't move while running death animation
        colony[i].move();
      }
      colony[i].show();
      colony[i].die();
    }
  }
  
  if (livingFood == 0) { // check if food exists
    foodLeft = false;
  }
}

void mouseClicked() { // teleport food if click mouse because why not
  for (int i = 0; i < noms.length; i++) {
    noms[i].tele();
  }
}

class Bacterium { 
  float x, y, fDist1, fDist2, foodX, foodY, lifetime, initialLife, diameter, initDiameter, angleToFood;
  color colour;
  int randomnessMult; 
  boolean alive, dead;
  int diam2; // not directly related to bacteria but used for cosmetic purposes later
  
  void move() {
    if (foodLeft) { // only move toward food if there is still food
      findNearestFood();
      angleToFood = acos((foodX - x) / fDist2); // calculate angle towards food
      if (foodY >= y) {
        angleToFood = -1 * angleToFood; // inverse trigs are annoying
      }
      x += 0.5*cos(angleToFood); 
      y -= 0.5*sin(angleToFood); // negative here b/c cartesian coords in math are different from programmer coords
    }
    
    x += ((Math.random() - 0.5) * randomnessMult); // random walk
    y += ((Math.random() - 0.5) * randomnessMult);
  }
  
  void show() {
    fill(colour);
    ellipse(x, y, diameter, diameter); // show bacteria
    if (eating()) { // lose life if not eating, gain if eating
      lifetime += 1;
    } else {
      lifetime -= 1;
    }
    if (alive) { // diameter decreases with lifetime to a minimum
      diameter = 10 * lifetime / initialLife + initDiameter;
    }
  }
  
  void findNearestFood() {
    for (int i = 0; i < noms.length; i++) {
      if (noms[i].alive == true) {
        if (sqrt((noms[i].x - x) * (noms[i].x - x) + (noms[i].y - y) * (noms[i].y - y)) < fDist1) { // pythagorean theorem for distance btwn food and bacteria
          fDist1 = sqrt((noms[i].x - x) * (noms[i].x - x) + (noms[i].y - y) * (noms[i].y - y));
          foodX = noms[i].x;
          foodY = noms[i].y;
        }
      }
      fDist2 = fDist1; // save distance value to be used elsewhere
    }
    fDist1 = 99999; // reset for next loop
  }
  
  void die() {
    if (lifetime <= 0) {
      alive = false;
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
  
  boolean eating() { // check if bacteria in contact with food (which is when it eats)
    if (fDist2 < (diameter + noms[0].diameter)/2 && foodLeft) {
      return true;
    } else {
      return false;
    }
  }
  
  Bacterium() {
    x = (int)(width*Math.random());
    y = (int)(height*Math.random());
    colour = color(100, (int)(256*Math.random()), 150);
    initDiameter = 15;
    diameter = 10 * lifetime / initialLife + initDiameter;
    randomnessMult = 7;
    initialLife = 300;
    lifetime = initialLife + 150 * (float)Math.random();
    alive = true;
    dead = false;
    fDist1 = fDist2 = 99999; // arbitrarily chosen large number
  }
}

class Food {
  int x, y, numEating;
  float lifetime, distance;
  int diameter;
  boolean alive;
  
  void tele() { // teleport food because food teleports
    x = (int)(width * Math.random());
    y = (int)(height * Math.random());
  }
  
  void show() {
    fill(230, 206, 160); // tan-ish color
    ellipse(x, y, diameter, diameter);
  }
  
  void beEaten() { // check if in contact with bacteria (to see if the bacteria is eating it)
    for (int i = 0; i < colony.length; i++) {
      distance = sqrt((colony[i].x - x) * (colony[i].x - x) + (colony[i].y - y) * (colony[i].y - y));
      if (distance < ((diameter + colony[i].diameter)/2)) {
        numEating += 1;
      }
    }
    lifetime -= numEating; // lifetime decreases proportional to number of bacteria eating it
    numEating = 0; // reset so food doesn't take exponential damage over time
  }
  
  void die() { 
    if (lifetime <= 0) {
      alive = false;
      livingFood -= 1;
    }
  }
  
  Food() {
    x = (int)(width*Math.random());
    y = (int)(height*Math.random());
    lifetime = 7500; // remember this will update every 30th of a second so must be large number
    numEating = 0;
    diameter = 40;
    alive = true;
  }
}
