part of hunt;
int firstY;
int lastY;


class GameController{


  GameController() {
    //Character Movement by comparing first and last Y-value (Up/Down)
    window.onTouchStart.listen((TouchEvent e){                            //Determine first Y-value
      firstY = e.touches.first.client.y.toInt();
    });

    window.onTouchMove.listen((TouchEvent e) {                            //Determine last Y-value
      lastY = e.touches.last.client.y.toInt();
    });

    window.onTouchEnd.listen((TouchEvent e) {                             //Compares both Y-values
      if (firstY < lastY && (lastY - firstY) > 70) {        //Swipe Down
        querySelector('#output').text = "Down";
      }
      else if (firstY > lastY && (firstY - lastY) > 70) {   //Swipe Up
        querySelector('#output').text = "Up";
      }
    });
  }
}