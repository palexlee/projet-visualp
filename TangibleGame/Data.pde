class Data {
  PGraphics scorebox;
  PGraphics topView;
  PGraphics scoreboard;
  PGraphics barChart;
  float totalScore = 0;
  float score = 0;
  int delta = 2;
  int inc = 1;
  int scoredelta = 1;
  int widthgraph = width-380;
  float limit = 0;
  ArrayList<Integer> scoregraph = new ArrayList<Integer>();  
  Data() {
    scorebox = createGraphics(width, 200, P2D);
    topView = createGraphics(200, 200, P2D);
    scoreboard = createGraphics(160, 200, P2D);
    barChart = createGraphics(width - 360, 200, P2D);
  }
  
  void drawData() {
    inc += 1;
    drawScorebox();
    image(scorebox, 0, height-200);
    drawTopView();
    image(topView, 0, height-200);
    drawScoreBoard();
    image(scoreboard, 200, height-200);
    drawBarChart();
    image(barChart, 360, height - 200);
    hs.update();
    hs.display();
  }
  
  void drawScorebox() {
    scorebox.beginDraw();
    scorebox.noStroke();
    scorebox.fill(186, 252, 150);
    scorebox.rect(0, 0, width, 200);
    scorebox.endDraw();
  }
  
  void drawTopView() {
    float miniball = 4*resize(ball.ballRadius);
    PVector pos = remap(ball.location);
    topView.beginDraw();
    topView.noStroke();
    topView.fill(150, 194, 252);
    topView.rect(10, 10, 180, 180);
    topView.fill(203, 64, 64);
    topView.ellipse(10 + pos.x, 10 + pos.y, miniball, miniball);
    for(int i = 0; i < sh.size(); ++i) {
      PVector c = remap(sh.get(i));
      float smallinder = 2*resize(cylindreC.cylinderBaseSize);
      topView.pushMatrix();
      topView.fill(186, 252, 180);
      topView.ellipse(10 + c.x, 10 + c.y,  smallinder, smallinder);
      topView.popMatrix();
    }
    topView.endDraw();
  }  
  
  void drawScoreBoard() {
    float v = ball.velocity.mag();
    scoreboard.beginDraw();
    scoreboard.fill(186, 252, 150);
    scoreboard.stroke(255);
    scoreboard.strokeWeight(4);
    scoreboard.rect(10, 10, 140, 180);
    scoreboard.fill(0);
    scoreboard.textSize(17);
    scoreboard.text("Total Score\n" + totalScore, 20, 30);
    scoreboard.text("Velocity\n" + v, 20, 90);
    scoreboard.text("Last Score\n" + score, 20, 150);
    scoreboard.endDraw();
    if(inc % 60 == 0) {
      scoregraph.add(max(0, ceil(totalScore/scoredelta)));
    }
  }
  
  void drawBarChart() {
    barChart.beginDraw();
    barChart.noStroke();
    barChart.fill(209, 255, 183);
    barChart.rect(10, 10, widthgraph, 140);
    barChart.fill(0);
    float chartwidth = 8*hs.getPos();
    if(limit >= (widthgraph - chartwidth)) {
      scoregraph.remove(0);
      
    }
    
    limit = scoregraph.size() * (1 + chartwidth); 
    println(widthgraph + " " +limit);
    for(int i = 0; i < scoregraph.size() ; ++i) {
      for(int j = 0; j < scoregraph.get(i)/scoredelta; ++j) {
        
        barChart.rect(10 + i*(chartwidth + 1), max(10, 145 - j*5), chartwidth, 4);
      }
    }
    barChart.endDraw();
  }
}