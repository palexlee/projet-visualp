import java.util.Collections;
import java.util.List;

PImage img;
PImage result;
PImage intermediate;

QuadGraph graphT;
HoughTransform houghT;
SobelTransform sobelT;
ConvolutionTransform convolutionT;
TwoDThreeD projection;

BlobDetection blob;

ArrayList<PVector> selectedLines;

float gaussianKernel[][] = {{9, 12, 9 }, 
  {12, 15, 12}, 
  {9, 12, 9 }}; 

int count = 1;

void settings() {
  size(2*800 + 400, 600);
}

void setup() {
  frameRate(30);

  graphT = new QuadGraph();
  houghT = new HoughTransform();
  sobelT = new SobelTransform();
  convolutionT = new ConvolutionTransform();

  img = loadImage("board2.jpg");
  result = createImage(img.width, img.height, ALPHA);
  
  projection = new TwoDThreeD(img.width, img.height);

  intermediate = createImage(800, 600, ALPHA);
  
}

/////////////////////////////////////////////////////////////////////////////
////////////////                  DRAW          /////////////////////////////
/////////////////////////////////////////////////////////////////////////////

void draw() {
  noLoop();
  background(0);

  chooseImage();

  result.loadPixels();  
  result = prepareForSobel(img, 80, 25, 95, 140);
  result.updatePixels();
  PImage tmp = createImage(img.width, img.height, ALPHA);
  for(int i = 0; i< img.width*img.height; ++i) {
    tmp.pixels[i] = result.pixels[i];
  }

  result.loadPixels();  
  result = convolutionT.convolute(result, gaussianKernel);
  result.updatePixels();
  
  result.loadPixels(); 
  result = intensityThresholding(result, 185);
  result.updatePixels();
  

  result.loadPixels(); 
  result = sobelT.sobel(result);
  result.updatePixels();

  selectedLines = houghT.hough(result, 4, 150);
  
  graphT.build(selectedLines, result.width, result.height);
  graphT.displayQuad(graphT.findCycles(), selectedLines);
  
  
  image(img, 0, 0);
  drawLines(selectedLines, img);
  image(result, 800+400, 0);
  
  ArrayList<PVector> intersections = new ArrayList<PVector>(sortCorners(getIntersections(selectedLines)));
  drawIntersections(intersections);
  
  PVector rot = projection.get3DRotations(intersections);
  println("x : " + degrees(rot.x) + " y : " + degrees(rot.y) + " z : " + degrees(rot.z));
  
  //blob = new BlobDetection(intersections.get(0),intersections.get(1),intersections.get(2),intersections.get(3));
  //image(blob.findConnectedComponents(img), 0, 0);

}


/////////////////////////////////////////////////////////////////////////////
////////////////            DRAW_UTILITIES          /////////////////////////
/////////////////////////////////////////////////////////////////////////////

  
void drawIntersections(ArrayList<PVector> intersections) {
  
  for (PVector intersect : intersections) {
    // draw the intersection 
    stroke(255, 255, 0);
    fill(255, 255, 0);
    ellipse(intersect.x, intersect.y, 10, 10);
  }
  
}

void drawLines(ArrayList<PVector> lines, PImage edgeImg) {
  
    float r, phi;
  
    for (PVector line : lines) {
      
      r = line.x;
      phi = line.y;
      
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
  
      // Finally, plot the lines
      //stroke(204,102,0);
      stroke(255, 0, 0);
      strokeWeight(2);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
      
    }
  
}


/////////////////////////////////////////////////////////////////////////////
////////////////             INTERSECTIONS          /////////////////////////
/////////////////////////////////////////////////////////////////////////////
ArrayList<PVector> getIntersections(List<PVector> lines) {

  ArrayList<PVector> intersections = new ArrayList<PVector>();
  float d = 0f;
  int x = 0;
  int y = 0;

  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);

    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      // compute the intersection and add it to ’intersections’
      d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
      x = (int)((line2.x * sin(line1.y) - line1.x * sin(line2.y))/d);
      y = (int)((line1.x * cos(line2.y) - line2.x * cos(line1.y))/d);

      if (x > 0 && x < img.width && y > 0 && y < img.height) {
        intersections.add(new PVector(x, y));
      }
    }
  }

  return intersections;
}

PVector getIntersection(PVector line1, PVector line2) {

  float d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
  int x = (int)((line2.x * sin(line1.y) - line1.x * sin(line2.y))/d);
  int y = (int)((line1.x * cos(line2.y) - line2.x * cos(line1.y))/d);

  return new PVector(x, y);
}

/////////////////////////////////////////////////////////////////////////////
////////////////           PREPARE FOR SOBEL        /////////////////////////
/////////////////////////////////////////////////////////////////////////////

PImage prepareForSobel(PImage img, int threshSaturation, int threshBrightness, int minHue, int maxHue) {

  PImage result = createImage(img.width, img.height, ALPHA);

  color pixelValue = 0;

  for (int i = 0; i < img.width * img.height; i++) {
    pixelValue = color(img.pixels[i]);

    pixelValue = tresholdTozeroSaturation(pixelValue, threshSaturation);
    pixelValue = tresholdTozeroBrightness(pixelValue, threshBrightness);

    if (hue(pixelValue) > minHue && hue(pixelValue) < maxHue) {
      result.pixels[i] = color(255);
    } else {
      result.pixels[i] = color(0);
    }
  }

  return result;
}


/////////////////////////////////////////////////////////////////////////////
////////////////           DIFFERENT TREHSOLDINGS        ////////////////////
/////////////////////////////////////////////////////////////////////////////

PImage intensityThresholding(PImage img, float threshold) {

  PImage result = createImage(img.width, img.height, ALPHA);

  for (int i = 0; i < img.width * img.height; i++) {

    if (brightness(color(img.pixels[i])) > threshold) {
      result.pixels[i] = color(255);
    } else {
      result.pixels[i] = color(0);
    }
  }

  return result;
}

color tresholdTozeroSaturation(color pixel, float threshold) {
  if (saturation(pixel) > threshold) {
    return pixel;
  } else {
    return color(0);
  }
}

color truncateSaturation(color pixel, float threshold) {
  if (saturation(pixel) > threshold) {
    return color(0);
  } else {
    return pixel;
  }
}

color tresholdTozeroBrightness(color pixel, float threshold) {
  if (brightness(pixel) > threshold) {
    return pixel;
  } else {
    return color(0);
  }
}

color truncateBrightness(color pixel, float threshold) {
  if (brightness(pixel) > threshold) {
    return color(0);
  } else {
    return pixel;
  }
}

/////////////////////////////////////////////////////////////////////////////
////////////////                 UTILITIES               ////////////////////
/////////////////////////////////////////////////////////////////////////////

void chooseImage() {

  if (keyPressed) {
    if (keyCode == SHIFT) {
      count = ((count+1) % 5) + 1; 

      switch (count) {
      case 1 :
        img = loadImage("board1.jpg");
        break;
      case 2 :
        img = loadImage("board2.jpg");
        break;
      case 3 :
        img = loadImage("board3.jpg");
        break;
      case 4 :
        img = loadImage("board4.jpg");
        break;
      default:
        break;
      }
    }
  }
}