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
