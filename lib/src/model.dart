part of hunt;

/**
 * Game-object that shows the current state of the game.
 */
class Game{
  int rows;             //Current amount of rows
  int level;            //Current Level
  bool started;         //Shows if the game has been started
  bool paused;          //Shows if the game has been paused
  int score;            //Current score
  Character character;  //Character on the field

  /**
   * Lists of objects on the field
   */
  List<PickUp> pickUps = new List<PickUp>();
  List<Entity> entities = new List<Entity>();
  List<Bullet> bullets = new List<Bullet>();

  /**
   * Used to handle Power-Ups
   */
  bool activeSlowedGame;
  bool activeDoubledPoints;
  bool slowedGamePickedUp;
  bool doublePointsPickedUp;

  /**
   * Constructor to create a new game
   */
 Game(int rows){
   this.rows = rows;
   this.level = 1;
   this.paused = false;
   this.started = false;
   this.activeSlowedGame = false;
   this.activeDoubledPoints = false;
   this.slowedGamePickedUp = false;
   this.doublePointsPickedUp = false;
   this.score = 0;
   this.character = new Character.On(this);
 }

  /**
   * Moves all entities on the field and handles collision with bullets and the character
   */
  void moveEntities() {
    entities.forEach((x) => x.move());
    for (int i = 0; i < entities.length; i++) {
      if(!entities.elementAt(i).alive){
        entities.removeAt(i);
      }
      else{
        if (entities.elementAt(i).currentPos <= 1) {
          if (entities.elementAt(i).row == character.currentRow) {
            entities.elementAt(i).onTouch();
          }
          entities.elementAt(i).alive = false;
        }
        else {
          for (int j = 0; j < bullets.length; j++) {
            if (entities.elementAt(i).currentPos == bullets.elementAt(j).currentPos || entities.elementAt(i).currentPos < bullets.elementAt(j).currentPos) {
              if(entities.elementAt(i).row == bullets.elementAt(j).row){
                if(bullets.elementAt(j).type == "net"){
                  entities.elementAt(i).onCatch();
                  character.regainNet();
                }
                else{
                  entities.elementAt(i).onHit();
                }
                bullets.elementAt(j).hit = true;
              }
            }
          }
        }
      }
    }
  }

  /**
   * Moves Pick-Ups and handles collision with character
   */
  void movePickUps(){
    pickUps.forEach((x) => x.move());
    for(int i = 0; i < pickUps.length; i++){
      if(pickUps.elementAt(i).getRemove()){
        pickUps.removeAt(i);
      }
      else{
        if(pickUps.elementAt(i).currentPos <= 1){
          if(pickUps.elementAt(i).row == character.currentRow){
            pickUps.elementAt(i).onPickUp();
          }
          pickUps.elementAt(i).setRemoveTrue();
        }
      }
    }
  }

  /**
   * Moves bullets and handles collision with entities
   */
  void moveBullets(){
   bullets.forEach((x) => x.move());
    for (int i = 0; i < bullets.length; i++)
    {
      if(bullets.elementAt(i).hit && bullets.elementAt(i).currentPos >= 1){
        bullets.removeAt(i);
        return;
      }
      if(bullets.elementAt(i).currentPos >= 48) {
        bullets.elementAt(i).hit = true;
        if(bullets.elementAt(i).type == "net"){
          character.regainNet();
        }
      }
      else{
       for(int j = 0; j < entities.length;j++){
         if(entities.elementAt(j).currentPos == bullets.elementAt(i).currentPos || entities.elementAt(j).currentPos < bullets.elementAt(i).currentPos+1){
           if(entities.elementAt(j).row == bullets.elementAt(i).row){
             if(bullets.elementAt(i).type == "net"){
               entities.elementAt(j).onCatch();
               character.regainNet();
             }
             else{
               entities.elementAt(j).onHit();
             }
             bullets.elementAt(i).hit = true;
          }
        }
      }
    }
  }
 }

  /**
   * Updates the level of the game-object and adjust rows
   */
  void levelUp(int rows){
   level = level + 1;
   this.rows = rows;
  }

  /**
   * Uses a random number (0-100) to spawn a random entity on each row
   */
  void spawnEntities() {
   var stones = 0;
    for (int row = 0; row < rows; row++) {
      var random = new Random();
      var number = random.nextInt(100);
      if (number <= 40) {
        entities.add(new Enemy1.On(this,row));
      }
      else if (number >= 41 && number <= 60) {
        if(stones < rows - 1) {
          entities.add(new Obstacle1.On(this, row));
          stones += 1;
        }
      }
      else if(number >= 61 && number <= 67){
        entities.add(new Objective1.On(this, row));
      }
    }
  }

  /**
   * Uses a random number (0-100) to spawn a Pick-Up
   */
  void spawnPickUp(int row, int currentPos){
    var random = new Random();
    var number = random.nextInt(100);
    if (number <= 50) {
        pickUps.add(new AmmoPickUp.On(this,row,currentPos));
    }
    else if (number == 51) {
      pickUps.add(new HealthPickUp.On(this,row,currentPos));
    }
    else if(number >= 52 && number <= 54){
        pickUps.add(new DoublePointsPickUp.On(this,row,currentPos));
    }
    else if(number >= 55 && number <= 57){
        pickUps.add(new SlowPickUp.On(this,row,currentPos));
    }
  }

  /**
   * Creates an [Arrow] in front of the [character]
   */
  void shootBullet(){
   if(!character.noAmmo) {
     bullets.add(new Arrow(this, character.currentRow));
     character.shootBullet();
   }
  }

  /**
   * Creates a [Net] in front of the [character]
   */
  void shootNet() {
    if(character.netOut){
      return;
    }
    bullets.add(new Net(this, character.currentRow));
    character.shootNet();
  }

  /**
   * Adds points to the score
   */
  void addPoints(int points){
   if(activeDoubledPoints){
     this.score = score + (points*2);
   }
   else {
     this.score = score + points;
   }
  }

  /**
   * Adds health to the [character]
   */
  void addHealth(double health){
    character.gainHealth(health);
  }

  /**
   * Adds Ammunition to the [character]
   */
  void addAmmo(int amount){
   character.gainAmmo(amount);
  }

  /**
   * Used to show that the double-points-Power-Up is active
   */
  void doublePointsPower(){
   this.activeDoubledPoints = true;
  }

  /**
   * Used to show that the double-points-Power-Up is expired
   */
  void doublePointsPowerExpire(){
    this.activeDoubledPoints = false;
  }

  /**
   * Used to show that a double-points-Power-Up got picked up
   */
  void doublePickedUp(){
    this.doublePointsPickedUp = true;
  }

  /**
   * Used to show that the picked up double-points-Power-Up got processed
   * and a new can be picked up to refresh the duration.
   */
  void doublePickedUpProcessed(){
    this.doublePointsPickedUp = false;
  }

  /**
   * Used to show that the slow-down-Power-Up is active
   */
  void slowDownPower(){
   this.activeSlowedGame = true;
  }

  /**
   * Used to show that the slow-down-Power-Up is expired
   */
  void slowDownPowerExpire(){
    this.activeSlowedGame = false;
  }

  /**
   * Used to show that a slow-down-Power-Up got picked up
   */
  void slowDownPickedUp(){
   this.slowedGamePickedUp = true;
  }

  /**
   * Used to show that the picked up slow-down-Power-Up got processed
   * and a new can be picked up to refresh the duration.
   */
  void slowDownPickedUpProcessed(){
   this.slowedGamePickedUp = false;
  }

  /**
   * Used to show that the game has started
   */
  void gameStart(){
   started = true;
  }

  /**
   * Used to show that the game is over
   */
  void gameOver(){
   started = false;
  }

  /**
   * Used to show that the game is paused
   */
  void gamePaused(){
   paused = true;
  }

  /**
   * Used to show that the game has resumed
   */
  void gameResumed(){
   paused = false;
  }

  /**
   * Used to ask if the game has started
   */
  bool getStarted(){
   return started;
  }

  /**
   * Used to ask if the game is paused
   */
  bool getPaused(){
    return paused;
  }

  /**
   * Used to see if the double-points-Power-Up is active
   */
  bool getActiveDoubledPoints(){
    return activeDoubledPoints;
  }

  /**
   * Used to see if a double-points-Power-Up got picked up
   */
  bool getDoublePointsPickedUp(){
   return doublePointsPickedUp;
  }

  /**
   * Used to see if the slow-down-Power-Up is active
   */
  bool getActiveSlowedDown(){
    return activeSlowedGame;
  }

  /**
   * Used to see if a slow-down-Power-Up got picked up
   */
  bool getSlowedGamePickedUp(){
    return slowedGamePickedUp;
  }

}
///////////////////////////////////////////////////////////////////////
class Character{
  int currentRow;         //Current row of the character
  int ammo = 30;          //Current ammunition of the character
  double health = 3.0;    //Current health of the character
  bool alive = true;      //Shows if the charater is alive
  bool netOut;            //Show if the net is out
  bool noAmmo = false;    //Shows if the character has ammunition
  Game _game;             //The game-object the character is on

  /**
   * Reduces the ammunition when a bullet is shot
   */
  void shootBullet(){
    if(noAmmo) {
      return;
    }
    ammo = ammo - 1;
    if(ammo == 0){
      noAmmo = true;
    }
  }

  /**
   * Shoots the net
   */
  void shootNet(){
    netOut = true;
  }

  /**
   * Regains the net
   */
  void regainNet(){
    netOut = false;
  }

  /**
   * Character moves up a row
   */
  void moveUp(){
    if(currentRow > 0) {
      currentRow = currentRow - 1;
    }
  }

  /**
   * Character moves down a row
   */
  void moveDown(){
    if(currentRow < _game.rows-1) {
      currentRow = currentRow + 1;
    }
  }

  /**
   * Character recieves damage / loses health
   */
  void receiveDamage(double damage){
    health = health - damage;
    if(health == 0){
      alive = false;
    }
  }

  /**
   * Character gains health
   */
  void gainHealth(double amount){
    if(this.health < 3) {
      this.health = this.health + amount;
    }
  }

  /**
   * Character gains ammunition
   */
  void gainAmmo(int amount){
    this.ammo = this.ammo + amount;
    if(noAmmo){
      noAmmo = false;
    }
  }

  /**
   * Used to place character on the game-object
   */
  Character.On(Game _game){
    this._game = _game;
    alive = true;
    this.currentRow = (_game.rows/2).floor();
  }

}
//////////////////////////////////////////////////////////////////////
abstract class Entity{
  int row;                //row of the entity
  int currentPos;         //current position of the entity
  int health;             //health of the entity
  int speed;              //speed of the entity
  int points;             //points the Entity can give
  String type;            //type of the entity <- Used for view
  double damage;          //damage the entity can deal
  bool alive;             //shows if the entity is alive
  void onHit();           //Used to make the entity do something when shot
  void onDeath();         //Used to make the entity do something when dying
  void onCatch();         //Used to make the entity do something when caught by a net
  void onTouch();         //Used to make the entity do something when colliding with character
  void move();            //Used to make the entity move
  Game _game;             //Game-Object the entity is on
}
//-----------------------------------------------------------------//
class Enemy1 extends Entity{
  int health = 1;
  String type = "enemy1";
  final points = 1;
  final damage = 1.0;
  final speed = 1;
  int currentPos = 48;
  bool alive = true;

  void onHit(){
    health = health - 1;
    if(health == 0){
      alive = false;
      onDeath();
    }
  }

  void onDeath(){
    _game.addPoints(points);
    _game.spawnPickUp(this.row, this.currentPos);
  }

  void onCatch(){
    return;
  }

  void onTouch(){
    _game.character.receiveDamage(damage);
  }

  void move(){
    currentPos = currentPos - speed;
  }

  Enemy1.On(Game _game,int row){
    this._game = _game;
    this.row = row;
  }
}
//-----------------------------------------------------------------//
class Obstacle1 extends Entity{
  int health = 99;
  String type = "obstacle1";
  final damage = 1.0;
  final speed = 1;
  int currentPos = 48;
  bool alive = true;

  void onHit(){
    return;
  }

  void onDeath(){
    return;
  }

  void onCatch(){
    return;
  }

  void onTouch(){
    _game.character.receiveDamage(damage);
  }

  void move(){
    currentPos = currentPos - speed;
  }

  Obstacle1.On(Game _game,int row){
    this._game = _game;
    this.row = row;
  }
}
//-----------------------------------------------------------------//
class Objective1 extends Entity{
  int health = 1;
  String type = "objective1";
  final damage = 0.0;
  final speed = 1;
  final points = 5;
  final catchPoints = 1;      //Points you get on colliding with the entity (Special-Case: Bunny)
  int currentPos = 48;
  bool alive = true;

  void onHit(){
    health = health - 1;
    if(health == 0){
      alive = false;
      onDeath();
    }
  }

  void onDeath(){
    return;
  }

  void onCatch(){
    _game.addPoints(points);
    alive = false;
  }

  void onTouch(){
    _game.addPoints(catchPoints);
  }

  void move(){
    currentPos = currentPos - speed;
  }

  Objective1.On(Game _game,int row){
    this._game = _game;
    this.row = row;
  }
}
/////////////////////////////////////////////////////////////////////
abstract class Bullet{
  String type;          //type of the bullet
  int row;              //row the bullet is on
  int currentPos;       //current position of the bullet
  Game _game;           //game-object the bullet is on
  bool hit;             //shows if the bullet has hit something
  void move();          //used to make the bullet move
}
//-----------------------------------------------------------------//
class Arrow extends Bullet{
  String type = "arrow";
  int currentPos = 0;
  bool hit = false;

  Arrow(Game_game,row){
    this._game = _game;
    this.row = row;
  }

  void move(){
    currentPos = currentPos + 1;
  }
}
//-----------------------------------------------------------------//
class Net extends Bullet{
  String type = "net";
  int currentPos = 0;
  bool hit = false;

  Net(Game_game,row){
    this._game = _game;
    this.row = row;
  }

  void move(){
    currentPos = currentPos + 1;
  }
}
//////////////////////////////////////////////////////////////////////
abstract class PickUp{
  int row;                                  // row the PickUp is on
  int currentPos;                           // current position of the PickUp
  bool remove = false;                      // Used to show if the PickUp has to be removed from the field
  String type;                              // type of the PickUp
  Game _game;                               // game-object the PickUp is on
  void onPickUp();                          // Used to make the PickUp do something on pick up

  /**
   * Used to make the PickUp move
   */
  void move(){
    this.currentPos = this.currentPos - 1;
  }

  /**
   * Used to see if the pickUp has to be removed
   */
  bool getRemove(){
    return remove;
  }

  /**
   * Makes the PickUp "say" that it has to be removed
   */
  void setRemoveTrue(){
    remove = true;
  }
}
//-----------------------------------------------------------------//
class AmmoPickUp extends PickUp{
  final String type = "ammoPickUp";
  final int amount = 3;


  AmmoPickUp.On(Game game, int row, int currentPos){
    this._game = game;
    this.row = row;
    this.currentPos = currentPos;
  }

  void onPickUp(){
    _game.addAmmo(amount);
  }
}
//-----------------------------------------------------------------//
class HealthPickUp extends PickUp{
  final String type = "healthPickUp";
  final double amount = 1.0;

  HealthPickUp.On(Game game, int row, int currentPos){
    this._game = game;
    this.row = row;
    this.currentPos = currentPos;
  }

  void onPickUp(){
    _game.addHealth(amount);
  }
}
//-----------------------------------------------------------------//
class DoublePointsPickUp extends PickUp{
  final String type = "doublePickUp";

  DoublePointsPickUp.On(Game game, int row, int currentPos){
    this._game = game;
    this.row = row;
    this.currentPos = currentPos;
  }

  void onPickUp(){
    _game.doublePointsPower();
    _game.doublePickedUp();
  }
}
//-----------------------------------------------------------------//
  class SlowPickUp extends PickUp {
    final String type = "slowPickUp";

    SlowPickUp.On(Game game, int row, int currentPos){
      this._game = game;
      this.row = row;
      this.currentPos = currentPos;
    }

    void onPickUp() {
      _game.slowDownPower();
      _game.slowDownPickedUp();
    }
  }