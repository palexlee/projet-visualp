class SobelTransform {
  
  private final float[][] hKernel = { { 0, 1, 0}, 
                                      { 0, 0, 0}, 
                                      { 0, -1, 0} };

  private final float[][] vKernel = { { 0, 0, 0}, 
                                      { 1, 0, -1}, 
                                      { 0, 0, 0} };
  
  public SobelTransform() {}
  
  PImage sobel(PImage img) {
  
    PImage result = createImage(img.width, img.height, ALPHA);
  
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
          result.pixels[y * img.width + x] = color(0);
        }
      }
    }
  
    return result;
  }
}