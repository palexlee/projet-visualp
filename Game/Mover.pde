class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  PVector friction;
   
  final float gravityConstant = 0.281;
  float normalForce;
  float mu;
  float frictionMagnitude;
  
  float coefRebond;
  
  float ballRadius;

  
  Mover() {
    ballRadius = 30;
    coefRebond = 0.9;
    
    normalForce = 1;
    mu = 0.02;
    frictionMagnitude = normalForce * mu;
    
    location = new PVector(0, -(ballRadius + plateau.getDepth()/2), 0);
    velocity = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);      
  }
  
  Mover(boolean fun) {
    ballRadius = 30;
    coefRebond = 1;
    
    normalForce = 1;
    mu = 0.00;
    frictionMagnitude = normalForce * mu;
    
    location = new PVector(-plateau.getWidth()/2, -(ballRadius + plateau.getDepth()/2), -plateau.getHeight()/2);
    velocity = new PVector(10, 0, 10);
    gravityForce = new PVector(0, 0, 0);      
  }
  
  void update() {
    
    if (mode == STATES.PLAY) {
      gravityForce.z = -sin(radians(plateau.getRotX())) * gravityConstant;
      gravityForce.x = sin(radians(plateau.getRotZ())) * gravityConstant;
      
      friction = velocity.copy();
      friction.mult(-1);
      friction.normalize();
      friction.mult(frictionMagnitude);
      
      velocity.add(friction);
      velocity.add(gravityForce);
      
      velocity.y = 0;
      
      location.add(velocity);
    }
    
  }
  
  void display() {
    pushMatrix();
      rotateX(radians(plateau.getRotX()));
      rotateZ(radians(plateau.getRotZ()));
      
      translate(location.x, location.y, location.z); //!!! y représente la hauteur !!!
      
      fill(255, 255, 255);
      sphere(ballRadius);
    popMatrix();
  }
  
  void stopBall() {
     velocity = new PVector(0, 0, 0);
     location = new PVector(0, -(ballRadius + plateau.getDepth()/2), 0);
  }
  
  void accelerateBall() {
     velocity.mult(1.1);
  }
  
  void deccelerateBall() {
     velocity.mult(0.9);
  }
  
  void checkEdges() {
    if (location.x > plateau.getWidth()/2) {
      velocity.x = -velocity.x*coefRebond;
      location.x = plateau.getWidth()/2;
    } else if (location.x < -plateau.getWidth()/2) {
      velocity.x = -velocity.x*coefRebond;
      location.x = -plateau.getWidth()/2;
    }
    
    if (location.z > plateau.getHeight()/2) {
      velocity.z = -velocity.z*coefRebond;
      location.z = plateau.getHeight()/2;
    } else if (location.z < -plateau.getHeight()/2) {
      velocity.z = -velocity.z*coefRebond;
      location.z = -plateau.getHeight()/2;
    }
    
  }
  
  void  checkCylinderCollision() {
    PVector destination = PVector.add(location, velocity);
    
    for (PVector obstacle : plateau.getObstacles()) {
      PVector obstacleOK = new PVector(obstacle.x, location.y, obstacle.y);
    
      if (PVector.dist(obstacleOK, destination) < 40 + ballRadius) {
        PVector normale = PVector.sub(obstacleOK, location).normalize();
        location = PVector.sub(obstacleOK, PVector.mult(normale, 40+ballRadius));         
        velocity = PVector.sub(velocity, normale.mult(normale.dot(velocity)).mult(2.0)).mult(coefRebond);
      }
     
    } 
    
  }
  
  
}