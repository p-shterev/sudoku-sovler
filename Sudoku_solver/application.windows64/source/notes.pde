class Notes {
  PVector v;
  int number = 0;
  boolean showed = false;

  Notes(int n, PVector v) {
    number = n;
    this.v = v;
  }
  
  void show() {
    textSize(16);
    fill(0, 49, 82);
    float x = v.x;
    float y = v.y;
    if (showed && this.number != 0) {
      text(this.number, x+pos_size/6, y+pos_size/6);
    }
  }
}
