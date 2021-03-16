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
int error_x = 0, error_y =0;
final static String TITLE = "Sudokuuuu";
PImage icon = new PImage();
void setup() {
  size(603, 603);

  icon = loadImage("/resource/icon.png");
  surface.setIcon(icon);
  changeAppTitle(TITLE);
  pos_size = width / 9; //67 pix

  initBoard();
  loadBoard();
}
void draw() {
  background(255);
  show();
  lines();
  numberDone();
}
void changeAppIcon(PImage img) {
  final PGraphics pg = createGraphics(16, 16, JAVA2D);

  pg.beginDraw();
  pg.image(img, 0, 0, 16, 16);
  pg.endDraw();

  frame.setIconImage(pg.image);
}

void changeAppTitle(String title) {
  surface.setTitle(title);
}
void initBoard() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j] = new Pos(0, new PVector(i*pos_size, j*pos_size));
    }
  }
}
void loadBoard() {
  JSONObject json = null;
  try {
    String FORMAT = "http://www.cs.utep.edu/cheon/ws/sudoku/new/?size=%d&level=%d";
    int size = 9;
    int level = round(random(1, 3));
    println(level);
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
void loadStaticBoard() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].setNum(board[j][i]);
      pos[i][j].changable = false;
    }
  }
}
void lines() {
  push();
  strokeWeight(4);
  line(width/3, 0, width/3, height);
  line(2*width/3, 0, 2*width/3, height);
  line(0, height/3, width, height/3);
  line(0, 2*height/3, width, 2*height/3);
  pop();
}
void Clear() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].setNum(0);
    }
  }
}
void allClear() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].clr();
      pos[i][j].changable = true;
    }
  }
}

void show() {
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
void mouseClicked() {
  stopHighlights();
  stopSelected();
  m_X = mouseX;
  m_Y = mouseY;
  if (mouseButton == RIGHT) {
    int kb_x = 0, kb_y = 0;
    for (int j = 0; j < 9; j++) { 
      for (int i = 0; i < 9; i++) {
        if (pos[i][j].isClicked()) {
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
              }
            }
          }
        }
      }
    }
  } else if (mouseButton == LEFT) {
    if (pos[error_x][error_y].error) {
      pos[error_x][error_y].setNum(0);
      turnOffError();
    }
    for (int j = 0; j < 9; j++) { 
      for (int i = 0; i < 9; i++) {
        if (pos[i][j].isClicked()) {
          pos[i][j].selected = true;
          if (pos[i][j].getNum() != 0) {            
            markThatNumber(pos[i][j].getNum());
          }
        }
      }
    }
  }
}

void stopHighlights() {

  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].highlights = false;
    }
  }
}
void stopSelected() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].selected = false;
    }
  }
}
void keyPressedForNormalSituation() {
  if (key == CODED) { 
    switch(keyCode) {
    case CONTROL:
      controlIsDown = true;
      break;
    }
  }
}


void keyPressed() {
  if (key == 'e') {
    allClear();
  }
  if (key =='c') {
    Clear();
  }
  if (key == 'x') {
    Clear();
    solve();
    numberDone();
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
    toggleNotes();
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

void keyReleased() {
  switch(keyCode) {
  case CONTROL:
    controlIsDown = false;
    break;
  }
}
boolean possible(int n, int a, int b) {
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
void toggleNotes() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (pos[i][j].isClicked() && pos[i][j].getNum() == 0) {
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
}
void row(int i, int j) {
  boolean flag = true;
  for (int x = 0; x < 9; x++) {
    if (x != i) {
      if (pos[x][j].getNum() == pos[i][j].getNum() && pos[i][j].getNum() != 0) {
        flag =  false;
      }
    }
  }
  for (int x = 0; x < 9; x++) {
    if (flag == false) {
      pos[x][j].error = true;
    }
  }
}
void column(int i, int j) {
  boolean flag = true;
  for (int y = 0; y < 9; y++) {
    if (y != j) {
      if (pos[i][y].getNum() == pos[i][j].getNum() && pos[i][j].getNum() != 0) {
        flag =  false;
      }
    }
  }
  for (int y = 0; y < 9; y++) {
    if (flag == false) {
      pos[i][y].error = true;
    }
  }
}



void square_(int i, int j) {
  int kb_x = 0, kb_y = 0;
  boolean flag = true;
  for (int x = 0; x < 9; x++) {
    for (int y = 0; y < 9; y++) {
      if (x % 3 == 0) {
        kb_x = x;
      }
      if (y % 3 == 0) {
        kb_y = y;
      }
      if ( i >= kb_x && i < kb_x + 3 && j >= kb_y && j < kb_y + 3) {
        if (x == i && y == j) {
          continue;
        }
        if (pos[x][y].getNum() == pos[i][j].getNum() && pos[i][j].getNum() != 0 ) {

          flag = false;
        }
      }
    }
  }

  kb_x = 0;
  kb_y = 0;

  for (int x = 0; x < 9; x++) {
    for (int y = 0; y < 9; y++) {
      if (x % 3 == 0) {
        kb_x = x;
      }
      if (y % 3 == 0) {
        kb_y = y;
      }
      if ( i >= kb_x && i < kb_x + 3 && j >= kb_y && j < kb_y + 3) {
        if (flag == false) {
          pos[x][y].error = true;
        }
      }
    }
  }
}
void turnOffError() {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      pos[i][j].error = false;
    }
  }
}


void putNumber() {

  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (pos[i][j].isClicked()) {
        error_x = i;
        error_y = j;
        if (key - 47 > 0 && key - 48 < 10) {
          if (key - 48 == 0) {
            pos[i][j].setNum(0);
          } else {
            pos[i][j].turnOffNotes();
            numberDone();
            pos[i][j].setNum(key-48);
          }
        }
      }
    }
  }
  turnOffError();
  square_(error_x, error_y);
  column(error_x, error_y);
  row(error_x, error_y);
}
void numberDone() {
  for (int n = 1; n < 10; n++) {
    int br = 0;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (pos[i][j].getNum() == n) {
          br++;
        }
      }
    }
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (pos[i][j].getNum() == n) {
          if (br == 9) {
            pos[i][j].number_done = true;
          } else {
            pos[i][j].number_done = false;
          }
        }
      }
    }
  }
}
void markThatNumber(int n) {
  for (int i = 0; i < 9; i++) {
    for (int j = 0; j < 9; j++) {
      if (pos[i][j].getNum() == n && pos[i][j].getNum() != 0) {
        pos[i][j].highlights = true;
      }
    }
  }
}

boolean solve() {
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
