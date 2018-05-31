part of hunt;
/**
 * Object that interacts with the DOM-Tree
 * and reflects current game-state to the user.
 */
class GameView {
  final gameField = querySelector("#gameField");

  HtmlElement get startButton => querySelector('#start');
  HtmlElement get shootButton => querySelector('#shoot');

  void update(Game game) {
    var field = new List.generate(3, (_) => new List(50));

    if(game.character.currentRow == 0){
      querySelector('#field_0_0').setInnerHtml("<div id='character'></div>");
      querySelector('#field_1_0').innerHtml = "";
      querySelector('#field_2_0').innerHtml = "";
    }
    else if(game.character.currentRow == 1){
      querySelector('#field_0_0').innerHtml = "";
      querySelector('#field_1_0').setInnerHtml("<div id='character'></div>");
      querySelector('#field_2_0').innerHtml = "";
    }
    else if(game.character.currentRow == 2){
      querySelector('#field_0_0').innerHtml = "";
      querySelector('#field_1_0').innerHtml = "";
      querySelector('#field_2_0').setInnerHtml("<div id='character'></div>");
    }


  }

  //creates a 3x50 field as a table and adds it to the html
  createField(Game game) {
    var field = new List.generate(3, (_) => new List(50)); //multidimensional array
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
