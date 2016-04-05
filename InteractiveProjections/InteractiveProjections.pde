void settings() {
  size (1000, 1000, P2D);
}

void setup() {
  frameRate(100);
}

private float scale = 1;

private float angleX = 0;
private float angleY = 0;

private float diffAngleX = 0.05;
private float diffAngleY = 0.05;

void draw() {
  
  background(255, 255, 255);
  My3DPoint eye = new My3DPoint(-500, -500, -5000);
  My3DPoint origin = new My3DPoint(0, 0, 0); //The first vertex of your cuboid
  My3DBox input3DBox = new My3DBox(origin, 100,100,300);
  
  
  KeyStroke();
  
  
  float[][] scaleM = scaleMatrix(scale, scale, scale);
  float[][] rotateX = rotateXMatrix(angleX);
  float[][] rotateY = rotateYMatrix(angleY);
  input3DBox = transformBox(input3DBox, scaleM);
  input3DBox = transformBox(input3DBox, rotateX);
  input3DBox = transformBox(input3DBox, rotateY);
  
  projectBox(eye, input3DBox).render();
  
}

void KeyStroke() {
  if(keyPressed && keyCode == UP) {
    angleX += diffAngleX;
  } else if (keyPressed && keyCode == DOWN) {
    angleX -= diffAngleX;
  } else if (keyPressed && keyCode == LEFT) {
    angleY += diffAngleY;
  } else if (keyPressed && keyCode == RIGHT) {
    angleY -= diffAngleY;
  }
}

void mouseDragged() {

  if (mouseY < pmouseY) {
    scale += 0.05; //<>//
  } else if( mouseY > pmouseY) {
    scale -= 0.05;
  }
}


//FONCTIONS DE MATRICES ET DE POINTS

My2DPoint projectPoint(My3DPoint eye, My3DPoint p) {
    float xProjected = eye.z*( (p.x - eye.x)/(eye.z - p.z) );
    float yProjected = eye.z*( (p.y - eye.y)/(eye.z - p.z) );
    
    return new My2DPoint(xProjected, yProjected);
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
    My2DPoint[] s = new My2DPoint[8];
    
    for (int i = 0; i<8 ; i++) {
      s[i] = projectPoint(eye, box.p[i]); 
    }
  
    return new My2DBox(s);  
}

float[] homogeneous3DPoint (My3DPoint p) {
  float[] result = {p.x, p.y, p.z , 1};
  return result;
}

float[][] rotateXMatrix(float angle) {
  return(new float[][] {{1, 0          , 0          , 0},
                        {0, cos(angle) , sin(angle) , 0},
                        {0, -sin(angle), cos(angle) , 0},
                        {0, 0          , 0          , 1}
                       }
    );
}
float[][] rotateYMatrix(float angle) {
   return(new float[][] { {cos(angle) , 0 , sin(angle) , 0},
                          {0          , 1 , 0          , 0},
                          {-sin(angle), 0 , cos(angle) , 0},
                          {0          , 0 , 0          , 1}
                         }
      );
}
float[][] rotateZMatrix(float angle) {
   return(new float[][] { {cos(angle), -sin(angle), 0 , 0},
                          {sin(angle), cos(angle) , 0 , 0},
                          {0         , 0          , 1 , 0},
                          {0         , 0          , 0 , 1}
                         }
      );
}
float[][] scaleMatrix(float x, float y, float z) {
  return(new float[][] {  {x, 0, 0, 0},
                          {0, y, 0, 0},
                          {0, 0, z, 0},
                          {0, 0, 0, 1}
                         }
      );
}
float[][] translationMatrix(float x, float y, float z) {
  return(new float[][] {  {1, 0, 0, x},
                          {0, 1, 0, y},
                          {0, 0, 1, z},
                          {0, 0, 0, 1}
                         }
      );
}

float[] matrixProduct(float[][] a, float[] b) {
   float[] result = new float[4]; //We assume 4x4 times 4 matrices
   float sum = 0;
   
   for (int i = 0; i<4; i++) {
     sum = 0;
     for (int j = 0; j<4; j++) {
       sum += a[i][j] * b[j];
     }  
     result[i] = sum;
   }
   
   return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  My3DPoint[] p = new My3DPoint[8];
  
  for (int i = 0; i<8; i++) {
     p[i] = euclidian3DPoint( matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])) );
  }
  
  return new My3DBox(p);
}

My3DPoint euclidian3DPoint (float[] a) {
  My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
  return result;
}