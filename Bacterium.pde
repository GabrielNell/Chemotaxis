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
