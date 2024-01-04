class Layer {  

  float start, noize, speed;  
  float yOff, yOff2;  

  Layer(float _start, float _noize, float _speed) {  
    start = _start;  
    noize = _noize;  
    speed = _speed;
  }  

  void display() {  
    yOff = yOff2;  
    noStroke();  
    for (int x=0; x<width; x+=1) {  
      float y = start + noise(noize+sin(yOff)*3)*step*3.5;  
      rect(x, height, 1, -height+y);         
      yOff+=TWO_PI/(width);
    }  
    yOff2=theta*speed;
  }
}  
