part of hunt;
/**
 * Object that interacts with the DOM-Tree
 * and reflects current game-state to the user.
 */
class GameView {

  /**
   * Element with id '#gamefield' of the DOM tree.
   * Contains the table used to visualize the field of the [Game]
   */
  final gameField = querySelector("#gameField");

  /**
   * Start-button of the game
   */
  HtmlElement get startButton => querySelector('#start');

  /**
   * Shoot-Arrow-button of the game
   */
  HtmlElement get shootButton => querySelector('#shoot');

  /**
   * Shoot-Net-button of the game
   */
  HtmlElement get netButton => querySelector("#netButton");

  /**
   * Element with id '#score' of the DOM tree.
   * Used to represent the [Game]-score
   */
  final score = querySelector('#score');

  /**
   * Element with id '#health' of the DOM tree.
   * Used to represent the [Character]-health
   */
  final health = querySelector('#health');

  /**
   * Element with id '#ammo' of the DOM tree.
   * Used to represent the [Character]-ammo
   */
  final ammo = querySelector('#ammo');

  /**
   * Element with id '#level' of the DOM tree.
   * Used to represent the current [Game]-level
   */
  final level = querySelector("#level");

  /**
   * Element with id '#landscape' of the DOM tree.
   * Used to show the user that he should turn his phone into landscape mode
   */
  final landscape = querySelector("#landscape");

  /**
   * Element with id '#doublePower' of the DOM tree.
   * Used to show if the double-points-Power-Up is active
   */
  final doublePoints = querySelector("#doublePower");

  /**
   * Element with id '#slowPower' of the DOM tree.
   * Used to show if the slow-game-Power-Up is active
   */
  final slowGame = querySelector("#slowPower");


  /**
   * Used to update the position of the [Character]
   */
  void updateCharacter(Game game) {
    var field = new List.generate(game.rows, (_) => new List(50));

    for(int i = 0; i < game.rows; i++){
      if (game.character.currentRow == i){
        querySelector('#field_' + i.toString() + "_0").setInnerHtml("<div id='character'></div>");
      }
      else{
        querySelector('#field_' + i.toString() + "_0").innerHtml = "";
      }
    }
  }

  /**
   * Updates the view according to the game state.
   * - Entities
   * - Bullets
   * - Power-Up
   * - Updates HUD
   */
  void update(Game game){
    for(int i = 0; i < 49; i++){
      for(int j = 0; j < game.rows; j++){
        querySelector('#field_' + j.toString() + "_" + i.toString()).innerHtml = "";
      }
    }
    for(int i = 0; i < game.entities.length; i++){
      if(game.entities.isNotEmpty){
        if(game.entities.elementAt(i).alive){
          querySelector('#field_'+game.entities.elementAt(i).row.toString()+'_'+game.entities.elementAt(i).currentPos.toString()).setInnerHtml(
              "<div id ='"+game.entities.elementAt(i).type+"'></div>");
        }
      }
    }
    for(int i = 0; i < game.bullets.length; i++){
      if(game.bullets.isNotEmpty){
        if(!game.bullets.elementAt(i).hit){
          querySelector('#field_'+game.bullets.elementAt(i).row.toString()+'_'+game.bullets.elementAt(i).currentPos.toString()).setInnerHtml(
              "<div id ='"+game.bullets.elementAt(i).type+"'></div>");
        }
      }
    }
    for(int i = 0; i < game.pickUps.length; i++){
      if(game.pickUps.isNotEmpty){
        if(!game.pickUps.elementAt(i).getRemove()){
          querySelector('#field_'+game.pickUps.elementAt(i).row.toString()+'_'+game.pickUps.elementAt(i).currentPos.toString()).setInnerHtml(
              "<div id ='"+game.pickUps.elementAt(i).type+"'></div>");
        }
      }
    }
    querySelector('#field_'+game.character.currentRow.toString()+'_0').setInnerHtml("<div id='character'></div>");
    updateHUD(game);
  }
/*
  void updateEntities(Game game) {
    if (game.entities.isNotEmpty && game.started) {
      for (int i = 0; i < game.entities.length; i++) {
        if (game.entities.elementAt(i).alive) {
          if (game.entities.elementAt(i).currentPos <= 49) {
            if (game.entities.elementAt(i).currentPos > 2) {
              querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + (game.entities.elementAt(i).currentPos).toString()).setInnerHtml(
                  "<div id ='"+game.entities.elementAt(i).type+"'></div>");
              querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + ((game.entities.elementAt(i).currentPos + 1).toString())).innerHtml = "";
            }
          }
        }
        else{
          if(game.entities.elementAt(i).currentPos >= 2){
            querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + (game.entities.elementAt(i).currentPos.toString())).innerHtml = "";
          }
          querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + ((game.entities.elementAt(i).currentPos+1).toString())).innerHtml = "";
        }
      }
    }
      updateHUD(game);
  }

  void updatePickUps(Game game){
    if(game.pickUps.isNotEmpty && game.started){
      for(int i = 0; i < game.pickUps.length; i++){
        if(!game.pickUps.elementAt(i).getRemove()){
          if (game.pickUps.elementAt(i).currentPos <= 49) {
            if (game.pickUps.elementAt(i).currentPos > 2) {
              querySelector('#field_' + (game.pickUps.elementAt(i).row.toString()) + '_' + (game.pickUps.elementAt(i).currentPos).toString()).setInnerHtml(
                  "<div id ='"+game.pickUps.elementAt(i).type+"'></div>");
              querySelector('#field_' + (game.pickUps.elementAt(i).row.toString()) + '_' + ((game.pickUps.elementAt(i).currentPos + 1).toString())).innerHtml = "";
            }
          }
        }
        else{
          if(game.pickUps.elementAt(i).currentPos >= 2){
            querySelector('#field_' + (game.pickUps.elementAt(i).row.toString()) + '_' + (game.pickUps.elementAt(i).currentPos.toString())).innerHtml = "";
          }
          querySelector('#field_' + (game.pickUps.elementAt(i).row.toString()) + '_' + ((game.pickUps.elementAt(i).currentPos+1).toString())).innerHtml = "";
        }
      }
    }
  }

    void updateBullets(Game game) {
      if (game.bullets.isNotEmpty && game.started) {
        for (int i = 0; i < game.bullets.length; i++) {
          if (!game.bullets.elementAt(i).hit) {
            if (game.bullets.elementAt(i).currentPos <= 47) {
              querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + (game.bullets.elementAt(i).currentPos.toString())).setInnerHtml(
                  "<div id ="+game.bullets.elementAt(i).type+"></div>");

              if (game.bullets.elementAt(i).currentPos > 1) {
                querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos - 1).toString())).innerHtml = "";
              }
            }
          }
          else {
            querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos).toString())).innerHtml = "";
            querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos - 1).toString())).innerHtml = "";
          }
        }
      }
      updateHUD(game);
    }
*/

  /**
   * Updates the HUD based on the [game]-state
   * - current score
   * - current ammo
   * - current level
   * - current health
   * - active Power-Ups
   */
  void updateHUD(Game game){
    level.setInnerHtml("Level: " + game.level.toString());
    ammo.setInnerHtml("Ammo: "+ game.character.ammo.toString());
    score.setInnerHtml("Score: " + game.score.toString());
    if(game.character.health > 0) {
      health.setInnerHtml("<div id='health"+ game.character.health.toString() +"'></div>");
    }
    else {
      health.innerHtml = "";
    }
    if(game.getActiveDoubledPoints()){
      doublePoints.style.display = "inline";
    }
    else{
      doublePoints.style.display = "none";
    }
    if(game.getActiveSlowedDown()){
      slowGame.style.display = "inline";
    }
    else{
      slowGame.style.display = "none";
    }
  }

  /**
   * - stops displaying the menu and starts displaying the hud and the shoot-buttons
   * - creates the field based on the number of rows in [game]
   * - initializes the HUD-Elements
   */
  void createField(Game game) {
    querySelector("#gameField").innerHtml = "";
    shootButton.style.display = "inline";
    netButton.style.display = "inline";
    querySelector("#hud").style.display = "inline";
    querySelector("#menu").style.display = "none";
    querySelector("#instructions").style.display = "none";

    var field = new List.generate(
        game.rows, (_) => new List(50)); //multidimensional array
    String table = "";
    for (int row = 0; row < game.rows; row++) {
      table += "<tr>";
      for (int col = 0; col < 50; col++) {
        final assignment = field[row][col];
        final pos = "field_${row}_${col}";
        table += "<td id='$pos' class='$assignment'></td>";
      }
      table += "</tr>";
    }
    gameField.innerHtml = table;
    health.setInnerHtml("<div id='health"+ game.character.health.toString() +"'></div>");
    ammo.setInnerHtml("Ammo: "+ game.character.ammo.toString());
    querySelector('#field_'+game.character.currentRow.toString()+'_0').setInnerHtml("<div id='character'></div>");
  }

  /**
   * Recreates the field on Level-Up, with the new number of rows and all existing elements.
   */
  void updateField(Game game) {
    var field = new List.generate(
        game.rows, (_) => new List(50)); //multidimensional array
    String table = "";
    for (int row = 0; row < game.rows; row++) {
      table += "<tr>";
      for (int col = 0; col < 50; col++) {
        final assignment = field[row][col];
        final pos = "field_${row}_${col}";
        table += "<td id='$pos' class='$assignment'></td>";
      }
      table += "</tr>";
    }
    gameField.innerHtml = table;
    for(int i = 0; i < game.entities.length; i++){
      if(game.entities.elementAt(i).alive){
        querySelector('#field_'+game.entities.elementAt(i).row.toString()+'_'+game.entities.elementAt(i).currentPos.toString()).setInnerHtml(
          "<div id ='"+game.entities.elementAt(i).type+"'></div>");
      }
    }
    for(int i = 0; i < game.bullets.length; i++){
      if(!game.bullets.elementAt(i).hit){
        querySelector('#field_'+game.bullets.elementAt(i).row.toString()+'_'+game.bullets.elementAt(i).currentPos.toString()).setInnerHtml(
          "<div id ='"+game.bullets.elementAt(i).type+"'></div>");
      }
    }
    for(int i = 0; i < game.pickUps.length; i++){
      if(!game.pickUps.elementAt(i).getRemove()){
        querySelector('#field_'+game.pickUps.elementAt(i).row.toString()+'_'+game.pickUps.elementAt(i).currentPos.toString()).setInnerHtml(
            "<div id ='"+game.pickUps.elementAt(i).type+"'></div>");
      }
    }
    querySelector('#field_'+game.character.currentRow.toString()+'_0').setInnerHtml("<div id='character'></div>");
    updateHUD(game);
  }

  /**
   * Shows the instruction to turn the phone into landscape mode
   */
  void showLandscape(){
    landscape.style.display = "inline";
  }

  /**
   * Hides the landscape-instruction
   */
  void hideLandscape(){
    landscape.style.display = "none";
  }

  /**
   * Hides all relevant elements for the game.
   * Shows the Start-button and turns it into a Restart-button
   * Show the score of the previous game.
   */
  void gameOver(Game game){
    querySelector("#hud").style.display = "none";
    shootButton.style.display = "none";
    netButton.style.display = "none";
    querySelector("#menu").style.display = "inline";
    gameField.innerHtml = "";
    startButton.setInnerHtml("Restart");
    querySelector("#gameOver").style.display = "inline";
    querySelector("#endScore").style.display = "inline";
    querySelector("#endScore").setInnerHtml("Score: <br>"+game.score.toString());
  }
}

