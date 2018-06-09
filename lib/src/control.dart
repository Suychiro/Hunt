part of hunt;



class GameController{

  var game = new Game();
  var view = new GameView();

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

  GameController() {

    int firstY;
    int lastY;
    bool touchMoved = false;

    window.onLoad.listen((_){
      window.scrollTo(0,0);
    });
    /**
     *  Character Movement by comparing first and last Y-value (Up/Down)
     */
    window.onTouchStart.listen((TouchEvent e){                            //Determine first Y-value
      firstY = 0;
      firstY = e.touches.first.client.y.toInt();
    });

    window.onTouchMove.listen((TouchEvent e) {                            //Determine last Y-value
      e.preventDefault();
      lastY = e.touches.last.client.y.toInt();
      touchMoved = true;
    });

  window.onTouchEnd.listen((TouchEvent e) {    //Compares both Y-values
    if(game.running == true && touchMoved) {
      if (firstY < lastY && (lastY - firstY) > 40) { //Swipe Down
        game.character.moveDown();
      }
      else if (firstY > lastY && (firstY - lastY) > 40) { //Swipe Up
        game.character.moveUp();
      }
      firstY = 0;
      lastY = 0;
      touchMoved = false;
      view.updateCharacter(game);
    }
  });

    window.onKeyDown.listen((KeyboardEvent ev) {
      if (game.running) {
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
      bulletTrigger = new Timer.periodic(new Duration(milliseconds: 25), (_) => moveBullets());
      spawnTrigger = new Timer.periodic(new Duration(seconds: 3),(_) => spawnEntities());
      entityTrigger = new Timer.periodic(new Duration(milliseconds: 70),(_) => moveEntities());
    });

    view.shootButton.onClick.listen((_) {
      game.shootBullet();
    });

    window.onBlur.listen((_){
      if(game.running) {
        game.paused = true;
      }
    });

    window.onFocus.listen((_){
      if(game.running) {
        game.paused = false;
      }
    });
  }

  void focusHandler(Event e) {
    print('focus: $e');
  }



  void start(){
    view.createField(game);
    game.running = true;
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