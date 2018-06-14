part of hunt;



class GameController{
  var game = new Game(0);
  var view = new GameView();
  Map<String,Map<String,double>> levelMap = new Map<String,Map<String,double>>();

  Duration spawn = new Duration(seconds: 3);
  Duration entity = new Duration(milliseconds: 70);
  Duration bullet = new Duration(milliseconds: 25);

  Duration currentSpawn;
  Duration currentEntity;
  Duration currentLvlUp;
  Stopwatch levelTimer = new Stopwatch();



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
   * Periodic Trigger leveling up
   */
  Timer levelUpTrigger;

  GameController() {
    int firstY;
    int lastY;
    bool touchMoved = false;
    bool down = false;



    window.onLoad.listen((_){
      HttpRequest.getString("LevelConfig.json").then((jsonfile){
        levelMap = JSON.decode(jsonfile);
      });
    });

    window.onDeviceOrientation.listen((DeviceOrientationEvent e){
      if(window.innerWidth < window.innerHeight){
        pauseGame();

      }
      else{
        if(game.paused) {
          unpauseGame();
        }
      }
    });

    /**
     *  Character Movement by comparing first and last Y-value (Up/Down)
     */
    view.gameField.onTouchStart.listen((TouchEvent e){                            //Determine first Y-value
      firstY = 0;
      firstY = e.touches.first.client.y.toInt();
    });

    view.gameField.onTouchMove.listen((TouchEvent e) {                            //Determine last Y-value
      lastY = e.touches.last.client.y.toInt();
      touchMoved = true;
    });

   view.gameField.onTouchEnd.listen((TouchEvent e) {    //Compares both Y-values
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
          if(down == false) {
            down = true;
            game.shootBullet();
          }
          break;
        case KeyCode.S:
          game.shootNet();

      }
      view.updateCharacter(game);
    }
  });

    window.onKeyUp.listen((KeyboardEvent ev) {
      down = false;
    });



  view.startButton.onClick.listen((_) {
      start();
      if(bulletTrigger != null) bulletTrigger.cancel();
      if(spawnTrigger != null) spawnTrigger.cancel();
      if(entityTrigger != null) entityTrigger.cancel();
      if(levelUpTrigger != null) levelUpTrigger.cancel();
      currentSpawn = spawn * levelMap["level1"]["spawnSpeedMultiplier"];
      currentEntity = entity * levelMap["level1"]["entitySpeedMultiplier"];
      currentLvlUp = new Duration (seconds: levelMap["level1"]["levelDurationInSeconds"].toInt());
      bulletTrigger = new Timer.periodic(bullet, (_) => moveBullets());
      spawnTrigger = new Timer.periodic(currentSpawn,(_) => spawnEntities());
      entityTrigger = new Timer.periodic(currentEntity,(_) => moveEntities());
      levelUpTrigger = new Timer.periodic(currentLvlUp, (_) => levelUp());
      levelTimer.start();
    });

    view.shootButton.onClick.listen((_) {
      game.shootBullet();
    });

    view.netButton.onClick.listen((_) {
      game.shootNet();
    });

    window.onBlur.listen((_){
      pauseGame();
    });

    window.onFocus.listen((_){
      unpauseGame();
    });
  }

  void pauseGame(){
    if (game.started) {
      levelTimer.stop();
      levelUpTrigger.cancel();
      spawnTrigger.cancel();
      entityTrigger.cancel();
      bulletTrigger.cancel();
      game.gamePaused();
    }
  }

  void unpauseGame(){
    if(game.started) {
      var levelUpTimePassed = levelTimer.elapsed.inSeconds;
      currentLvlUp = new Duration(seconds: (levelMap["level"+game.level.toString()]["levelDurationInSeconds"].toInt() - levelUpTimePassed));
      levelUpTrigger = new Timer.periodic(currentLvlUp, (_) => levelUp());
      bulletTrigger = new Timer.periodic(bullet, (_) => moveBullets());
      spawnTrigger = new Timer.periodic(currentSpawn,(_) => spawnEntities());
      entityTrigger = new Timer.periodic(currentEntity,(_) => moveEntities());
      game.gameResumed();
      levelTimer.start();
    }
  }

  void start(){
    game = new Game (levelMap["level1"]["rows"].toInt());
    view.createField(game);
    game.gameStart();
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
    game.moveEntities();
    if(!game.character.alive){
      gameOver();
    }
    view.updateEntities(game);

  }

  /**
   * Makes the bullets move when triggered
   */
  void moveBullets(){
    game.moveBullets();
    view.updateBullets(game);
  }

  void levelUp(){

    var nextlevel = game.level + 1;
    if(levelMap.containsKey("level"+nextlevel.toString())){
      if(levelMap["level"+nextlevel.toString()].containsKey("rows")) {
        game.levelUp(levelMap["level" + nextlevel.toString()]["rows"].toInt());
      }
      if(levelMap["level"+nextlevel.toString()].containsKey("spawnSpeedMultiplier")) {
        spawnTrigger.cancel();
        currentSpawn = spawn * levelMap["level"+nextlevel.toString()]["spawnSpeedMultiplier"];
        spawnTrigger = new Timer.periodic(currentSpawn,(_) => spawnEntities());
      }
      if(levelMap["level"+nextlevel.toString()].containsKey("entitySpeedMultiplier")) {
        entityTrigger.cancel();
        currentEntity = entity * levelMap["level"+nextlevel.toString()]["entitySpeedMultiplier"];
        entityTrigger = new Timer.periodic(currentEntity,(_) => moveEntities());
      }
      if(levelMap["level"+nextlevel.toString()].containsKey("levelDurationInSeconds")) {
        levelUpTrigger.cancel();
        currentLvlUp = new Duration (seconds: levelMap["level"+nextlevel.toString()]["levelDurationInSeconds"].toInt());
        levelUpTrigger = new Timer.periodic(currentLvlUp,(_) => levelUp());

      }
      levelTimer.reset();
      view.updateField(game);
    }
  }

  void gameOver(){
    spawnTrigger.cancel();
    entityTrigger.cancel();
    levelUpTrigger.cancel();
    bulletTrigger.cancel();
    levelTimer.stop();
    view.gameOver(game);
    game.gameOver();

  }

}