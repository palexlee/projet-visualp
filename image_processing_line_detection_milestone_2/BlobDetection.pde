import java.awt.Polygon; 
import java.util.ArrayList; 
import java.util.List; 
import java.util.SortedSet; 
import java.util.TreeSet;
import java.util.Random;

class BlobDetection {
  
  Polygon quad = new Polygon();
  
  /** Create a blob detection instance with the four corners of the Lego board. */ 
  BlobDetection(PVector c1, PVector c2, PVector c3, PVector c4) { 
    
    quad.addPoint((int) c1.x, (int) c1.y); 
    quad.addPoint((int) c2.x, (int) c2.y); 
    quad.addPoint((int) c3.x, (int) c3.y); 
    quad.addPoint((int) c4.x, (int) c4.y); 
  }
  /** Returns true if a (x,y) point lies inside the quad */ 
  boolean isInQuad(int x, int y) {
    return quad.contains(x, y);
  }
  
  PImage findConnectedComponents(PImage input){
    
    // First pass: label the pixels and store labels’ equivalences
    int [] labels= new int [input.width*input.height]; 
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
    labelsEquivalences.add(new TreeSet<Integer>());
    int currentLabel=0;
    int tmpLabel = currentLabel;
    
    float lastHue = 0;
    
    int hueThres = 6;
    for(int i = 0; i < input.width * input.height; ++i) {
        if(isInQuad(i % input.width, i / input.width)) {
          float currentHue = hue(input.pixels[i]);
          
          if(currentLabel == 0 ||currentHue < lastHue - hueThres || currentHue > lastHue + hueThres) {
            currentLabel = tmpLabel;
            tmpLabel += 1;
            
            labelsEquivalences.add(new TreeSet<Integer>());
            labelsEquivalences.get(currentLabel).add(currentLabel);
          }
          
          List<Integer> points = Arrays.asList(i -input.width - 1,
                                           i -input.width,
                                           i -input.width + 1,
                                           i - 1);
          if(i <= input.width) {
            points.set(0, i);
            points.set(1, i);
            points.set(2, i);
          }
          
          if(i % input.width == 0) {
            points.set(3, i);
          }
          
          for(Integer p : points) {
            if(currentHue > hue(input.pixels[p]) - hueThres && currentHue < hue(input.pixels[p]) + hueThres){
              
              if(labels[p] != 0) {
                labelsEquivalences.get(currentLabel).add(labels[p]);
                labelsEquivalences.get(labels[p]).add(currentLabel);
              }
              
              if(labels[p] != 0 && labels[p] < currentLabel) {
                currentLabel = labels[p];
              }
            }
          }
          labels[i] = currentLabel;
          lastHue = currentHue;
        }
    }
     println("size " + labelsEquivalences.size());
     println(input.width * input.height);
    // TODO!
    // Second pass: re-label the pixels by their equivalent class
    for(int i = 0; i < img.width * img.height; ++i) {
      if(labels[i] != 0)  {
        labels[i] = labelsEquivalences.get(labels[i]).first();
      }
    }
    
    PImage output = createImage(img.width, img.height, ALPHA);
    // TODO!
    // Finally, output an image with each blob colored in one uniform color.
    currentLabel = -1;
    color lastColor = 0;
    for(int i = 0; i < input.width*input.height; ++i) {
       //if(labels[i] != currentLabel) {
         lastColor = color(255-3*labels[i]%255, labels[i]%255, 255-labels[i]%255, 150);
         //currentLabel = labels[i];
       //}
       output.pixels[i] = lastColor;
    }
    
    // TODO!
    return output;
  }
}