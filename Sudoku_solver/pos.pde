class Pos {
  int num;
  PVector vec;
  boolean changable = true;
  boolean selected = false;
  boolean highlights = false;
  boolean number_done = false;
  boolean error = false;
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
  void clr() {
    this.num = 0;
    turnOffNotes();
  }
  void setNum(int num) {
    if (this.changable)
      this.num = num;
  }

  int getNum() {
    return this.num;
  }

  boolean isClicked() {

    if (m_X > vec.x && m_X < vec.x + pos_size && m_Y > vec.y &&  m_Y  < vec.y + pos_size) {
      return true;
    }

    return false;
  }

  void turnOffNotes() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        note[i][j].showed = false;
      }
    }
  }

  void show() {
    if (this.error && this.selected) {
      fill(248, 204, 208);
    } else if (this.error) {
      fill(252, 229, 231);
    } else if (selected) {
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
      if (this.error && this.selected) {
        fill(255, 0, 25);
      } else if (this.number_done) {
        fill(50, 200, 50);
      } else if (this.changable) {
        fill(0, 49, 132);
      } else if (!this.changable) {
        fill(0, 0, 0);
      }
      text(this.num, vec.x+pos_size/2, vec.y+pos_size/2);
    }
  }
}
