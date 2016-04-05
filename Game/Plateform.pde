class Plateform {

  float rotX;
  float rotZ;
  float rotXSav;
  float rotZSav;
  float speed;
  
  float widthP, heightP, depthP;
  ArrayList<PVector> obstacles;
  private Cylinder cylindre;


  Plateform() {
    rotX = 0;
    rotZ = 0;
    rotXSav = 0;
    rotZSav = 0;
    speed = 1;
    widthP = 700;
    heightP = 700;
    depthP = 10;
    
    cylindre = new Cylinder(40, 80, 60);
    obstacles = new ArrayList<PVector>();                                         
  }
  
  Plateform(float widthP, float heightP, float depthP) {
    rotX = 0;
    rotZ = 0;
    rotXSav = 0;
    rotZSav = 0;
    speed = 1;
    this.widthP = widthP;
    this.heightP = heightP;
    this.depthP = depthP;
    
    cylindre = new Cylinder(50, 50, 60);
    obstacles = new ArrayList<PVector>();                                         
  }

  void display() {
    
    pushMatrix();
      rotateX(radians(rotX));
      rotateZ(radians(rotZ));
      
      fill(255, 255, 255);
      box(widthP, depthP, heightP);
      
      for(PVector obstacleCord : obstacles) {
        pushMatrix();
          rotateX(radians(90));
          translate(obstacleCord.x, obstacleCord.y, depthP/2);
          shape(cylindre.getCylinder());
        popMatrix();  
      }
    popMatrix();
    
  }
  
    
  void addCylindre(float x, float y) {
    obstacles.add(new PVector(x, y));
  }
  
  ArrayList<PVector> getObstacles() {
    return obstacles; 
  }
  
  void resetRotation() {
    rotX = 0;
    rotZ = 0;
  }
  
  void resetObstacles() {
    obstacles = new ArrayList<PVector>();
  }
  
  void reset() {
    rotX = 0;
    rotZ = 0;
    speed = 1;
    obstacles = new ArrayList<PVector>();
  }

  //EDITION MODE FONCTIONS
  
   private void saveRotation() {
    rotXSav = rotX;
    rotZSav = rotZ;
  }
  
  private void restoreRotation() {
    rotX = rotXSav;
    rotZ = rotZSav;
  }
  
  void editionMode() {
    saveRotation();
    rotX = -90;
    rotZ = 0;
  }
  
  void stopEditionMode() {
    restoreRotation();
  }


  //SETTERS AND GETTERS

  float getRotX() {
    return rotX;
  }
  
  float getRotZ() {
    return rotZ;
  }
  
  float getSpeed() {
    return speed;
  }
  
  float getWidth() {
    return widthP;
  }
  
  float getHeight() {
    return heightP;
  }
  
  float getDepth() {
    return depthP;
  }
  
  void setSpeed(float s) {
    speed = s;
    if (s < 0) {
       speed = 0;
    } else if (s > 6) {
       speed = 6;
    }
  }
  
  void setRotX(float x) {
    rotX = x;
    
    if (rotX > 60) {
      rotX = 60;
    } else if (rotX < -60) {
      rotX = -60;
    }
  }
  
  void setRotZ(float z) {
    rotZ = z;
    
    if (rotZ > 60) {
      rotZ = 60;
    } else if (rotZ < -60) {
      rotZ = -60;
    }
  }
  
 

}