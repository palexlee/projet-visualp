class ImageProcessing extends PApplet {

  boolean camera = false;
  boolean video = true;
  boolean manualHue = false;
  
  import processing.video.*;
  import java.util.Collections;
  import java.util.List;
  import java.util.Random;
  
  Capture cam;
  /*Capture to Movie in declaring the video class*/
  //Capture cam;
  Movie vid;

  
  HScrollbar scrollbar1;
  HScrollbar scrollbar2;
  
  PImage img;
  PImage result;
  PImage intermediate;
  
  QuadGraph graphT;
  HoughTransform houghT;
  TwoDThreeD twoDThreeD;
  
  ArrayList<PVector> selectedLines;
  ArrayList<PVector> intersections;
  
  float gaussianKernel[][] = {{9, 12, 9 }, 
    {12, 15, 12}, 
    {9, 12, 9 }}; 
  
  int fpsCount = 0;
  long t1, t2 = 0;
  int count = 1;
  
  void settings() {
    int w = 0;
    int h = 0;
    if (camera || video) {
      w = 2*640;
      h = 1*480;
    } else {
      w = 2*800;
      h = 600;
    }
  
    if (manualHue) {
      h += 40;
    }
  
    size(w, h);
  }
  
  void setup() {
    //frameRate(60);
  
    scrollbar1 = new HScrollbar(0, height-20, width, 20);
    scrollbar2 = new HScrollbar(0, height-40, width, 20);
  
    graphT = new QuadGraph();
    houghT = new HoughTransform();
    if (camera || video) {
      twoDThreeD = new TwoDThreeD(640, 480);
    } else {
      twoDThreeD = new TwoDThreeD(800, 600);
    }
  
  
  
    if (camera) {
  
      String[] cameras = Capture.list();
  
      if (cameras.length == 0) {
        println("There are no cameras available for capture.");
        exit();
      } else {
        println("Available cameras:");
  
        for (int i = 0; i < cameras.length; i++) {
          println(i+" -> "+cameras[i]);
        }
  
        cam = new Capture(this, cameras[0]);
        cam.start();
      }
  
      result = createImage(640, 480, ALPHA);
    } else if (video) {
      vid = new Movie(this, "C:/Users/yvesl/Documents/Processing/my_sketches/Game_and_image_processing/testvideo.mp4"); //Put the video in the same directory
      vid.loop();
      result = createImage(640, 480, ALPHA);
    }else {
      img = loadImage("C:/Users/yvesl/Documents/Processing/my_sketches/Game_and_image_processing/board1.jpg", "jpg");
      img.loadPixels();
      result = createImage(img.width, img.height, ALPHA);
    }
  
    if (camera || video) { 
      intermediate = createImage(640, 480, ALPHA);
    } else {
      intermediate = createImage(800, 600, ALPHA);
    }
  }
  
  /////////////////////////////////////////////////////////////////////////////
  ////////////////                  DRAW          /////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  
  void draw() {
  
    background(0);
  
    if (camera) {
      if (cam.available() == true) {
        cam.read();
      }
  
      img = cam.get();
    } else if (video) {
      if (vid.available() == true) {
        vid.read();
      }
  
      img = vid.get();
    }else {
  
      chooseImage();
    }
  
    if (frameCount % 3 == 0) {
  
      result.loadPixels();  
      //(img, threshSaturation, threshBrightness, minHue, maxHue)
      result = prepareForSobel(img, 80, 25, 95, 140);
      result.updatePixels();
      
      result.loadPixels();  
      result = convolute(result, gaussianKernel);
      result.updatePixels();
      
      result.loadPixels(); 
      result = intensityThresholding(result, 185);
      result.updatePixels();
   
      result.loadPixels(); 
      result = sobel(result);
      result.updatePixels();
      intermediate = result.copy();
     
    }
  
    selectedLines = houghT.hough(result, 4, 75);
    
    image(img, 0, 0);
    
    drawLines(selectedLines, img);
    
    if (camera || video) {
      image(intermediate, 640, 0);
    } else {
      image(intermediate, 800, 0);
    }
    
  
    graphT.build(selectedLines, result.width, result.height);
    graphT.displayQuad(graphT.findCycles(), selectedLines);
    intersections = getIntersections(selectedLines);
    drawIntersections(intersections);
  
   /* if (manualHue) {
      imgproc.scrollbar1.update();
      imgproc.scrollbar1.display();
  
      imgproc.scrollbar2.update();
      imgproc.scrollbar2.display();
    }*/
  
    /*if (frameCount % 10 == 0) {
      println("framerate = "+frameRate);
    }*/
  }
  
  PVector getRotation() {
    
    if (graphT != null && graphT.rotations != null) {
      return graphT.rotations;
    } else {
      return null;
    }
    
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
  
    color pixelValue = (int)(0);
  
    for (int i = 0; i < img.width * img.height; i++) {
      pixelValue = img.pixels[i];
  
      pixelValue = tresholdTozeroSaturation(pixelValue, threshSaturation);
      pixelValue = tresholdTozeroBrightness(pixelValue, threshBrightness);
  
      if (manualHue) {
        if (hue(pixelValue) > scrollbar1.getPos()*255 && hue(pixelValue) < scrollbar2.getPos()*255) {
          result.pixels[i] = color(255);
        } else {
          result.pixels[i] = 0;
        }
      } else {
        if (hue(pixelValue) > minHue && hue(pixelValue) < maxHue) {
          result.pixels[i] = color(255);
        } else {
          result.pixels[i] = 0;
        }
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
  
      if (brightness(img.pixels[i]) > threshold) {
        result.pixels[i] = color(255);
      } else {
        result.pixels[i] = 0;
      }
    }
  
    return result;
  }
  
  color tresholdTozeroSaturation(color pixel, float threshold) {
    if (saturation(pixel) > threshold) {
      return pixel;
    } else {
      return 0;
    }
  }
  
  color truncateSaturation(color pixel, float threshold) {
    if (saturation(pixel) > threshold) {
      return 0;
    } else {
      return pixel;
    }
  }
  
  color tresholdTozeroBrightness(color pixel, float threshold) {
    if (brightness(pixel) > threshold) {
      return pixel;
    } else {
      return 0;
    }
  }
  
  color truncateBrightness(color pixel, float threshold) {
    if (brightness(pixel) > threshold) {
      return 0;
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
        count = ((count) % 4) + 1; 
  
        switch (count) {
        case 1 :
          img = loadImage("C:/Users/yvesl/Documents/Processing/my_sketches/Game_and_image_processing/board1.jpg", "jpg");
          break;
        case 2 :
          img = loadImage("C:/Users/yvesl/Documents/Processing/my_sketches/Game_and_image_processing/board2.jpg", "jpg");
          break;
        case 3 :
          img = loadImage("C:/Users/yvesl/Documents/Processing/my_sketches/Game_and_image_processing/board3.jpg", "jpg");
          break;
        case 4 :
          img = loadImage("C:/Users/yvesl/Documents/Processing/my_sketches/Game_and_image_processing/board4.jpg", "jpg");
          break;
        default:
          break;
        }
      }
    }
  }


  PImage convolute(PImage img, float kernel[][]) {
    
    //int N = kernel.length;
    int N = 3;
  
    /*float weight = 0.f;
     for (int k = 0; k < N; k++) {
     for (int l = 0; l < N; l++) {
     weight += kernel[l][k];
     }
     }*/
  
    float weight = 99;
  
  
    // create a greyscale image (type: ALPHA) for output
    PImage result = createImage(img.width, img.height, ALPHA);
  
    // kernel size N = 3
    //
    // for each (x,y) pixel in the image:
    // - multiply intensities for pixels in the range
    // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
    // corresponding weights in the kernel matrix
    // - sum all these intensities and divide it by the weight
    // - set result.pixels[y * img.width + x] to this value
    int sum = 0;
  
    for (int j = N/2; j<img.height-N/2; j++) {
      for (int i = N/2; i<img.width-N/2; i++) {
        sum = 0;
        for (int k = 0; k < N; k++) {
          for (int l = 0; l < N; l++) {
            sum += brightness(img.pixels[(j + l - N/2)*img.width+(i + k - N/2)])*kernel[l][k];
          }
        }
  
        result.pixels[j*img.width+i] = color(sum/weight);
      }
    }
  
    return result;
  } 
  
  private final float[][] hKernel = { { 0,  1, 0}, 
                                      { 0,  0, 0}, 
                                      { 0, -1, 0} };
  
  private final float[][] vKernel = { { 0, 0,  0}, 
                                      { 1, 0, -1}, 
                                      { 0, 0,  0} };
    
  
  PImage sobel(PImage img) {
  
    PImage result = createImage(img.width, img.height, ALPHA);
  
    // clear the image
    /*for (int i = 0; i < img.width * img.height; i++) {
     result.pixels[i] = color(0);
     }*/
  
    float max=0;
    float[] buffer = new float[img.width * img.height];
  
    // *************************************
    // Implement here the double convolution
    // *************************************
  
    int sumv = 0;
    int sumh = 0;
    float sum = 0;
  
    for (int j = 1; j<img.height-1; j++) {
      for (int i = 1; i<img.width-1; i++) {
        sumh = 0;
        sumv = 0;
        sum = 0;
        for (int k = 0; k < 3; k++) {
          for (int l = 0; l < 3; l++) {
            sumh += brightness(img.pixels[(j + (l - 1))*img.width+(i + (k - 1))])*hKernel[l][k];
            sumv += brightness(img.pixels[(j + (l - 1))*img.width+(i + (k - 1))])*vKernel[l][k];
          }
        }
  
        sum = sqrt(sumh*sumh + sumv*sumv);
  
        buffer[(j)*img.width+(i)] = sum;
  
        if (sum > max) {
          max = sum;
        }
      }
    }
  
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
          result.pixels[y * img.width + x] = color(255);
        } else {
          result.pixels[y * img.width + x] = 0;
        }
      }
    }
  
    return result;
  }

}