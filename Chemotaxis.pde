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
