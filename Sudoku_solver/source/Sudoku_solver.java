import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Sudoku_solver extends PApplet {

int board[][] = { //<>// //<>//
  {0, 1, 0, 0, 0, 7, 5, 0, 0}, 
  {5, 0, 3, 0, 9, 0, 0, 0, 0}, 
  {2, 0, 0, 0, 0, 0, 0, 0, 0}, 

  {0, 0, 9, 7, 0, 0, 2, 0, 0}, 
  {4, 0, 0, 0, 0, 5, 0, 0, 9}, 
  {0, 2, 1, 0, 0, 0, 8, 0, 3}, 

  {1, 0, 7, 0, 6, 0, 0, 8, 0}, 
  {3, 0, 0, 1, 0, 0, 0, 4, 0}, 
  {0, 9, 5, 0, 0, 4, 1, 0, 6}, 
};

Pos[][] pos = new Pos[9][9];
int pos_size;
int[] numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9};
boolean controlIsDown = false; 
float m_X = 0, m_Y = 0;
public void setup() {
  

  pos_size = width / 9; //67 pix

  initBoard();
  loadBoard();
}
public void draw() {
  background(255);
  show();
  lines();
}

public void initBoard() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j] = new Pos(0, new PVector(i*pos_size, j*pos_size));
    }
  }
}
public void loadBoard() {
  JSONObject json = null;
  try {
    String FORMAT = "http://www.cs.utep.edu/cheon/ws/sudoku/new/?size=%d&level=%d";
    int size = 9;
    int level = 1;
    String url = String.format(FORMAT, size, level);
    json = loadJSONObject(url);
    for (int i = 0; i < json.getJSONArray("squares").size(); i++) {
      int x, y, n;
      x = json.getJSONArray("squares").getJSONObject(i).getInt("x");
      y = json.getJSONArray("squares").getJSONObject(i).getInt("y");
      n = json.getJSONArray("squares").getJSONObject(i).getInt("value");
      pos[x][y].setNum(n);
      pos[x][y].changable = false;
    }
  }
  catch (NullPointerException  e) {
    //e.printStackTrace();
  }
  finally {
    if (json == null) {
      loadStaticBoard();
    }
  }
}
public void loadStaticBoard() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].setNum(board[j][i]);
      pos[i][j].changable = false;
    }
  }
}
public void lines() {
  push();
  strokeWeight(4);
  line(width/3, 0, width/3, height);
  line(2*width/3, 0, 2*width/3, height);
  line(0, height/3, width, height/3);
  line(0, 2*height/3, width, 2*height/3);
  pop();
}
public void Clear() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].setNum(0);
    }
  }
}

public void show() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].show();
      for (int k = 0; k < 3; k++) {
        for (int l = 0; l < 3; l++) {
          pos[i][j].note[k][l].show();
        }
      }
    }
  }
}
public void mouseClicked() {
  m_X = mouseX;
  m_Y = mouseY;
  if (mouseButton == RIGHT) {
    int kb_x = 0, kb_y = 0;
    for (int j = 0; j < 9; j++) { 
      for (int i = 0; i < 9; i++) {
        if (pos[i][j].isClicked()) {
          if (pos[i][j].selected) {
            pos[i][j].selected = false;
            stopHighlights();
          } else {
            pos[i][j].selected = true;
            for (int y = 0; y < 9; y++) {
              for (int x = 0; x < 9; x++) {
                if (x % 3 == 0) {
                  kb_x = x;
                }
                if (y % 3 == 0) {
                  kb_y = y;
                }
                if (x == i || y == j || ( i >= kb_x && i < kb_x + 3 && j >= kb_y && j < kb_y + 3)) {
                  pos[x][y].highlights = true;
                } else
                  pos[x][y].highlights = false;
              }
              println();
            }
          }
        } else {
          pos[i][j].selected = false;
        }
      }
    }
  } else if (mouseButton == LEFT) {
    for (int j = 0; j < 9; j++) { 
      for (int i = 0; i < 9; i++) {
        if (pos[i][j].isClicked()) {
          if (pos[i][j].getNum() == 0) {
            pos[i][j].selected = false;
          } else {
            pos[i][j].selected = true;
            markThatNumber(pos[i][j].getNum());
          }
        } else {
          pos[i][j].highlights = false;
        }
      }
    }
  }
}

public void stopHighlights() {

  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].highlights = false;
    }
  }
}
public void keyPressedForNormalSituation() {
  if (key == CODED) { 
    switch(keyCode) {
    case CONTROL:
      controlIsDown = true;
      break;
    }
  }
}


public void keyPressed() {
  if (key == 'm') {
    markThatNumber(1);
  }
  if (key =='c') {
    Clear();
  }
  if (key == 'x') {
    solve();
    println("done");
  }
  if (key == 'z') {
    for (int y = 0; y < 9; y++) {
      for (int x = 0; x < 9; x++) {
        if (pos[x][y].getNum() == 0) {
          print("- ");
        } else {
          print(pos[x][y].num+" ");
        }
      }
      println();
    }
  }

  if (controlIsDown) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (pos[i][j].isClicked()) {
          switch(keyCode) {
          case '1': 
            pos[i][j].note[0][0].showed = !pos[i][j].note[0][0].showed;
            break;
          case '2': 
            pos[i][j].note[1][0].showed = !pos[i][j].note[1][0].showed;
            break;
          case '3': 
            pos[i][j].note[2][0].showed = !pos[i][j].note[2][0].showed;
            break;
          case '4': 
            pos[i][j].note[0][1].showed = !pos[i][j].note[0][1].showed;
            break;
          case '5': 
            pos[i][j].note[1][1].showed = !pos[i][j].note[1][1].showed;
            break;
          case '6': 
            pos[i][j].note[2][1].showed = !pos[i][j].note[2][1].showed;
            break;
          case '7': 
            pos[i][j].note[0][2].showed = !pos[i][j].note[0][2].showed;
            break;
          case '8': 
            pos[i][j].note[1][2].showed = !pos[i][j].note[1][2].showed;
            break;
          case '9': 
            pos[i][j].note[2][2].showed = !pos[i][j].note[2][2].showed;
            break;
          }
        }
      }
    }
  } else {
    putNumber();
    keyPressedForNormalSituation();
  }

  if (key == 'q') {
    if (possible(1, 0, 0)) {
      print("true");
    } else
      print("false");
  }
}

public void keyReleased() {
  switch(keyCode) {
  case CONTROL:
    controlIsDown = false;
    break;
  }
}
public boolean possible(int n, int a, int b) {
  int kb_x = 0, kb_y = 0;

  for (int x = 0; x < 9; x++) {
    for (int y = 0; y < 9; y++) {
      if (x % 3 == 0) {
        kb_x = x;
      }
      if (y % 3 == 0) {
        kb_y = y;
      }
      if (x == a || y == b || ( a >= kb_x && a < kb_x + 3 && b >= kb_y && b < kb_y + 3)) {
        if (pos[x][y].getNum() != 0) {
          if (pos[x][y].num == n) {
            return false;
          }
        }
      }
    }
  }
  return true;
}

public void putNumber() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (pos[i][j].isClicked()) {
        if (key - 47 > 0 && key - 48 < 10) {
          if (key == '0') {
            pos[i][j].setNum(0);
          } else {              
            if (possible(key-48, i, j)) {
            } else {
            }
            pos[i][j].setNum(key-48);
          }
        }
      }
    }
  }
}
public boolean numberDone(int n) {
  int br = 0;
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (pos[i][j].getNum() == n) {
        br++;
      }
    }
  }
  return br != 9 ? false : true;
}
public void markThatNumber(int n) {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (pos[i][j].getNum() == n && pos[i][j].getNum() != 0) {
        pos[i][j].highlights = true;
      } else {
        pos[i][j].highlights = false;
      }
    }
  }
}

public boolean solve() {
  for (int x = 0; x < 9; x++) {
    for (int y = 0; y < 9; y++) {
      if (pos[x][y].getNum() == 0) {
        boolean flag = false;
        for (int n = 1; n <= 9; n++) {
          if (possible(n, x, y) && !flag) {
            pos[x][y].setNum(n);
            flag = true;
            if (solve() == false) {
              flag = false;
            }
          }
        }
        if (!flag) {
          pos[x][y].setNum(0);
          return false;
        }
      }
    }
  }
  return true;
}
class Notes {
  PVector v;
  int number = 0;
  boolean showed = false;

  Notes(int n, PVector v) {
    number = n;
    this.v = v;
  }
  
  public void show() {
    textSize(16);
    fill(0, 49, 82);
    float x = v.x;
    float y = v.y;
    if (showed && this.number != 0) {
      text(this.number, x+pos_size/6, y+pos_size/6);
    }
  }
}
class Pos {
  int num;
  PVector vec;
  boolean changable = true;
  boolean selected = false;
  boolean highlights = false;
  boolean number_done = false;
  Notes[][] note = new Notes[3][3];


  Pos(int num, PVector vec) {
    this.num = num;
    this.vec = vec;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        note[i][j] = new Notes((i+j*3)+1, new PVector(vec.x+i*pos_size/3, vec.y+j*pos_size/3));
      }
    }
  }

  public void setNum(int num) {
    if (this.changable)
      this.num = num;
  }

  public int getNum() {
    return this.num;
  }

  public boolean isClicked() {

    if (m_X > vec.x && m_X < vec.x + pos_size && m_Y > vec.y &&  m_Y  < vec.y + pos_size) {
      return true;
    }

    return false;
  }



  public void show() {
    if (selected) {
      fill(150, 170, 210);
    } else if (highlights) {
      fill(176, 223, 229);
    } else {
      noFill();
    }
    square(vec.x, vec.y, pos_size);
    textAlign(CENTER, CENTER);
    textSize(32);
    //fill(0, 49, 82);

    if (this.num == 0) {
      text(" ", vec.x+pos_size/2, vec.y+pos_size/2);
    } else {
      if (!this.changable) {
        fill(0, 0, 0);
      } else if (this.changable) {
        fill(0, 49, 132);
      } else if (this.number_done) {
        fill(50, 200, 50);
      }
      text(this.num, vec.x+pos_size/2, vec.y+pos_size/2);
    }
  }
}
  public void settings() {  size(603, 603); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Sudoku_solver" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
