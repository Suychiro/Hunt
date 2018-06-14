part of hunt;
/**
 * Object that interacts with the DOM-Tree
 * and reflects current game-state to the user.
 */
class GameView {
  final gameField = querySelector("#gameField");

  HtmlElement get startButton => querySelector('#start');

  HtmlElement get shootButton => querySelector('#shoot');

  HtmlElement get netButton => querySelector("#netButton");

  HtmlElement get score => querySelector('#score');

  HtmlElement get health => querySelector('#health');

  HtmlElement get ammo => querySelector('#ammo');

  HtmlElement get level => querySelector("#level");

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
    }


    void createField(Game game) {
      querySelector("#gameField").innerHtml = "";
      shootButton.style.display = "inline";
      netButton.style.display = "inline";
      querySelector("#hud").style.display = "inline";
      querySelector("#menu").style.display = "none";

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
    querySelector('#field_'+game.character.currentRow.toString()+'_0').setInnerHtml("<div id='character'></div>");
  }


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

