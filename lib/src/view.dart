part of hunt;
/**
 * Object that interacts with the DOM-Tree
 * and reflects current game-state to the user.
 */
class GameView {
  final gameField = querySelector("#gameField");

  HtmlElement get startButton => querySelector('#start');

  HtmlElement get shootButton => querySelector('#shoot');

  void updateCharacter(Game game) {
    var field = new List.generate(3, (_) => new List(50));

    if (game.character.currentRow == 0) {
      querySelector('#field_0_0').setInnerHtml("<div id='character'></div>");
      querySelector('#field_1_0').innerHtml = "";
      querySelector('#field_2_0').innerHtml = "";
    }
    else if (game.character.currentRow == 1) {
      querySelector('#field_0_0').innerHtml = "";
      querySelector('#field_1_0').setInnerHtml("<div id='character'></div>");
      querySelector('#field_2_0').innerHtml = "";
    }
    else if (game.character.currentRow == 2) {
      querySelector('#field_0_0').innerHtml = "";
      querySelector('#field_1_0').innerHtml = "";
      querySelector('#field_2_0').setInnerHtml("<div id='character'></div>");
    }
  }

  void updateEntities(Game game) {
    if (game.entities.isNotEmpty) {
      for (int i = 0; i < game.entities.length; i++) {
        if (game.entities.elementAt(i).alive) {
          if (game.entities.elementAt(i).currentPos <= 49) {
            if (game.entities.elementAt(i).currentPos >= 2) {
              querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + (game.entities.elementAt(i).currentPos).toString()).setInnerHtml("<div id ='enemy1'></div>");
              querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + ((game.entities.elementAt(i).currentPos + 1).toString())).innerHtml = "";
            }
            else if (game.entities.elementAt(i).currentPos <= 1 && game.entities.elementAt(i).row == game.character.currentRow) {
              querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos - 1).toString())).setInnerHtml("<div id='character'></div>");
            }
            else {
              querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos - 1).toString())).innerHtml = "";
              querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + (game.entities.elementAt(i).currentPos.toString())).innerHtml = "";
            }
          }
          else {
            querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + ((game.entities.elementAt(i).currentPos + 1).toString())).innerHtml = "";
            querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + (game.entities.elementAt(i).currentPos.toString())).innerHtml = "";
          }
        }
        else{
          querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + (game.entities.elementAt(i).currentPos.toString())).innerHtml = "";
          querySelector('#field_' + (game.entities.elementAt(i).row.toString()) + '_' + ((game.entities.elementAt(i).currentPos+1).toString())).innerHtml = "";
        }
      }
    }
  }



    void updateBullets(Game game) {
      if (game.bullets.isNotEmpty) {
        for (int i = 0; i < game.bullets.length; i++) {
          if (!game.bullets.elementAt(i).hit) {
            if (game.bullets.elementAt(i).currentPos <= 47) {
              querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + (game.bullets.elementAt(i).currentPos.toString())).setInnerHtml("<div id ='arrow'></div>");
              if (game.bullets.elementAt(i).currentPos > 1) {
                querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos - 1).toString())).innerHtml = "";
              }
              else {
                querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos - 1).toString())).setInnerHtml("<div id='character'></div>");
              }
            }
          }
          else {
            querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos).toString())).innerHtml = "";
            querySelector('#field_' + (game.bullets.elementAt(i).row.toString()) + '_' + ((game.bullets.elementAt(i).currentPos - 1).toString())).innerHtml = "";
          }
        }
      }
    }



    //creates a 3x50 field as a table and adds it to the html
    createField(Game game) {
      shootButton.style.display = "inline";
      querySelector("#menu").style.display = "none";
      var field = new List.generate(
          3, (_) => new List(50)); //multidimensional array
      String table = "";
      for (int row = 0; row < 3; row++) {
        table += "<tr>";
        for (int col = 0; col < 50; col++) {
          final assignment = field[row][col];
          final pos = "field_${row}_${col}";
          table += "<td id='$pos' class='$assignment'></td>";
        }
        table += "</tr>";
      }
      gameField.innerHtml = table;
      querySelector('#field_1_0').setInnerHtml("<div id='character'></div>");
    }
  }

