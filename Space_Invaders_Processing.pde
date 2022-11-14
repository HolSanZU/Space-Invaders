int WIDTH_ = 800;
int HEIGHT_ = 650;
Space spaceObj;
Ship shipObj;
Controls gameControls;
Bullets bulletsObj;
EnemyBullets enemeyBulletsObj;
Enemy enemyObj;
EnemyArmy armyObj; 
Score scoreObj;
PFont Akashi48;
PFont Akashi24;
PFont Akashi36;

void setup(){
  size(800,700);
  spaceObj = new Space();
  gameControls = new Controls();
  gameControls.restartGame();
  Akashi48 = createFont("Akashi", 48);
  Akashi36 = createFont("Akashi", 36);
  Akashi24 = createFont("Akashi", 28);
}

void draw(){
  if(gameControls.gameStatus == "inicio"){ 
    spaceObj.display();
    startScreen();
  }if(gameControls.gameStatus == "transport"){
    if(scoreObj.transportStart == 0)  scoreObj.setTransportStart();
    spaceObj.hyperDisplay(scoreObj.transportTime());
    levelDisplay();
    shipObj.display();
    if(scoreObj.transportDone()){
      gameControls.gameOn(); 
      scoreObj.clearTransport();
    }  
  } else if(gameControls.gameStatus == "on"){
    spaceObj.display();
    shipObj.display();
    bulletsObj.display();
    enemeyBulletsObj.display();
    armyObj.display();
    scoreObj.display();
  } else if(gameControls.gameStatus == "pause") pauseScreen();
  else if(gameControls.gameStatus == "lose") loseScreen();
  else if(gameControls.gameStatus == "win") winScreen();
}
class Bullets {
  PVector bullet;

  Bullets() { bullet = null; }

  void display() {
    if( bullet != null){
      rectMode(CENTER);
      fill(255, 255, 100);
      stroke(255, 255, 100);
      ellipse(bullet.x, bullet.y, 1, 5);
      movement();
    }
  } 

  void addBullet(PVector position) {
    bullet = new PVector( position.x, position.y -25);
  }

  void deleteBullet() {
    bullet = null;
  }
  
  void movement() {
    bullet = new PVector( bullet.x, bullet.y - 6 );
    if (bullet.y < 0) bullet = null;
  }
}
//Inicio donde se comeinzan a "mostrar" los controles a utilizar "Izquierda, Derecha y El disparo"
class Controls {
 boolean right; 
 boolean left;
 boolean gun;
 String gameStatus = "inicio";
 Controls(){}
 
 void restartGame() {
  right=false; left= false; 
  bulletsObj = new Bullets();
  armyObj = new EnemyArmy(39);
  shipObj = new Ship(true);
  scoreObj = new Score();
  enemeyBulletsObj = new EnemyBullets();
 }
 
 void softRestartGame(){
   right=false; left= false; 
   enemeyBulletsObj = new EnemyBullets();
   bulletsObj = new Bullets();
   armyObj = new EnemyArmy(39);
 }
 
 void transportStart(){ gameStatus = "transport"; }
 void gameOn(){ gameStatus = "on"; }
 void gamePause(){ gameStatus = "pause"; }
 void gameWin(){ 
   if( scoreObj.isFinalLevel())
     gameStatus = "win";
   else { // progress Level
     scoreObj.nextLevel();
     softRestartGame();
     transportStart();
   }
 }
 void gameLose(){ gameStatus = "lose"; }
 void rightOn(){ right=true; }
 void rightOff(){ right=false; }
 void leftOn(){ left=true; }
 void leftOff(){ left=false; }
 void gunOn(){ gun=true; }
 void gunOff(){ gun=false; }
}
//Aqui se dice cuando una tecla es presionada se hara el movimiento que se debe o se tiene planeado
void keyPressed(){
  if(gameControls.gameStatus == "on"){
    if( key == 'a' || ( key == CODED && keyCode == LEFT ) ) gameControls.leftOn();
    else if( key == 'd' || ( key == CODED && keyCode == RIGHT ) ) gameControls.rightOn();
    else if( key == ' ' ) gameControls.gunOn(); 
    else if( key == 'p' ) gameControls.gamePause(); 
  } else if(gameControls.gameStatus == "pause"){
    if( key == 'p' ) gameControls.gameOn(); 
  } else if( gameControls.gameStatus == "transport"){
    if( key == 'a' || ( key == CODED && keyCode == LEFT ) ) gameControls.leftOn();
    else if( key == 'd' || ( key == CODED && keyCode == RIGHT ) ) gameControls.rightOn();
  }
}

void keyReleased(){
  if(gameControls.gameStatus == "on" || gameControls.gameStatus == "transport" ){
    if( key=='a' || ( key == CODED && keyCode == LEFT ) ) gameControls.leftOff();
    else if( key=='d' || ( key == CODED && keyCode == RIGHT ) ) gameControls.rightOff();
    else if( key == ' ' ) gameControls.gunOff(); 
  } 
}
//Lo mismo que en lo anterior pero en el mouse
void mousePressed(){
  if(gameControls.gameStatus == "inicio") gameControls.transportStart();
  else if(gameControls.gameStatus == "win"  || gameControls.gameStatus == "lose" ){
    if(mouseX >= width/2 - 75 && mouseX <= width/2 + 75 && mouseY >= height/2 && mouseY <= height/2 + 50){
      gameControls.restartGame(); 
      gameControls.transportStart();
    } else if(mouseX >= width/2 - 75 && mouseX <= width/2 + 75 && mouseY >= height/2 + 75 && mouseY <= height/2 + 125){
      exit();
    }
  }
  
}
//Aqui se menciona a los enemigos y la "función" que tendran
class Enemy {
  PVector origin; 
  PVector curveOrigin;
  String type;
  String status;
  int diameter;
  int i;
  float defRotation;
  float angle = 0.05;
  float scalar = 1.7;
  float speed = 0.02;
  int shooterCooldown = 0;
  int coolDownInterval = 90;
  float [] levelSpeedMod = {0, 1, 1.4, 1.9 };
  
  void setActive(){ status = "active"; }
  void setReturning(){ status = "returning"; }
  void setExploding(){ status = "explode"; }
  void setDead(){ status = "dead"; }
  void clearStatus(){ status = ""; }
  boolean isActive() { return status == "active"; }
  boolean isReturning() { return status == "returning"; }
  boolean isDead() { return status == "dead"; }
  boolean isExploding() { return status == "explode"; }

  Enemy(PVector position, String enemyType) {
    origin = position; type = enemyType;
    status = "";
    diameter = 6;
    i = 0;
  }
  //Aqui se dicen los "Tipos" de enemigos
  color getDefaultColor(){
    if (type == "2") return color(160, 137, 214);
    else if ( type == "3") return color(189, 47, 14); 
    return color(26, 160, 18);
  }

  void display(PVector addition) {
    if(isDead()) return;
    else if(isExploding()){ exploder(); return; }
    movement(addition);
    
    PVector corigin = isActive() || isReturning() ? curveOrigin : origin;
    color defaultColor = getDefaultColor();
    rectMode(CENTER);

    fill(46, 78, 127);
    stroke(46, 78, 127);
    triangle(corigin.x-5, corigin.y - 11, corigin.x + 16, corigin.y-3, corigin.x +16, corigin.y  );
    triangle(corigin.x+4, corigin.y - 11, corigin.x - 17, corigin.y-3, corigin.x -17, corigin.y );

    fill(defaultColor);
    stroke(defaultColor);
    triangle(corigin.x + 7, corigin.y - 5, corigin.x, corigin.y +2, corigin.x -7, corigin.y -5);
    rect(corigin.x, corigin.y-7, 15, 3);

    rect(corigin.x, corigin.y - 9, 30, 1);
    rect(corigin.x - 15, corigin.y - 11, 1, 2);
    rect(corigin.x + 15, corigin.y - 11, 1, 2);

    rect(corigin.x - 5, corigin.y - 11, 2, 4);
    rect(corigin.x + 5, corigin.y - 11, 2, 4);

    fill(255);
    stroke(255);
    rect(corigin.x-5, corigin.y - 7, 1, 2);
    rect(corigin.x+5, corigin.y - 7, 1, 2);
    
    if( isActive() ){
      popMatrix();
      shoot();
      if(curveOrigin.y > HEIGHT_ + 48 ){
        curveOrigin = new PVector(250, 0);
        setReturning();
      }
    } else if (isReturning() && 
      curveOrigin.x <= origin.x + 3 && curveOrigin.x >= origin.x - 3 &&
      curveOrigin.y <= origin.y + 3 && curveOrigin.y >= origin.y - 3 ){ 
      clearStatus();
    }
  }
  //Aqui se duce el cooldown de los disparos de nuestra arma asi como el como se debera de manejar
  void shoot(){
    if( shooterCooldown <= 0 ){
      float x = curveOrigin.x * cos(defRotation) - curveOrigin.y * sin(defRotation) + origin.x;
      float y = curveOrigin.x * sin(defRotation) + curveOrigin.y * cos(defRotation) + origin.y + 25;
      PVector actualPos = new PVector( x, y);
      enemeyBulletsObj.addBullet(actualPos);
      shooterCooldown = coolDownInterval;
    } 
    shooterCooldown = shooterCooldown - 1;
  }
  
  void movement( PVector addition){
    if( isReturning() ){
      if( curveOrigin.x > origin.x) curveOrigin.x--; 
      else if( curveOrigin.x < origin.x) curveOrigin.x++; 
      if(curveOrigin.y > origin.y) curveOrigin.y--; 
      else if(curveOrigin.y < origin.y) curveOrigin.y++;
    } else if( isActive() ){
      pushMatrix();
      translate(origin.x, origin.y);
      rotate(defRotation);
      curveOrigin.x = curveOrigin.x + (sin(angle) *scalar * levelSpeedMod[scoreObj.level]);
      angle = angle + speed;
      curveOrigin.y = (curveOrigin.y + (1* levelSpeedMod[scoreObj.level])) % (HEIGHT_ + 50);
    }
    origin = new PVector( origin.x + addition.x, origin.y + addition.y);
  }
  
  void activate(boolean fromR){ 
    setActive();
    curveOrigin = new PVector(0,0);
    if( fromR ) defRotation = PI/5.0;
    else defRotation = -PI/9.0;
  }
  
  void explode(){ setExploding(); }
  
  void exploder(){
     if( isActive() ){
      pushMatrix();
      translate(origin.x, origin.y);
      rotate(defRotation);
     } 
     PVector corigin = isReturning() || isActive() ? curveOrigin : origin;
     noStroke(); 
     fill(getDefaultColor()); 
     rect( corigin.x-(i*10), corigin.y, diameter, diameter);  
     rect( corigin.x+(i*10), corigin.y, diameter, diameter); 
     rect( corigin.x, corigin.y-(i*10), diameter, diameter); 
     rect( corigin.x, corigin.y+(i*10), diameter, diameter); 
     diameter-=0.5; 
     i++; 
     if( isActive()) popMatrix();
     if(diameter <=0){ setDead(); } 
  }
}
class EnemyArmy {
  PVector origin; 
  PVector slideOrigin; 
  PVector move;
  Enemy [] army;
  int startX;
  int startY;
  boolean directionR;
  boolean activeEnemyDirectionR;
  int activeCountDown; 
  int coolDownInterval;
  int minArmyCountActive; 
  float [] levelSpeedMod = {0, 1, 1.4, 1.9 };
  
  EnemyArmy(int armyCount){
    origin = move = new PVector( 0, -320);
    directionR = false;
    army = new Enemy[0]; 
    startX = 100;
    startY = HEIGHT_/3;
    activeEnemyDirectionR = true;
    minArmyCountActive = 3 * armyCount/4;
    activeCountDown = 0;
    coolDownInterval  = 220;
    for( int i = 0; i< int(armyCount/2); i++){
      army = (Enemy [])append(army, new Enemy(new PVector(startX, startY), "1"));
      modulatePosition();
    }
    for( int i = int(armyCount/2); i< int(3 * armyCount/4); i++){
      army = (Enemy [])append(army, new Enemy(new PVector(startX, startY), "2"));
      modulatePosition();
    }
    for( int i = int(3 * armyCount/4); i< armyCount; i++){
      army = (Enemy [])append(army, new Enemy(new PVector(startX, startY), "3"));
      modulatePosition();
    }
  }
  
  void modulatePosition(){
    startX = startX + 50; 
    if(startX > WIDTH_ - 100) { 
        startX = 100; startY = startY - 25; 
     } 
  }
  
  void display(){
    if(army.length == 0) gameControls.gameWin();
    for( int i = 0; i< army.length; i++){ 
      army[i].display(move); 
      if(army[i].isDead()) { deleteEnemy(i); return;}
      else if(detectCollision(army[i]) && !army[i].isExploding() ) army[i].explode();
     }
     triggerArc();
     movement();
  }
  
  void slideIn(){
    for( int i = 0; i< army.length; i++) army[i].display(move);
    slideInMovement();
  }
  
  void slideInMovement(){
    move = new PVector( 0,  2);
    origin = new PVector(origin.x, origin.y + 2);
  }
  
  void deleteEnemy(int i){
    scoreObj.normalKill();
    if(army.length == 1) army = new Enemy[0];
    else army = (Enemy [])concat( (Enemy [])subset(army, 0, i), (Enemy [])subset(army, i + 1 ));
  }
  
  boolean detectCollision(Enemy es){
    if( bulletsObj.bullet != null ){
      if( es.isActive() ) {
        float x = es.curveOrigin.x * cos(es.defRotation) -
          es.curveOrigin.y * sin(es.defRotation) + es.origin.x;
        float y = es.curveOrigin.x * sin(es.defRotation) +
          es.curveOrigin.y * cos(es.defRotation) + es.origin.y;
        if(dist(x,y, bulletsObj.bullet.x,bulletsObj.bullet.y)<=20){
          bulletsObj.deleteBullet();
          return true; 
        }
      } else if( es.isReturning() && 
      dist(es.curveOrigin.x, es.curveOrigin.y, bulletsObj.bullet.x,bulletsObj.bullet.y)<=20){
        bulletsObj.deleteBullet();
        return true; 
      } else if( !es.isActive() && !es.isReturning() && dist(es.origin.x, es.origin.y, bulletsObj.bullet.x,bulletsObj.bullet.y)<=17){
        bulletsObj.deleteBullet();
        return true;
      }
    }
    return false;
  }
  
  int findEdgeMost(){
    if( army.length == 0 ) return -1;
    int edgeMost = 0; 
    for( int i = 1; i< army.length; i++){
      if( (( activeEnemyDirectionR && army[i].origin.x > army[edgeMost].origin.x ) 
        || ( !activeEnemyDirectionR && army[i].origin.x < army[edgeMost].origin.x )) 
        && army[i].isActive() == false && army[i].isReturning() == false && army[i].isDead() ==false && army[i].isExploding() ==false){ 
        edgeMost = i;
      }
    }
   if ( army.length > edgeMost && 
      (army[edgeMost].isActive() ||  army[edgeMost].isReturning() || army[edgeMost].isDead() ||  army[edgeMost].isExploding()) ){
      edgeMost = -1; 
      for( int i = 1; i< army.length; i++){
        if(army[i].isActive()== false && army[i].isReturning() == false && army[i].isDead() ==false && army[i].isExploding() ==false){ 
          edgeMost = i;
        }
      }
    } 
    return edgeMost;
  }
  
  void triggerArc(){
    if( minArmyCountActive > army.length ){
      if( activeCountDown <= 0 && findEdgeMost() != -1 ){
        army[findEdgeMost()].activate(activeEnemyDirectionR);
        activeEnemyDirectionR = !activeEnemyDirectionR;
        activeCountDown = coolDownInterval;
      } else activeCountDown--;
    }
  }
  
  void movement(){
    if(directionR) {
      if(origin.x >= 70){
        directionR = false;
        move = new PVector( -1 * levelSpeedMod[scoreObj.level],  2);
      } else move = new PVector(1 * levelSpeedMod[scoreObj.level], 0); 
    } else {
      if(origin.x <= -70){
        directionR = true;
        move = new PVector( 1 * levelSpeedMod[scoreObj.level],  2);
      } else move = new PVector(  -1 * levelSpeedMod[scoreObj.level], 0); 
    }
    origin = new PVector(origin.x + move.x, origin.y + move.y);
  }
}
class EnemyBullets {
  PVector [] bullets; 

  EnemyBullets(){
    bullets = new PVector[0] ; 
  }
  
  void display() {
    rectMode(CENTER);
    fill(255, 255, 100);
    stroke(255, 255, 100);
    for (int i = 0; i< bullets.length; i++) ellipse(bullets[i].x, bullets[i].y, 1, 5);
    movement();
  } 

  void addBullet(PVector position) {
    bullets = (PVector [])append(bullets, new PVector( position.x, position.y -25));
  }

  void deleteBullet(int i) {
    bullets = (PVector [])concat( (PVector [])subset(bullets, 0, i), (PVector [])subset(bullets, i + 1 ));
  }

  void movement() {
    for (int i = 0; i< bullets.length; i++) {
      bullets[i] = new PVector( bullets[i].x, bullets[i].y + 6 );
      if (bullets[i].y > HEIGHT_) deleteBullet(i);
    }
  }
  
}
//Todo esto es el apartado grafico de textos mostrados en pantalla
//El puntaje
class Score {
   int shipScore; 
   int highScore = 99999;
   int lives;
   int level; 
   int transportStart; 
   
   Score(){
     shipScore = 0;
     lives = 3;
     level = 1; 
     transportStart = 0; 
   }
   
   boolean isFinalLevel(){  return level == 3;  }
   
   void nextLevel(){ level += 1; }
   
   void normalKill(){ shipScore = shipScore + 40; }
   //Lo que se muestra al jugar
   void display(){
     stroke(255);
     rectMode(CORNER);
     fill(255);
     textFont(Akashi24);
     text(shipScore, 100, 30);
     stroke(255,100,100);
     text("Puntaje más alto:",WIDTH_/2 - 50, 30);
     stroke(255);
     text(highScore, WIDTH_/2 + 100, 30);
     
     if(lives >= 1) livesIcon( new PVector(WIDTH_ -80, 20));
     if(lives >= 2) livesIcon( new PVector(WIDTH_ -100, 20));
     if(lives >= 3) livesIcon( new PVector(WIDTH_ -120, 20));
   }
   
   void livesIcon(PVector origin){
     fill(255,100,100);
     stroke(255,100,100);
     ellipse(origin.x, origin.y, 6,6);
     fill(255); stroke(255);
     ellipse(origin.x, origin.y, 2,2);
   }
  
   void setTransportStart(){ transportStart = millis();  }
   void clearTransport(){ transportStart = 0; }
   int transportTime(){ return millis() - transportStart; } 
   boolean transportDone(){ return transportTime() > 10000;  }// 10 sec 
   
   void deathHandler(){
     if(lives > 0){
       lives--; 
       shipObj = new Ship(false);
       shipObj.slideIn();
     } else {
        gameControls.gameLose(); 
     }
   }
}
//Textos mostrados al correr el codigo
void startScreen(){
  rectMode(CORNER);
  textAlign(CENTER); 
  textLeading(20); 
  textFont(Akashi48);
  fill(255);
  noStroke();
  text("Space Invaders de HolSan",0,height/2.5,width, height); 
  textFont(Akashi24);
  text("Click para iniciar",0, height/2.5 + 100, width, height);
}

void levelDisplay(){
  int time = scoreObj.transportTime();
  if(time > 4000 && time < 7500 ) {
    int alpha = 255; 
    if( time <= 5000) alpha = (time - 4000)/4;
    else if ( time >= 6000) alpha = (7500 - time)/4; 
    rectMode(CORNER);
    textAlign(CENTER); 
    noStroke();
    textLeading(20); 
    fill(255, alpha);
    textFont(Akashi48);
    text("Nivel " + scoreObj.level ,0,height/2.3,width, height);  
  }
  if(time > 8000) armyObj.slideIn();
}
//Textos en pausa
void pauseScreen(){
  rectMode(CORNER);
  fill(0, 2); 
  rect(0,0,width,height); 
  textAlign(CENTER); 
  textLeading(20); 
  fill(255);
  stroke(0);
  textFont(Akashi48);
  text("Uy kieto",0,height/3,width, height); 
  textFont(Akashi24);
  text("Dale a la p para jugar mancazo " ,0,height/3 + 100 ,width, height); 
}
//Pantalla cuando pierdes (MALARDOOOOOOOOOOOOOOOOOOOOO)
void loseScreen(){
  rectMode(CORNER);
  noStroke();
  fill(200, 5); 
  rect(0,0,width,height); 
  fill(100,255,255); 
  rect(width/2-90, height/2, 180,50); 
  fill(0); 
  rect(width/2-90, height/2 + 75, 180,50);
  textAlign(CENTER); 
  textLeading(20); 
  fill(0);
  textFont(Akashi36);
  text("Malardo NASHEEE",0,height/3,width, height); 
  text("Tu Puntaje: " + scoreObj.shipScore,0,height/3 + 50 ,width, height); 
  textFont(Akashi24);
  text("Otra?", width/2-75, height/2+15, 150,50); 
  fill(255); 
  text("Nao nao", width/2-75, height/2+92, 150,50); 
}
//Pantalla cuando Ganas (NASHE)
void winScreen(){
  rectMode(CORNER);
  noStroke();
  fill(200, 5); 
  rect(0,0,width,height); 
  fill(100,255,255); 
  rect(width/2-90, height/2, 180,50); 
  fill(0); 
  rect(width/2-90, height/2 + 75, 180,50);
  textAlign(CENTER); 
  textLeading(20); 
  fill(0);
  textFont(Akashi36);
  text("MIS MOMOS, BUENOS SON",0,height/3,width, height); 
  text("Tu Puntaje: " + scoreObj.shipScore,0,height/3 + 50 ,width, height); 
  textFont(Akashi24);
  text("Otra?", width/2-75, height/2+15, 150,50); 
  fill(255); 
  text("Nao nao", width/2-75, height/2+92, 150,50); 
}
 //Aqui esta el codigo de la Nave 
 //"SHIP" es la nave y el movimiento que tiene, asi tambien como el apartado grafico
class Ship{
  PVector origin;
  float diameter; 
  int i; 
  boolean isdead; 
  boolean isexplode; 
  boolean isslide;
  
  Ship(boolean newGame){
    if(newGame)
      origin = new PVector(WIDTH_/2, 13* HEIGHT_/14); 
    else 
      origin= new PVector( WIDTH_/2, HEIGHT_ + 60); 
    diameter = 10;
    i = 0; 
    isdead = isexplode = false;
  }
  
  void moveRight(){
    origin= new PVector( constrain(origin.x + 2, 15, WIDTH_ - 15),origin.y);
  }
  
  void moveLeft(){
    origin= new PVector( constrain(origin.x - 2, 15, WIDTH_ - 15),origin.y);
  }
  
  void movement(){
   if(gameControls.right) moveRight(); 
   else if(gameControls.left) moveLeft(); 
  }
  
  void display(){
    if(isdead){ scoreObj.deathHandler(); return; }
    else if(isexplode){ exploder(); return; }
    shipDisplay();
    if(isslide){ slideInMovement(); return; }
    if(detectCollision()) { explode(); return; }
    movement();
    shoot();
  }
  
  void slideIn(){ isslide = true; } 
  
  void slideInMovement(){
    if( origin.y == 13* HEIGHT_/14) isslide = false;
    origin= new PVector( WIDTH_/2 , max(origin.y - 2, 13* HEIGHT_/14)  );
  }
  
  boolean detectCollision(){
    int eblen = enemeyBulletsObj.bullets.length,
        alen =  armyObj.army.length;
    for( int i = 0; i< eblen || i< alen; i++){
      if( i < alen ) {
        Enemy tempEnemy = armyObj.army[i];
        if((!tempEnemy.isActive() && !tempEnemy.isReturning()
            && dist(origin.x,origin.y, tempEnemy.origin.x, tempEnemy.origin.y) <= 27) || 
            (tempEnemy.isReturning() && dist(origin.x,origin.y, tempEnemy.curveOrigin.x, tempEnemy.curveOrigin.y) <= 27)){
          armyObj.deleteEnemy(i);
          return true; 
        } else if( tempEnemy.isActive() ){
          PVector curOr = tempEnemy.curveOrigin; 
          PVector oldOr = tempEnemy.origin;
          float rot = tempEnemy.defRotation;
          float x = curOr.x * cos(rot) - curOr.y * sin(rot) + oldOr.x;
          float y = curOr.x * sin(rot) + curOr.y * cos(rot) + oldOr.y;
          if( dist(origin.x,origin.y, x, y) <= 20){
            armyObj.deleteEnemy(i);
            return true; 
          }
        }
      } 
      if(  i< eblen && dist(origin.x,origin.y, enemeyBulletsObj.bullets[i].x,enemeyBulletsObj.bullets[i].y) <= 25){
        enemeyBulletsObj.deleteBullet(i);
        return true; 
      }
    }
    return false;
  }
  
 
  void shipDisplay(){ 
    rectMode(CENTER);

    
  fill(0,255,255);
    stroke(0,255,255);
    rect( origin.x - 2, origin.y + 2, 1.5, 22);
    rect( origin.x + 2, origin.y + 2, 1.5, 22);
    
    quad(origin.x, origin.y -6, origin.x, origin.y -4 , origin.x-10, origin.y + 9, origin.x-10, origin.y+6);
    quad(origin.x, origin.y -6, origin.x, origin.y -4, origin.x+10, origin.y +9, origin.x+10, origin.y+6);
    
    rect(origin.x - 11, origin.y + 5, 1, 10);
    rect(origin.x + 12, origin.y + 5, 1, 10);
    
    
    stroke(255,0,0);
    triangle(origin.x, origin.y - 18, origin.x + 8, origin.y - 9, origin.x - 8, origin.y - 9);
 
    //Aqui esta la propiedad visual de la bala
    if( bulletsObj.bullet == null ){
      stroke(255,255,100);
      rect(origin.x, origin.y - 19, 1, 5);
    }
  }
  
  void shoot(){
    if(gameControls.gun && bulletsObj.bullet == null ){
      bulletsObj.addBullet(origin);
    } 
  }
  
  void explode(){ isexplode=true; }
  
  void exploder(){
     noStroke(); 
     fill(0,255,255); 
     rect( origin.x-(i*10), origin.y, diameter, diameter);  
     rect( origin.x+(i*10), origin.y, diameter, diameter); 
     rect( origin.x, origin.y-(i*10), diameter, diameter); 
     rect( origin.x, origin.y+(i*10), diameter, diameter); 
     diameter-=0.5; 
     i++; 
     if(diameter <=0){ isexplode=false;  isdead=true; } 
  }
}
class Space{
  int count =0;
  PVector [] wStars = new PVector[0]; 
  PVector [] rStars = new PVector[0]; 
  PVector [] bStars = new PVector[0]; 
  
  Space(){
    for(int i = 0; i< 90; i ++) wStars = (PVector [])append(wStars, new PVector(random(0,WIDTH_), random(0,HEIGHT_)));
    for(int i = 0; i< 10; i ++) rStars = (PVector [])append(rStars, new PVector(random(0,WIDTH_), random(0,HEIGHT_)));
  } 
  
  void display(){
    background(0);
    noStroke();
    fill(255);
    for(int i = 0; i< 30; i ++) ellipse(wStars[i].x, (wStars[i].y + count) % HEIGHT_, 2,2); 
    fill(255,150);
    for(int i = 30; i< 60; i ++) ellipse(wStars[i].x, (wStars[i].y + count/2) % HEIGHT_, 2,2); 
    fill(255, 75);
    for(int i = 60; i< 90; i ++) ellipse(wStars[i].x, (wStars[i].y + count/6) % HEIGHT_, 2,2); 
    fill(100,200,255);
    for(int i = 0; i< 5; i ++) ellipse(rStars[i].x, ( rStars[i].y + count) % HEIGHT_, 2,2); 
    fill(100,200,255, 150);
    for(int i = 3; i< rStars.length; i ++) ellipse(rStars[i].x, ( rStars[i].y + count/2) % HEIGHT_, 2,2); 
    movement();
  }
  
  void movement(){
    count = count + 1;
    if( count > HEIGHT_ * 6) count = 0;
  }
  
   void hyperDisplay(int hyperSpeed){
    background(0);
    noStroke();
    fill(255);
    for(int i = 0; i< 30; i ++) ellipse(wStars[i].x, (wStars[i].y + count) % HEIGHT_, 2,2); 
    fill(255,150);
    for(int i = 30; i< 60; i ++) ellipse(wStars[i].x, (wStars[i].y + count/2) % HEIGHT_, 2,2); 
    fill(255, 75);
    for(int i = 60; i< 90; i ++) ellipse(wStars[i].x, (wStars[i].y + count/6) % HEIGHT_, 2,2); 
    fill(100,200,255);
    for(int i = 0; i< 5; i ++) ellipse(rStars[i].x, ( rStars[i].y + count) % HEIGHT_, 2,2); 
    fill(100,200,255, 150);
    for(int i = 3; i< rStars.length; i ++) ellipse(rStars[i].x, ( rStars[i].y + count/2) % HEIGHT_, 2,2); 
    hyperMovement(hyperSpeed);
  }

   void hyperMovement(int hyperSpeed){
    if(hyperSpeed >= 5000 ) count = count + max(2 * (5000 - (hyperSpeed-5000))/500, 1);
    else  count = count + max(2 * hyperSpeed/500, 1);
    
    if( count > HEIGHT_ * 6) count = 0;
  }
  
}
