enum STATES {
  PLAY, CYLINDER
}

float reculCamera = 1000;
float hauteurCamera = 1000;

Plateform plateau;
Mover ball;
STATES mode = STATES.PLAY;
Cylinder cylindreC;
Data data;
ArrayList<PVector> sh;

HScrollbar hs;

void settings() {
  fullScreen(P3D, 1);
  //size(1200, 800, P3D);
}

void setup() {
  noStroke();
  frameRate(100);
  plateau = new Plateform();
  ball = new Mover();
  cylindreC = new Cylinder(20, 80, 60);
  sh = new ArrayList<PVector>();
 
  data = new Data();
  hs = new HScrollbar(370, height - 30, 400, 20);
}

void draw() {
  background(220);
  data.drawData();
  switch (mode) {

  case PLAY:
    perspective();
    camera(width/2, height/2 - hauteurCamera, reculCamera, width/2, height/2, 0, 0, 1, 0);

    directionalLight(50, 100, 125, 0, 1, -1);
    ambientLight(102, 102, 102);

    pushMatrix();
    rotateX(atan(hauteurCamera/reculCamera));

    float decalX1 = -700;
    float decalY1 = -500;
    float decalZ1 = 0;
    fill(255, 0, 0);
    textSize(20);
    text("speed = "+plateau.getSpeed(), width/2 + decalX1, height/2 + decalY1, decalZ1);
    text("rotX = "+plateau.getRotX(), width/2 + decalX1, height/2 + decalY1 + 50, decalZ1);
    text("rotZ = "+plateau.getRotZ(), width/2 + decalX1, height/2 + decalY1 + 100, decalZ1);
    text("mode = "+mode.toString(), width/2 + decalX1, height/2 + decalY1 + 150, decalZ1);

    popMatrix(); 
    break;

  case CYLINDER:
    ortho();
    camera(width/2, height/2, 300, width/2, height/2, 0, 0, 1, 0);

    directionalLight(50, 100, 125, 0, 0, -1);
    ambientLight(102, 102, 102);

    pushMatrix();
    // rotateX(atan(hauteurCamera/reculCamera));
    float decalX = -575;
    float decalY = -375;
    float decalZ = 0;
    fill(255, 0, 0);
    textSize(20);
    text("speed = "+plateau.getSpeed(), width/2 + decalX, height/2 + decalY, decalZ);
    text("mouseX = "+mouseX, width/2 + decalX, height/2 + decalY + 50, decalZ);
    text("mouseY = "+mouseY, width/2 + decalX, height/2 + decalY + 100, decalZ);
    text("mode = "+mode.toString(), width/2 + decalX, height/2 + decalY + 150, decalZ);
    popMatrix(); 

    pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(radians(90));
    rotateX(radians(plateau.rotX));
    rotateY(radians(plateau.rotZ));

    translate(mouseX - width/2, mouseY - height/2, 4);
    shape(cylindreC.getCylinder());

    popMatrix();
    break;
  default: 
    break;
  }

  pushMatrix();
  translate(width/2, height/2, 0);

  plateau.display();

  ball.update();
  ball.checkEdges();
  ball.checkCylinderCollision();
  ball.display();

  fill(100, 100, 100, 100);
  box(plateau.widthP, plateau.depthP/4, plateau.heightP);

  popMatrix();

  //if(mode == STATES.PLAY) {
  camera();
  noLights();
  
  //}

}

void mouseClicked() {
  if (mode == STATES.CYLINDER) {

    float posx;
    float posy;

    // clamp the cylinder positions to the edges
    if (mouseX < width/2 - plateau.getWidth()/2) {
      posx = width/2 - plateau.getWidth()/2;
    } else if (mouseX > width/2 + plateau.getWidth()/2) {
      posx = width/2 + plateau.getWidth()/2;
    } else {
      posx = mouseX;
    }

    if (mouseY < height/2 - plateau.getHeight()/2) {
      posy = height/2 - plateau.getHeight()/2;
    } else if (mouseY >  height/2 + plateau.getHeight()/2) {
      posy =  height/2 + plateau.getHeight()/2;
    } else {
      posy = mouseY;
    }


    plateau.addCylindre(posx-width/2, posy-height/2);
  }
}

void mouseDragged() {

  switch (mode) {
  case PLAY:
    if(!hs.locked){
      if (pmouseY > mouseY) {
        plateau.setRotX(plateau.getRotX() + plateau.getSpeed());
      } else if (pmouseY < mouseY ) {
        plateau.setRotX(plateau.getRotX() - plateau.getSpeed());
      }
  
      if (pmouseX > mouseX) {
        plateau.setRotZ(plateau.getRotZ() - plateau.getSpeed());
      } else if (pmouseX < mouseX ) {
        plateau.setRotZ(plateau.getRotZ() + plateau.getSpeed());
      }
      break;
    }
  case CYLINDER : 
    break;
  default: 
    break;
  }
}

void mouseWheel(MouseEvent event) {
  if (event.getCount() > 0) {
    plateau.setSpeed(plateau.getSpeed() - 0.2);
    cylindreC.setResolution(cylindreC.getResolution() + 1);
  } else if (event.getCount() < 0) {
    plateau.setSpeed(plateau.getSpeed() + 0.2);
    cylindreC.setResolution(cylindreC.getResolution() - 1);
  }
}

void keyPressed() {
  if (key == CODED) {
    switch (keyCode) {
    case UP:
      reculCamera -= 50;
      break;
    case DOWN:
      reculCamera += 50;
      break;
    case LEFT:
      plateau.setSpeed(plateau.getSpeed() - 0.2);
      break;
    case RIGHT:
      plateau.setSpeed(plateau.getSpeed() + 0.2);
      break;
    case SHIFT:
      mode = STATES.CYLINDER;
      plateau.editionMode();
      break;
    default: 
      break;
    }
  } else {
    switch (key) {
    case 'r':
      plateau.reset();
      break;
    case 'f':
      ball.accelerateBall();
      break;
    case 'g':
      ball.deccelerateBall();
      break;
    default: 
      break;
    }
  }
}

PVector remap(PVector coor) {
  PVector pos = new PVector(0, 0);
  pos.x = resize(coor.x + plateau.widthP/2);
  pos.y = resize(coor.z + plateau.heightP/2);
  return pos;
}

float resize(float x) {
  return x / max(plateau.widthP, plateau.heightP) * 180;
}

void keyReleased() {
  if (key == CODED) {
    switch (keyCode) {
    case SHIFT:
      mode = STATES.PLAY;
      plateau.stopEditionMode();
      break;
    }
  }
}