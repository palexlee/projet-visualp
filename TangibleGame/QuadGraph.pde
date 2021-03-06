import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.ArrayList;
import java.util.Arrays;

class QuadGraph {

  PVector rotations;
  List<int[]> cycles = new ArrayList<int[]>();
  int[][] graph;

  void build(List<PVector> lines, int width, int height) {

    int n = lines.size();

    // The maximum possible number of edges is n * (n - 1)/2
    graph = new int[n * (n - 1)/2][2];

    int idx =0;

    for (int i = 0; i < lines.size(); i++) {
      for (int j = i + 1; j < lines.size(); j++) {
        if (intersect(lines.get(i), lines.get(j), width, height)) {

          // TODO
          // fill the graph using intersect() to check if two lines are
          // connected in the graph.
		  graph[idx][0] = i;
          graph[idx][1] = j;

          idx++;
        }
      }
    }
  }

  /** Returns true if polar lines 1 and 2 intersect 
   * inside an area of size (width, height)
   */
  boolean intersect(PVector line1, PVector line2, int width, int height) {

    double sin_t1 = Math.sin(line1.y);
    double sin_t2 = Math.sin(line2.y);
    double cos_t1 = Math.cos(line1.y);
    double cos_t2 = Math.cos(line2.y);
    float r1 = line1.x;
    float r2 = line2.x;

    double denom = cos_t2 * sin_t1 - cos_t1 * sin_t2;

    int x = (int) ((r2 * sin_t1 - r1 * sin_t2) / denom);
    int y = (int) ((-r2 * cos_t1 + r1 * cos_t2) / denom);

    if (0 <= x && 0 <= y && width >= x && height >= y)
      return true;
    else
      return false;
  }

  List<int[]> findCycles() {

    cycles.clear();
    for (int i = 0; i < graph.length; i++) {
      for (int j = 0; j < graph[i].length; j++) {
        findNewCycles(new int[] {graph[i][j]});
      }
    }
    /*for (int[] cy : cycles) {
      String s = "" + cy[0];
      for (int i = 1; i < cy.length; i++) {
        s += "," + cy[i];
      }
      System.out.println(s);
    }*/
    return cycles;
  }

  void findNewCycles(int[] path)
  {
    int n = path[0];
    int x;
    int[] sub = new int[path.length + 1];

    for (int i = 0; i < graph.length; i++)
      for (int y = 0; y <= 1; y++)
        if (graph[i][y] == n)
          //  edge refers to our current node
        {
          x = graph[i][(y + 1) % 2];
          if (!visited(x, path))
            //  neighbor node not on path yet
          {
            sub[0] = x;
            System.arraycopy(path, 0, sub, 1, path.length);
            //  explore extended path
            findNewCycles(sub);
          } else if ((path.length == 4) && (x == path[path.length - 1]))
            //  cycle found
          {
            int[] p = normalize(path);
            int[] inv = invert(p);
            if (isNew(p) && isNew(inv))
            {
              cycles.add(p);
            }
          }
        }
  }
  
  void displayQuad(List<int[]> quads, List<PVector> lines) 
  {

    for (int[] quad : quads) {
      PVector l1 = lines.get(quad[0]);
      PVector l2 = lines.get(quad[1]);
      PVector l3 = lines.get(quad[2]);
      PVector l4 = lines.get(quad[3]);
  
      // (intersection() is a simplified version of the
      // intersections() method you wrote last week, that simply
      // return the coordinates of the intersection between 2 lines)
      PVector c12 = imgproc.getIntersection(l1, l2);
      PVector c23 = imgproc.getIntersection(l2, l3);
      PVector c34 = imgproc.getIntersection(l3, l4);
      PVector c41 = imgproc.getIntersection(l4, l1);
      
      //println(c12+" "+c23+" "+c34+" "+c41);
  
      if (isConvex(c12, c23, c34, c41) 
       && validArea(c12, c23, c34, c41, 1000000000, 0)
       )//&& nonFlatQuad(c12, c23, c34, c41)) 
      {
        // Choose a random, semi-transparent colour
        /*Random random = new Random();
         fill(color(min(255, random.nextInt(300)),
         min(255, random.nextInt(300)),
         min(255, random.nextInt(300)), 150));*/
        imgproc.fill(color(100, 
          255, 
          100, 150));
          
        rotations = imgproc.twoDThreeD.get3DRotations(sortCorners(Arrays.asList(c12, c23, c34, c41)));
  
        imgproc.quad(c12.x, c12.y, c23.x, c23.y, c34.x, c34.y, c41.x, c41.y);
      }
    }
  }

  //  check of both arrays have same lengths and contents
  Boolean equals(int[] a, int[] b)
  {
    Boolean ret = (a[0] == b[0]) && (a.length == b.length);

    for (int i = 1; ret && (i < a.length); i++)
    {
      if (a[i] != b[i])
      {
        ret = false;
      }
    }

    return ret;
  }

  //  create a path array with reversed order
  int[] invert(int[] path)
  {
    int[] p = new int[path.length];

    for (int i = 0; i < path.length; i++)
    {
      p[i] = path[path.length - 1 - i];
    }

    return normalize(p);
  }

  //  rotate cycle path such that it begins with the smallest node
  int[] normalize(int[] path)
  {
    int[] p = new int[path.length];
    int x = smallest(path);
    int n;

    System.arraycopy(path, 0, p, 0, path.length);

    while (p[0] != x)
    {
      n = p[0];
      System.arraycopy(p, 1, p, 0, p.length - 1);
      p[p.length - 1] = n;
    }

    return p;
  }

  //  compare path against known cycles
  //  return true, iff path is not a known cycle
  Boolean isNew(int[] path)
  {
    Boolean ret = true;

    for (int[] p : cycles)
    {
      if (equals(p, path))
      {
        ret = false;
        break;
      }
    }

    return ret;
  }

  //  return the int of the array which is the smallest
  int smallest(int[] path)
  {
    int min = path[0];

    for (int p : path)
    {
      if (p < min)
      {
        min = p;
      }
    }

    return min;
  }

  //  check if vertex n is contained in path
  Boolean visited(int n, int[] path)
  {
    Boolean ret = false;

    for (int p : path)
    {
      if (p == n)
      {
        ret = true;
        break;
      }
    }

    return ret;
  }



  /** Check if a quad is convex or not.
   * 
   * Algo: take two adjacent edges and compute their cross-product. 
   * The sign of the z-component of all the cross-products is the 
   * same for a convex polygon.
   * 
   * See http://debian.fmi.uni-sofia.bg/~sergei/cgsr/docs/clockwise.htm
   * for justification.
   * 
   * @param c1
   */
  boolean isConvex(PVector c1, PVector c2, PVector c3, PVector c4) {

    PVector v21= PVector.sub(c1, c2);
    PVector v32= PVector.sub(c2, c3);
    PVector v43= PVector.sub(c3, c4);
    PVector v14= PVector.sub(c4, c1);

    float i1=v21.cross(v32).z;
    float i2=v32.cross(v43).z;
    float i3=v43.cross(v14).z;
    float i4=v14.cross(v21).z;

    if (   (i1>0 && i2>0 && i3>0 && i4>0) 
      || (i1<0 && i2<0 && i3<0 && i4<0))
      return true;
    else 
    //System.out.println("Eliminating non-convex quad");
    return false;
  }

  /** Compute the area of a quad, and check it lays within a specific range
   */
  boolean validArea(PVector c1, PVector c2, PVector c3, PVector c4, float max_area, float min_area) {

    float i1=c1.cross(c2).z;
    float i2=c2.cross(c3).z;
    float i3=c3.cross(c4).z;
    float i4=c4.cross(c1).z;

    float area = Math.abs(0.5f * (i1 + i2 + i3 + i4));

    //System.out.println(area);

    boolean valid = (area < max_area && area > min_area);

    //if (!valid) System.out.println("Area out of range");

    return valid;
  }

  /** Compute the (cosine) of the four angles of the quad, and check they are all large enough
   * (the quad representing our board should be close to a rectangle)
   */
  boolean nonFlatQuad(PVector c1, PVector c2, PVector c3, PVector c4) {

    // cos(70deg) ~= 0.3
    float min_cos = 0.5f;

    PVector v21= PVector.sub(c1, c2);
    PVector v32= PVector.sub(c2, c3);
    PVector v43= PVector.sub(c3, c4);
    PVector v14= PVector.sub(c4, c1);

    float cos1=Math.abs(v21.dot(v32) / (v21.mag() * v32.mag()));
    float cos2=Math.abs(v32.dot(v43) / (v32.mag() * v43.mag()));
    float cos3=Math.abs(v43.dot(v14) / (v43.mag() * v14.mag()));
    float cos4=Math.abs(v14.dot(v21) / (v14.mag() * v21.mag()));

    if (cos1 < min_cos && cos2 < min_cos && cos3 < min_cos && cos4 < min_cos)
      return true;
    else {
      //System.out.println("Flat quad");
      return false;
    }
  }


  List<PVector> sortCorners(List<PVector> quad) {

    // 1 - Sort corners so that they are ordered clockwise
    PVector a = quad.get(0);
    PVector b = quad.get(2);

    PVector center = new PVector((a.x+b.x)/2, (a.y+b.y)/2);

    Collections.sort(quad, new CWComparator(center));



    // 2 - Sort by upper left most corner
    PVector origin = new PVector(0, 0);
    float distToOrigin = 1000;

    for (PVector p : quad) {
      if (p.dist(origin) < distToOrigin) distToOrigin = p.dist(origin);
    }

    while (quad.get(0).dist(origin) != distToOrigin)
      Collections.rotate(quad, 1);


    return quad;
  }
}

static class CWComparator implements Comparator<PVector> {

  PVector center;

  public CWComparator(PVector center) {
    this.center = center;
  }

  @Override
    public int compare(PVector b, PVector d) {
    if (Math.atan2(b.y-center.y, b.x-center.x)<Math.atan2(d.y-center.y, d.x-center.x))      
      return -1; 
    else return 1;
  }
}

public static List<PVector> sortCorners(List<PVector> quad){
  
  // Sort corners so that they are ordered clockwise
  PVector a = quad.get(0);
  PVector b = quad.get(2);
  PVector center = new PVector((a.x+b.x)/2,(a.y+b.y)/2);
  
  CWComparator comparator = new CWComparator(center);
  
  Collections.sort(quad,comparator);
  
  // TODO:
  // Re-order the corners so that the first one is the closest to the
  // origin (0,0) of the image.
  //
  // You can use Collections.rotate to shift the corners inside the quad.
  
  int indexRotate = 0;
  float minDistToOrigin = abs(PVector.dist(quad.get(0), new PVector(0, 0)));
  float temp = 0;
  
  for (int i = 1; i<4; i++) {
     temp = abs(PVector.dist(quad.get(i), new PVector(0, 0)));
     
     if (temp < minDistToOrigin) {
       minDistToOrigin = temp;
       indexRotate = i;
     }
     
  }
  
  Collections.rotate(quad, -indexRotate);
  
  return quad;
}