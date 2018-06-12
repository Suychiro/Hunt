part of hunt;



class GameController{
  var game;
  var view = new GameView();
  Map<String,Map<String,double>> levelMap = new Map<String,Map<String,double>>();

  Duration spawn = new Duration(seconds: 3);
  Duration entity = new Duration(milliseconds: 70);
  Duration bullet = new Duration(milliseconds: 25);

  /**
   * Periodic trigger spawning entities
   */
  Timer spawnTrigger;

  /**
   * Periodic trigger moving entities
   */
  Timer entityTrigger;

  /**
   * Periodic Trigger moving bullets
   */
  Timer bulletTrigger;


  /**
   * Periodic Trigger moving bullets
   */
  Timer levelUpTrigger;

  GameController() {

    int firstY;
    int lastY;
    bool touchMoved = false;

    window.onLoad.listen((_){
      HttpRequest.getString("LevelConfig.json").then((jsonfile){
        levelMap = JSON.decode(jsonfile);
      });

    });



    /**
     *  Character Movement by comparing first and last Y-value (Up/Down)
     */
    window.onTouchStart.listen((TouchEvent e){                            //Determine first Y-value
      firstY = 0;
      firstY = e.touches.first.client.y.toInt();
    });

    window.onTouchMove.listen((TouchEvent e) {                            //Determine last Y-value
      lastY = e.touches.last.client.y.toInt();
      touchMoved = true;
    });

  window.onTouchEnd.listen((TouchEvent e) {    //Compares both Y-values
    if(game.started == true && touchMoved) {
      if (firstY < lastY && (lastY - firstY) > 30) { //Swipe Down
        game.character.moveDown();
      }
      else if (firstY > lastY && (firstY - lastY) > 30) { //Swipe Up
        game.character.moveUp();
      }
      firstY = 0;
      lastY = 0;
      touchMoved = false;
      view.updateCharacter(game);
    }
  });

    window.onKeyDown.listen((KeyboardEvent ev) {
      if (game.started) {
        switch (ev.keyCode) {
          case KeyCode.UP:
            game.character.moveUp(); break;
          case KeyCode.DOWN:
            game.character.moveDown(); break;
          case KeyCode.A:
            game.shootBullet(); break;
        }
        view.updateCharacter(game);
      }
    });

    /**
     * Speed of Trigger
     */


   /*


   */

    view.startButton.onClick.listen((_) {
      start();
      var spawnSpeedMultiplier = levelMap["level1"]["spawnSpeedMultiplier"];
      var entitySpeedMultiplier = levelMap["level1"]["entitySpeedMultiplier"];
      bulletTrigger = new Timer.periodic(bullet, (_) => moveBullets());
      spawnTrigger = new Timer.periodic(spawn * spawnSpeedMultiplier,(_) => spawnEntities());
      entityTrigger = new Timer.periodic(entity * entitySpeedMultiplier,(_) => moveEntities());
    });

    view.shootButton.onClick.listen((_) {
      game.shootBullet();
    });

    window.onBlur.listen((_){
      if(game.started) {
        game.paused = true;
      }
    });

    window.onFocus.listen((_){
      if(game.started) {
        game.paused = false;
      }
    });
  }

  void focusHandler(Event e) {
    print('focus: $e');
  }



  void start(){

    game = new Game (levelMap["level1"]["rows"].toInt(),0);
    view.createField(game);
    game.started = true;
  }

  /**
   * Makes the game spawn entities when triggered
   */
  void spawnEntities(){
    game.spawnEntities();
    view.updateEntities(game);
  }

  /**
   * Makes the entities move when triggered
   */
  void moveEntities(){
    game.moveEntities(49);
    view.updateEntities(game);
  }

  /**
   * Makes the bullets move when triggered
   */
  void moveBullets(){
    game.moveBullets(49);
    view.updateBullets(game);
  }

}