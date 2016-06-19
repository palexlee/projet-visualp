class ScoreObject {
 
  private float score;
  private float lastPointsGained;
  private float time;
  
  int maxTabTime;
  int maxTabScore;
  private int indexTab;
  private int[] tabScore;
  
  private int discreteScore;
  private int scoreRatio = 5;
  
  private boolean timeToDraw;
  
  ScoreObject() {
   score = 0;
   lastPointsGained = 0;
   time = 0;
   
   indexTab = 0;
   maxTabTime = 600;
   maxTabScore = 40;
   tabScore = new int[maxTabTime];
   
   timeToDraw = true;
   
  }
  
  void timeGoesOn() {
    time += 0.05;
    updateScoreTab();
  }
  
  boolean isTimeToDraw() {
    if(timeToDraw) {
      timeToDraw = false;
      return true;
    } else {
       return false; 
    }
  }
  
  void updateScoreTab() {
    if (floor(time) > indexTab && indexTab < maxTabTime && indexTab >= 0) {
      
      discreteScore = ceil(score/scoreRatio) - 1;
      
      while(discreteScore >= maxTabScore) {
        scoreRatio += 1;
        discreteScore = ceil(score/scoreRatio) - 1;
      }
      
      if (discreteScore > 0) {
         tabScore[indexTab] = discreteScore;
      } else {
         tabScore[indexTab] = 0;
      }
      
      indexTab += 1;
      timeToDraw = true;
    }
    
  }
  
  int[] getScoreTab() {
     return tabScore; 
  }
  
  void resetScore() {
   score = 0;
   lastPointsGained = 0;
   time = 0;
   
   tabScore = new int[maxTabTime];
  }
  
  void gainScoreCollision(PVector velocity) {
    lastPointsGained = velocity.mag();
    score += lastPointsGained;
  }
  
  void loseScoreCollision(PVector velocity) {
    lastPointsGained = -velocity.mag();
    score += lastPointsGained;
  }
  
  float getScore() {
    return score;
  }
  
  float getLastPointsGained() {
    return lastPointsGained;
  }
  
}