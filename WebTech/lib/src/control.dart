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
    window.screen.orientation.lock("landscape");
    int firstY;
    int lastY;
    bool touchMoved = false;
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
    if(game.running == true && touchMoved) {
      if (firstY < lastY && (lastY - firstY) > 70) { //Swipe Down
        game.character.moveDown();
      }
      else if (firstY > lastY && (firstY - lastY) > 70) { //Swipe Up
        game.character.moveUp();
      }
      firstY = 0;
      lastY = 0;
      touchMoved = false;
      view.update(game);
    }
  });

    /**
     * Speed of Trigger
     */


   /*
    spawnTrigger = new Timer.periodic(new Duration(seconds: 2),(_) => spawnEntities());
    entityTrigger = new Timer.periodic(new Duration(milliseconds: 25),(_) => moveEntities());
    bulletTrigger = new Timer.periodic(new Duration(milliseconds: 25), (_) => moveBullets());
*/
    view.startButton.onClick.listen((_) {
      start();
      spawnEntities();
    });

    view.shootButton.onClick.listen((_) {
      game.shootBullet();
    });
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
    view.update(game);
  }

  /**
   * Makes the entities move when triggered
   */
  void moveEntities(){
    game.moveEntities(50);
    view.update(game);
  }

  /**
   * Makes the bullets move when triggered
   */
  void moveBullets(){
    game.moveBullets(50);
    view.update(game);
  }

}