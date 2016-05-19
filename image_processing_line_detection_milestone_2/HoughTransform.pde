class HoughTransform {
  
  float discretizationStepsPhi = 0.04f;
  float discretizationStepsR = 2.5f;  
  
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  
  public HoughTransform() {
    
    optimize();
    
  }
  
  void optimize() {
    
    //Optimization
    // pre-compute the sin and cos values
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
  }
  
  ArrayList<PVector> hough(PImage edgeImg, int nLines, int minVotes) {
  
    // dimensions of the accumulator
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
    
  
    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  
    int rd = 0;
  
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator with something like: r += (rDim - 1) / 2
          for (int i = 0; i<phiDim; i++) {
  
            rd = floor(x*tabCos[i] + y*tabSin[i]);
            rd += (rDim - 1) / 2;
            accumulator[(i+1) * (rDim + 2) + rd + 2] += 1;
          }
        }
      }
    }
  
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
     
     PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
     for (int i = 0; i < accumulator.length; i++) {
       houghImg.pixels[i] = color(min(255, accumulator[i]));
     }
     // You may want to resize the accumulator to make it easier to see:
     houghImg.resize(400, 600);
     houghImg.updatePixels();
     image(houghImg, 800, 0);
     
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
  
    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    ArrayList<PVector> selectedLinesTemp = new ArrayList<PVector>();
  
    // size of the region we search for a local maximum
    int neighbourhood = 10;
  
    // only search around lines with more that this amount of votes
    // (to be adapted to your image)
    //defined in params
    
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
  
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
  
        if (accumulator[idx] > minVotes) {
  
          boolean bestCandidate=true;
          // iterate over the neighbourhood
  
          for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            // check we are not outside the image
            if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
  
            for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
  
              // check we are not outside the image
              if (accR+dR < 0 || accR+dR >= rDim) continue;
  
              int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
  
              if (accumulator[idx] < accumulator[neighbourIdx]) {
                // the current idx is not a local maximum!
                bestCandidate=false;
                break;
              }
            }
  
            if (!bestCandidate) break;
          }
  
          if (bestCandidate) {
            // the current idx *is* a local maximum
            bestCandidates.add(idx);
          }
        }
      }
    }
  
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  
    int idx = 0;
    int limit = min(bestCandidates.size(), nLines);
    
    for (int i = 0; i < limit; i++) {
      idx = bestCandidates.get(i);
  
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim+2)) - 1;
      int accR = idx - (accPhi+1) * (rDim+2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
  
      selectedLinesTemp.add(new PVector(r, phi));
  
    }
  
    return selectedLinesTemp;
  }

  
}