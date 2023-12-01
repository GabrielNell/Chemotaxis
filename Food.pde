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
