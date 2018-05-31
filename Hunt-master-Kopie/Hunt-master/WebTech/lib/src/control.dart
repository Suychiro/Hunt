part of hunt;
int firstY;
int lastY;


class GameController{

  final game = querySelector("#gameField");

  GameController() {

    createField();

    //Character Movement by comparing first and last Y-value (Up/Down)
    window.onTouchStart.listen((TouchEvent e){                            //Determine first Y-value
      firstY = e.touches.first.client.y.toInt();
    });

    window.onTouchMove.listen((TouchEvent e) {                            //Determine last Y-value
      lastY = e.touches.last.client.y.toInt();
    });

    window.onTouchEnd.listen((TouchEvent e) {                             //Compares both Y-values
      if (firstY < lastY && (lastY - firstY) > 70) {        //Swipe Down
        if(querySelector('#field_0_0').text.isEmpty) {
          querySelector('#field_1_0').text = "";
          querySelector('#field_2_0').text = "test";
        }
        else if(!querySelector('#field_0_0').text.isEmpty) {
          querySelector('#field_0_0').text = "";
          querySelector('#field_1_0').text = "test";
          querySelector('#field_2_0').text = "";
        }
      }
      else if (firstY > lastY && (firstY - lastY) > 70) {   //Swipe Up
        if(querySelector('#field_2_0').text.isEmpty) {
          querySelector('#field_0_0').text = "test";
          querySelector('#field_1_0').text = "";
        }
        else if(!querySelector('#field_2_0').text.isEmpty) {
          querySelector('#field_0_0').text = "";
          querySelector('#field_1_0').text = "test";
          querySelector('#field_2_0').text = "";
        }
      }
    });
  }

  //creates a 3x50 field as a table and adds it to the html
  createField() {
    var field = new List.generate(3, (_) => new List(50)); //multidimensional array
    String table = "";
    for(int row = 0; row < 3; row++) {
      table += "<tr>";
      for(int col = 0; col < 50; col++) {
        final assignment = field[row][col];
        final pos = "field_${row}_${col}";
        table += "<td id='$pos' class='$assignment'></td>";
      }
      table += "</tr>";
    }
    game.innerHtml = table;
    querySelector('#field_1_0').text = "test";
  }
}