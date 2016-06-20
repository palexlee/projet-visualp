class DataSurface {
  
  private PGraphics backgroundSurface;
  private PGraphics topView;
  private PGraphics scoreBoard;
  private PGraphics scoreGraph;
  
  private int padding = 10;
  private int heightSurface = height/5;
  private int widthTopView = heightSurface - 2*padding;
  private int heightTopView = heightSurface - 2*padding;
  private int heightScoreBoard = heightSurface - padding;
  private int widthScoreBoard = width/10;
  
  private float sizeCube = (width/400);
  
  HScrollbar scrollBar;
  
  DataSurface() {
    backgroundSurface = createGraphics(width, heightSurface, P2D);
    topView = createGraphics(widthTopView, heightTopView, P2D); 
    scoreBoard = createGraphics(widthScoreBoard, heightScoreBoard, P2D);
    scoreGraph = createGraphics(5*width/7, height/4, P2D);
    scrollBar = new HScrollbar(widthTopView * 2 + 4*padding, (height-heightSurface) + 2*padding + ceil(score.maxTabScore*sizeCube), 5*width/7, 10);
}
  
  void drawSurface() {
     drawBackground();
     image(backgroundSurface, 0, height-heightSurface);
     drawTopView();
     image(topView, padding, (height-heightSurface) + padding);
     drawScoreBoard();
     image(scoreBoard, widthTopView + 3*padding, (height-heightSurface)+ padding/2);
     drawScoreGraph();
     image(scoreGraph, widthTopView * 2 + 4*padding, (height-heightSurface) + padding);
     scrollBar.update();
     
     scrollBar.display();
}
  
  void drawBackground() {
    backgroundSurface.beginDraw();
    backgroundSurface.background(219, 208, 156);
    backgroundSurface.endDraw();
  }
  
  void drawTopView() {
    topView.beginDraw();
    topView.background(61, 148, 196);
    topView.noStroke();    

    topView.fill(250, 151, 166);
    for (PVector v: plateau.getObstacles()) {
       topView.ellipse((widthTopView/plateau.getWidth())*v.x + widthTopView/2,
                       (heightTopView/plateau.getHeight())*v.y + heightTopView/2,
                       (widthTopView/plateau.getWidth())*2*cylindreC.cylinderBaseSize,
                       (heightTopView/plateau.getHeight())*2*cylindreC.cylinderBaseSize);
    }
    
    topView.fill(255, 255, 255);
    topView.ellipse((widthTopView/plateau.getWidth())*ball.location.x + widthTopView/2,
                   (widthTopView/plateau.getWidth())*ball.location.z + heightTopView/2,
                   (widthTopView/plateau.getWidth())*2*ball.ballRadius,
                   (heightTopView/plateau.getHeight())*2*ball.ballRadius);

    topView.endDraw();
  }
  
  void drawScoreBoard() {
     scoreBoard.beginDraw();
     
     scoreBoard.fill(219, 208, 156);
     scoreBoard.stroke(255);
     scoreBoard.strokeWeight(4);
     scoreBoard.rect(0, 0, widthScoreBoard, heightScoreBoard);
     
     scoreBoard.fill(0);
     scoreBoard.textSize(12);
     scoreBoard.text("Total Score :\n\t"+score.getScore(), widthScoreBoard/10, heightScoreBoard/10 + padding/2);
     scoreBoard.text("\nVelocity :\n\t"+ball.velocity.mag(), widthScoreBoard/10, 3*heightScoreBoard/10 + padding/2);
     scoreBoard.text("\nLast Score :\n\t"+score.getLastPointsGained(), widthScoreBoard/10, 6*heightScoreBoard/10 + padding/2);
     
     scoreBoard.endDraw();
    
  }
  
  void drawScoreGraph() {
    if (score.isTimeToDraw()) {
      
      scoreGraph.beginDraw();
      
      int[] graph = score.getScoreTab();
      scoreGraph.stroke(255);
      scoreGraph.strokeWeight(0.5);
      
      
      for (int i = 0; i < graph.length; i++) {
        for (int j = 0; j < graph[i]; j++) {
            scoreGraph.fill(48, 106, 137);  
            scoreGraph.rect(i*sizeCube, (score.maxTabScore-j-1)*sizeCube, sizeCube, sizeCube);
        }
        for (int j = graph[i]; j < score.maxTabScore; j++) {
            scoreGraph.fill(240, 234, 203);  
            scoreGraph.rect(i*sizeCube, (score.maxTabScore-j-1)*sizeCube, sizeCube, sizeCube);
        }
      }
      
      scoreGraph.endDraw();
    }
  }
  
}  