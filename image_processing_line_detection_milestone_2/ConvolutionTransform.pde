class ConvolutionTransform { 
  
 public ConvolutionTransform() {}
  
 PImage convolute(PImage img, float kernel[][]) {
  
    //int N = kernel.length;
    int N = 3;
  
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
  
}