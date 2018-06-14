part of hunt;


class Game{
  int rows;
  int level;
  bool started;
  bool paused;
  int score;
  Character character;
  List<PickUp> pickups = new List<PickUp>();
  List<Entity> entities = new List<Entity>();
  List<Bullet> bullets = new List<Bullet>();

 Game(int rows){
   this.rows = rows;
   this.level = 1;
   this.paused = false;
   this.started = false;
   this.score = 0;
   this.character = new Character.On(this);
 }


  void moveEntities() {
    entities.forEach((x) => x.move());
    for (int i = 0; i < entities.length; i++) {
      if(!entities.elementAt(i).alive){
        entities.removeAt(i);
      }
      else{
        if (entities.elementAt(i).currentPos == 2) {
          if (entities.elementAt(i).row == character.currentRow) {
            entities.elementAt(i).onTouch();
          }
          entities.elementAt(i).alive = false;
        }
        else {
          for (int j = 0; j < bullets.length; j++) {
            if (entities.elementAt(i).currentPos == bullets.elementAt(j).currentPos || entities.elementAt(i).currentPos < bullets.elementAt(j).currentPos) {
              if(entities.elementAt(i).row == bullets.elementAt(j).row){
                entities.elementAt(i).onHit();
                bullets.elementAt(j).hit = true;
              }
            }
          }
        }
      }
    }
  }

  void movePickUps(){}

  void moveBullets(){
   bullets.forEach((x) => x.move());
    for (int i = 0; i < bullets.length; i++)
    {
      if(bullets.elementAt(i).hit && bullets.elementAt(i).currentPos >= 2){
        bullets.removeAt(i);
        return;
      }
      if(bullets.elementAt(i).currentPos >= 48) {
        bullets.elementAt(i).hit = true;
      }
      else{
       for(int j = 0; j < entities.length;j++){
         if(entities.elementAt(j).currentPos == bullets.elementAt(i).currentPos || entities.elementAt(j).currentPos < bullets.elementAt(i).currentPos+1){
           if(entities.elementAt(j).row == bullets.elementAt(i).row){
            entities.elementAt(j).onHit();
            bullets.elementAt(i).hit = true;
          }
        }
      }
    }
  }
 }

  void levelUp(int rows){
   level = level + 1;
   this.rows = rows;
  }

  void spawnEntities() {
    for (int row = 0; row < rows; row++) {
      var random = new Random();
      if (random.nextInt(100) <= 50) {
        entities.add(new Enemy1.on(this,row));
      }
    }
  }

  void shootBullet(){
    int id = bullets.length;
    bullets.add(new Arrow(this,id,character.currentRow));
    character.shootBullet();
  }

  void addPoints(int points){
    this.score = score + points;
  }

  void gameStart(){
   started = true;
  }

  void gameOver(){
   started = false;
  }

  void gamePaused(){
   paused = true;
  }

  void gameResumed(){
   paused = false;
  }

}
///////////////////////////////////////////////////////////////////////
class Character{
  int currentRow;
  int ammo = 99;
  double health = 3.0;
  bool alive = true;
  bool netOut;
  bool noAmmo = false;
  Game _game;

  void shootBullet(){
    if(noAmmo) {
      return;
    }
    ammo = ammo - 1;
    if(ammo == 0){
      noAmmo = true;
    }
  }

  void shootNet(){}

  void moveUp(){
    if(currentRow > 0) {
      currentRow = currentRow - 1;
    }
  }

  void moveDown(){
    if(currentRow < _game.rows-1) {
      currentRow = currentRow + 1;
    }
  }

  void receiveDamage(double damage){
    health = health - damage;
    if(health == 0){
      alive = false;
    }
  }

  Character.On(Game _game){
    this._game = _game;
    alive = true;
    this.currentRow = (_game.rows/2).floor();
  }
}
//////////////////////////////////////////////////////////////////////
abstract class Entity{
  int row;
  int currentPos;
  int health;
  int speed;
  int lootProbability;
  int points;
  String type;
  double damage;
  bool alive;
  void onHit();
  void onDeath();
  void onCatch();
  void onTouch();
  void move();
  Game _game;
}

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
  }

  void onCatch(){}

  void onTouch(){
    _game.character.receiveDamage(damage);
  }

  void move(){
    currentPos = currentPos - speed;
  }

  Enemy1.on(Game _game,int row){
    this._game = _game;
    this.row = row;
  }
}

/////////////////////////////////////////////////////////////////////
abstract class Bullet{
  int id;
  String type;
  int row;
  int currentPos;
  Game _game;
  bool hit;
  void move(){}
}

class Arrow extends Bullet{
  String type = "arrow";
  int currentPos = 0;
  bool hit = false;

  Arrow(Game_game,id,row){
    this._game = _game;
    this.id = id;
    this.row = row;
  }

  void move(){
    currentPos = currentPos + 1;
  }
}
//////////////////////////////////////////////////////////////////////
abstract class PickUp{

}
