part of hunt;


/**
 * A [GameController] object registers several handlers
 * to grab interactions of a user with a [Game] and translate
 * them into valid [Game] actions.
 *
 * Furthermore a [GameController] object triggers the
 * movements of all [Entity] / [Bullet] / [PickUp]  objects and the [Character] object of the
 *[Game].
 *
 * Necessary updates of the view are delegated to a [View] object
 * to inform the user about changing [Game] states.
 */

class GameController{

  /**
   * Referencing the to be controlled model.
   */
  var game = new Game(0);

  /**
   * Referencing the presenting view.
   */
  var view = new GameView();

  /**
   * Used to save the content of the JSON-File
   */
  Map<String,Map<String,double>> levelMap = new Map<String,Map<String,double>>();

  /**
   * Used to check if the Slow-Power-Up is active
   */
  bool slowInUse = false;

  /**
   * Used to check if the double-points-Power is active
   */
  bool doubleInUse = false;

  /**
   *  Defines the base spawn-frequency
   */
  Duration spawn = new Duration(seconds: 5);

  /**
   * Defines the base speed of the entities and Power-Ups
   */
  Duration entity = new Duration(milliseconds: 100);

  /**
   * Defines the base speed of the bullets
   */
  Duration bullet = new Duration(milliseconds: 25);

  /**
   * Used to save the Duration of the Power-Ups
   */
  int doublePointsDuration;
  int slowedGameDuration;

  /**
   * Used to save the current:
   * - spawn-frequency
   * - entity-speed
   * - the time it takes for a level up
   */
  Duration currentSpawn;
  Duration currentEntity;
  Duration currentLvlUp;

  /**
   * Stopwatches used to save the past time for
   * the Power-Ups and the Level-Up
   */
  Stopwatch levelTimer = new Stopwatch();
  Stopwatch slowDownTimer = new Stopwatch();
  Stopwatch doublePointsTimer = new Stopwatch();


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

  /**
   * Trigger to end the Double-Points-PowerUp
   */
  Timer doublePointsEndTrigger;

  /**
   * Trigger to end the Slow-Down-PowerUp
   */
  Timer slowDownEndTrigger;

  GameController() {
    int firstY;
    int lastY;
    bool touchMoved = false;
    bool down = false;


    /**
     * Used to save the content of the JSON - LevelConfig file in a Map onLoad
     */
    window.onLoad.listen((_){
      HttpRequest.getString("LevelConfig.json").then((jsonfile){
        levelMap = JSON.decode(jsonfile);
      });
    });

    /**
     * Used to determine the device orientation and pause if its in portrait mode
     */
    window.onDeviceOrientation.listen((DeviceOrientationEvent e){
      if(window.innerWidth < window.innerHeight){
        if(game.started && !game.paused) {
          pauseGame();
          view.showLandscape();
        }
      }
      else{
        if(game.started && game.paused) {
          view.hideLandscape();
          unpauseGame();
        }
      }
    });

    window.onDoubleClick.listen((Event e){
      e.preventDefault();
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
      if(game.paused){return;}
      if (firstY < lastY && (lastY - firstY) > 10) { //Swipe Down
        game.character.moveDown();
      }
      else if (firstY > lastY && (firstY - lastY) > 10) { //Swipe Up
        game.character.moveUp();
      }
      firstY = 0;
      lastY = 0;
      touchMoved = false;
      view.updateCharacter(game);
    }
  });

    /**
     * Implements controlls for the computer.
     */
  window.onKeyDown.listen((KeyboardEvent ev) {
    if (game.started && !game.paused) {
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

    /**
     * Sets the check-value to false when button is released
     *
     * Used to hinder multiple arrows by clicking once
     */
    window.onKeyUp.listen((KeyboardEvent ev) {
      down = false;
    });

    /**
     * Starts the game if the button is triggered.
     *
     * Sets and starts all relevant timers and sets the durations of the PowerUps
     */
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
      doublePointsDuration = levelMap["durations"]["doublePointsDurationInSeconds"].toInt();
      slowedGameDuration = levelMap["durations"]["slowDownDurationInSeconds"].toInt();
    });

    /**
     * Shoot an arrow if the button is triggered.
     */
    view.shootButton.onClick.listen((_) {
      if(game.paused){return;}
      game.shootBullet();
    });

    /**
     * Shoots the net if the Button is triggered.
     */
    view.netButton.onClick.listen((_) {
      if(game.paused){return;}
      game.shootNet();
    });

    /**
     * Pauses the game when the Webpage/App isn't focued
     */
    window.onBlur.listen((_){
      pauseGame();
    });

    /**
     * Unpauses the game when the Webpage/App gets focused
     */
    window.onFocus.listen((_){
      unpauseGame();
    });
  }

  /**
   * Pauses the game.
   * Stops the Stopwatches and cancels the timers.
   */
  void pauseGame(){
    if (game.started) {
      if(slowInUse){
        slowDownTimer.stop();
        slowDownEndTrigger.cancel();
      }
      if(doubleInUse){
        doublePointsTimer.stop();
        doublePointsEndTrigger.cancel();
      }
      levelTimer.stop();
      levelUpTrigger.cancel();
      spawnTrigger.cancel();
      entityTrigger.cancel();
      bulletTrigger.cancel();
      game.gamePaused();
    }
  }

  /**
   * Unpauses the game.
   * Sets all timers and starts the stopwatches again.
   */
  void unpauseGame(){
    if(game.started) {
      if(slowInUse){
        var passedSlowTime = slowDownTimer.elapsed.inSeconds;
        slowDownEndTrigger = new Timer(new Duration(seconds:(slowedGameDuration - passedSlowTime)), () => disableSlow());
        slowDownTimer.start();
      }
      if(doubleInUse){
        var passedDoubleTime = doublePointsTimer.elapsed.inSeconds;
        doublePointsEndTrigger = new Timer(new Duration(seconds:(doublePointsDuration - passedDoubleTime)), () => disableDouble());
        doublePointsTimer.start();
      }
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

  /**
   * Sets the model, creates the field accordingly and tell the model to start.
   */
  void start(){
    game = new Game (levelMap["level1"]["rows"].toInt());
    view.createField(game);
    game.gameStart();
  }

  /**
   * Makes the game spawn entities
   */
  void spawnEntities(){
    game.spawnEntities();
    //view.updateEntities(game);
    view.update(game);
  }

  /**
   * Makes the entities and pickUps move.
   * Checks if PickUps got picked up
   */
  void moveEntities(){
    game.moveEntities();
    if(!game.character.alive){
      gameOver();
      return;
    }
    //view.updateEntities(game);
    checkPowerUps();
    game.movePickUps();
    //view.updatePickUps(game);
    view.update(game);
  }

  /**
   * Makes the bullets move
   */
  void moveBullets(){
    game.moveBullets();
    //view.updateBullets(game);
    view.update(game);
  }


  /**
   * Checks if Power-Ups got picked up and activates/refreshes them
   */
  void checkPowerUps(){
    if(game.getSlowedGamePickedUp()){
      slowInUse = true;
      slowDownTimer.stop();
      slowDownTimer.reset();
      slowDownTimer.start();
      game.slowDownPickedUpProcessed();
      if(slowDownEndTrigger != null){
        if(slowDownEndTrigger.isActive){
          slowDownEndTrigger.cancel();
        }
      }
      entityTrigger.cancel();
      spawnTrigger.cancel();
      slowDownEndTrigger = new Timer(new Duration(seconds: slowedGameDuration), () => disableSlow());
      entityTrigger = new Timer.periodic((currentEntity * 1.5),(_) => moveEntities());
      spawnTrigger = new Timer.periodic((currentSpawn *1.5) ,(_) => spawnEntities());
    }
    if(game.doublePointsPickedUp){
      doubleInUse = true;
      doublePointsTimer.stop();
      doublePointsTimer.reset();
      doublePointsTimer.start();
      game.doublePickedUpProcessed();
      if(doublePointsEndTrigger != null){
        if(doublePointsEndTrigger.isActive){
          doublePointsEndTrigger.cancel();
        }
      }
      doublePointsEndTrigger = new Timer(new Duration(seconds: doublePointsDuration), () => disableDouble());
    }

  }

  /**
   * Disables the double-points-PowerUp
   */
  void disableDouble(){
    game.doublePointsPowerExpire();
    doublePointsTimer.stop();
    doubleInUse = false;
  }

  /**
   * Disables the slow-PowerUp
   */
  void disableSlow(){
    slowDownTimer.stop();
    entityTrigger.cancel();
    spawnTrigger.cancel();
    entityTrigger = new Timer.periodic(currentEntity,(_) => moveEntities());
    spawnTrigger = new Timer.periodic(currentSpawn,(_) => spawnEntities());
    game.slowDownPowerExpire();
    slowInUse = false;
  }


  /**
   * Handles Level-Up
   *
   * Sets the new amount of rows and sets the new timers(Function-Triggers) .
   */
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

  /**
   * Handles Game Over
   *
   * Cancels all timers and starts the GameOver functions of the model and view.
   */
  void gameOver(){
    spawnTrigger.cancel();
    entityTrigger.cancel();
    levelUpTrigger.cancel();
    bulletTrigger.cancel();
    if(slowDownEndTrigger != null){
      slowDownEndTrigger.cancel();
    }
    if(doublePointsEndTrigger != null){
      doublePointsEndTrigger.cancel();
    }
    levelTimer.stop();
    levelTimer.reset();
    view.gameOver(game);
    game.gameOver();

  }

}