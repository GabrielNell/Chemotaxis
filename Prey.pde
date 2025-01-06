class Prey { 
  float x, y, a, lifetime, initialLife, diameter, initDiameter, xBump, yBump;
  float iDist1, iDist2, threatX, threatY, angleToThreat, numEating, distance, moveSpeed, regen;
  color colour;
  int randomnessMult, timeSinceDuplication, numTargeting;
  boolean alive, dead;
  int diam2; // not directly related to bacteria but used for cosmetic purposes later
  Predator [] iOverlappers;
  Prey [] aOverlappers;
  
  void move() {
    findNearestThreat();
    countOverlaps();
    angleToThreat = acos((threatX - x) / iDist2); // calculate angle towards food
    if (threatY >= y) {
      angleToThreat = -1 * angleToThreat; // inverse trigs are annoying
    }
    // angleToThreat += daring * 360 * neg;
    x -= moveSpeed*cos(angleToThreat); 
    y += moveSpeed*sin(angleToThreat);  
    x += xBump * 0.15;
    y += yBump * 0.15;
    
    //x += ((Math.random() - 0.5) * randomnessMult); // random walk
    //y += ((Math.random() - 0.5) * randomnessMult);
    locationRollover();
    if (lifetime <= 2 * initialLife) {
      lifetime += regen;
    }
    duplicate();
  }
  
  void show() {
    fill(colour);
    ellipse(x, y, diameter, diameter); // show bacteria
    if (alive) { // diameter decreases with lifetime to a minimum
      diameter = 10 * lifetime / initialLife + initDiameter;
    }
  }
  
  void findNearestThreat() {
    float deltaX, deltaY;
    for (int i = 0; i < invaders.length; i++) {
      deltaX = invaders[i].x - x;
      deltaY = invaders[i].y - y;
      if (invaders[i].alive == true) {
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
        
        if (sqrt(deltaX * deltaX + deltaY * deltaY) < iDist1) { // pythagorean theorem for distance btwn food and bacteria
          iDist1 = sqrt(deltaX * deltaX + deltaY * deltaY);
          threatX = deltaX + x;
          threatY = deltaY + y;
        }
      }
      iDist2 = iDist1; // save distance value to be used elsewhere
    }
    iDist1 = 99999; // reset for next loop
  }
  
  void countOverlaps() {
    xBump = yBump = 0;
    iOverlappers = new Predator[0];
    aOverlappers = new Prey[0];
    for (int i = 0; i < invaders.length; i++) {
      distance = sqrt((invaders[i].x - x) * (invaders[i].x - x) + (invaders[i].y - y) * (invaders[i].y - y));
      if (distance <= (diameter + invaders[i].diameter)/2) {
        iOverlappers = (Predator[])append(iOverlappers, invaders[i]);
      }
    }
    for (int i = 0; i < iOverlappers.length; i++) {
      xBump = (x - iOverlappers[i].x) * 0.1;
      yBump = (y - iOverlappers[i].y) * 0.1;
    }
    
    for (int i = 0; i < defenders.length; i++) {
      distance = sqrt((defenders[i].x - x) * (defenders[i].x - x) + (defenders[i].y - y) * (defenders[i].y - y));
      if (distance <= (diameter + defenders[i].diameter)/2) {
        aOverlappers = (Prey[])append(aOverlappers, defenders[i]);
      }
    }
    for (int i = 0; i < aOverlappers.length; i++) {
      xBump = (x - aOverlappers[i].x) * 0.5;
      yBump = (y - aOverlappers[i].y) * 0.5;
    }
  }
  
  void die() {
    if (lifetime <= 0 && alive) {
      alive = false;
      nPrey -= 1;
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
  
  void beEaten() { // check if in contact with bacteria (to see if the bacteria is eating it)
    for (int i = 0; i < invaders.length; i++) {
      distance = sqrt((invaders[i].x - x) * (invaders[i].x - x) + (invaders[i].y - y) * (invaders[i].y - y));
      if (distance < ((diameter + invaders[i].diameter)/2) && invaders[i].alive) {
        numEating += 1;
      }
    }
    lifetime -= 2 * numEating; // lifetime decreases proportional to number of bacteria eating it
    numEating = 0; // reset so food doesn't take exponential damage over time
  }
  
  void locationRollover() {
    if (x > width) {
      x -= width;
    } else if (x < 0) {
      x += width;
    }
    if (y > height) {
      y -= height;
    } else if (y < 0) {
      y += height;
    }
  }
  
  void duplicate() {
    if (lifetime >= initialLife * 2 && timeSinceDuplication >= frameRate && nPrey < maxPrey) {
      Prey filler = new Prey((float)(x + (Math.random() - 0.5) * 15), (float)(y + (Math.random() - 0.5) * 15), lifetime / 2, moveSpeed);
      defenders = (Prey[])append(defenders, filler);
      nPrey += 1;
      lifetime = lifetime / 2;
      timeSinceDuplication = 0;
    } else {
      timeSinceDuplication += 1;
    }
  }
  
  void debug() {
    if (x > width + 100 || x < -100) {
      alive = false;
    }
    if (y > height + 100 || y < -100) {
      alive = false;
    }
  }
  
  Prey() {
    x = (int)(width*Math.random());
    y = (int)(height*Math.random());
    a = 255;
    colour = color(75, 130 + (float)Math.random() * 125, 125, a);
    initDiameter = 15;
    diameter = 10 * lifetime / initialLife + initDiameter;
    randomnessMult = 4;
    initialLife = 300;
    lifetime = initialLife + 150 * (float)Math.random();
    alive = true;
    dead = false;
    iDist1 = iDist2 = 99999; // arbitrarily chosen large number
    timeSinceDuplication = 0;
    moveSpeed = 1.3 + (float)(0.7 * Math.random());
    // daring = (float)Math.random() * 0.3;
    // neg = -1;
    numTargeting = 0;
    iOverlappers = new Predator[0];
    aOverlappers = new Prey[0];
    xBump = yBump = 0;
    regen = 2;
  }
  
  Prey(float x_, float y_, float lifetime_, float moveSpeed_) {
    this();
    x = x_;
    y = y_;
    lifetime = lifetime_;
    moveSpeed = moveSpeed_ + (float)((Math.random() - 0.5) * 0.4);
  }
}
