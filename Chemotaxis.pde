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
