part of hunt;


class Game{
  int rows;
  int level;
  bool running;
  bool gameOver;
  int score;
  Character character;
  List<PickUp> pickups = new List<PickUp>();
  List<Entity> entities = new List<Entity>();
  List<Bullet> bullets = new List<Bullet>();

 Game(){
   this.rows = 3;
   this.level = 1;
   this.running = false;
   this.gameOver = false;
   this.score = 0;
   this.character = new Character.On(this);
 }


  void moveEntities(int maxPos){
    entities.forEach((x) => x.move());
    for (int i = 0; i < entities.length - 1; i++)
    {
      if(entities.elementAt(i).currentPos <= 0){
       if(entities.elementAt(i).row == character.currentRow){
         entities.elementAt(i).onTouch();
       }
        entities.removeAt(i);
      }
      for(int j = 0; j< bullets.length; j++){
        if(entities.elementAt(i).currentPos == bullets.elementAt(j).currentPos && entities.elementAt(i).row == bullets.elementAt(j).row){
          entities.elementAt(i).onHit();
          bullets.removeAt(j);
        }
      }

    }
  }

  void movePickUps(){}

  void moveBullets(int maxPos){
   bullets.forEach((x) => x.move());
    for (int i = 0; i < bullets.length - 1; i++)
    {
      if(bullets.elementAt(i).currentPos > 50){
        entities.removeAt(i);
      }
      for(int j = 0; j < entities.length;j++){
        if(entities.elementAt(i).currentPos == bullets.elementAt(j).currentPos && entities.elementAt(i).row == bullets.elementAt(j).row){
          entities.elementAt(i).onHit();
          bullets.removeAt(j);
        }
      }
    }
  }

  void levelUp(){}

  void spawnEntities() {
   for(int row = 0; row <= rows; row++) {
     int id = entities.length;

     entities.add(new Enemy1.on(this, id, row));
   }
  }

  void shootBullet(){
   int id = bullets.length;
   bullets.add(new Arrow(this,id,character.currentRow));
  }

  void addPoints(int points){
    score = score + points;
  }

}
///////////////////////////////////////////////////////////////////////
class Character{
  int currentRow = 1;
  int ammo = 999;
  double health = 3.0;
  bool alive;
  bool netOut;
  bool noAmmo;
  Game _game;

  void shootBullet(){
    if(!noAmmo) {
      ammo = ammo - 1;
      if(ammo == 0){
        noAmmo = true;
      }
    }
  }

  void shootNet(){}

  void moveUp(){
    if(currentRow > 0) {
      currentRow = currentRow - 1;
    }
  }

  void moveDown(){
    if(currentRow < _game.rows) {
      currentRow = currentRow + 1;
    }
  }

  void receiveDamage(double damage){
    health = health - damage;
  }

  Character.On(Game _game){
    this._game = _game;
    alive = true;
    netOut = false;
    noAmmo = false;
  }
}
//////////////////////////////////////////////////////////////////////
abstract class Entity{
  int id;
  int row;
  int currentPos;
  int health;
  int speed;
  int lootProbability;
  int points;
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
  final health = 1;
  final points = 1;
  final damage = 1.0;
  final speed = 1;

  void onHit(){
    health = health - 1;
  }

  void onDeath(){
    _game.entities.remove(this);
    _game.addPoints(points);
  }

  void onCatch(){}

  void onTouch(){
    _game.character.receiveDamage(damage);
  }

  void move(){
    currentPos = currentPos - speed;
  }

  Enemy1.on(Game _game, int id,int row){
    this._game = _game;
    this.id = id;
    this.row = row;
  }
}

/////////////////////////////////////////////////////////////////////
abstract class Bullet{
  int id;
  int row;
  int currentPos;
  void move();
  Game _game;
}

class Arrow extends Bullet{

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
