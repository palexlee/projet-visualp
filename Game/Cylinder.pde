class Cylinder {
  
  float cylinderBaseSize;
  float cylinderHeight;
  int cylinderResolution;
  PShape cylindre;
  PShape openCylinder;
  PShape top;
  PShape bottom;
  float[] colorC = new float[4];
  float alpha;
  
  Cylinder(float baseC, float heightC, int resolutionC) {
    cylinderBaseSize = baseC;
    cylinderHeight = heightC;
    cylinderResolution = resolutionC;
    alpha = 255;
    
    createCylinder();    
  }
  
  Cylinder(float baseC, float heightC, int resolutionC, float alpha) {
    this(baseC, heightC, resolutionC);
    this.alpha = alpha;
    
    createCylinder();
  }
  
  Cylinder() {
    this(40.0, 80.0, 60);
  }
  
  private void createCylinder() {
    
    cylindre = new PShape();
    openCylinder = new PShape();
    top = new PShape();
    bottom = new PShape();
  
    noStroke();
    fill(250, 151, 166, alpha);
  
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    
    //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    
    /////////////////////////////////////////////////////////
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    
    //draw the border of the cylinder
    for(int i = 0; i < x.length; i++) {
     openCylinder.vertex(x[i], y[i] , 0);
     openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    openCylinder.endShape();
    
    ////////////////////////////////////////////////////////
    top = createShape();
    top.beginShape(TRIANGLE_FAN);
    top.vertex(0, 0, 0);
    
    //draw the border of the cylinder
    for(int i = 0; i < x.length; i++) {
    top.vertex(x[i], y[i] , 0);
    }
    
    top.endShape();
    
    ////////////////////////////////////////////////////////
    bottom = createShape();
    bottom.beginShape(TRIANGLE_FAN);
    bottom.vertex(0, 0, cylinderHeight);
    
    //draw the border of the cylinder
    for(int i = 0; i < x.length; i++) {
     bottom.vertex(x[i], y[i] , cylinderHeight);
    }
    
    bottom.endShape();
    
    /////////////////////////////////////////////////////
    
    cylindre = createShape(GROUP);
    cylindre.addChild(openCylinder);
    cylindre.addChild(top);
    cylindre.addChild(bottom);
    
    noStroke();
  }
  
  // FONCTIONS UTILES
  
  PShape getCylinder() {    
    return cylindre;
  }
  
  void setResolution(int resolution) {
     if (resolution > 2) {
        cylinderResolution = resolution; 
        createCylinder();
     }
  }
  
  int getResolution() {
     return cylinderResolution;
  }
  
  
  
}