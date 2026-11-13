Corgi corgi;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
ArrayList<Coin> coins = new ArrayList<Coin>();
float[] lanes = new float[3];
int score = 0;
boolean gameOver = false;
float gameSpeed = 5.5;

void setup() {
  size(480, 800);
  lanes[0] = width * 0.22;
  lanes[1] = width * 0.50;
  lanes[2] = width * 0.78;
  corgi = new Corgi();
}

void draw() {
  background(120, 195, 110);
  drawTracks();

  if (!gameOver) {
    gameSpeed = min(9.5, 5.5 + score * 0.002);

    if (frameCount % 75 == 0) {
      spawnPattern();
    }

    for (int i = coins.size() - 1; i >= 0; i--) {
      Coin c = coins.get(i);
      c.update();
      c.display();
      if (c.hits(corgi)) {
        score += 10;
        coins.remove(i);
      } else if (c.offscreen()) {
        coins.remove(i);
      }
    }

    for (int i = obstacles.size() - 1; i >= 0; i--) {
      Obstacle obs = obstacles.get(i);
      obs.update();
      obs.display();
      if (obs.hits(corgi)) {
        gameOver = true;
      }
      if (obs.offscreen()) {
        obstacles.remove(i);
      }
    }

    corgi.update();
    corgi.display();
    drawUI();
  } else {
    drawGameOver();
  }
}

void drawTracks() {
  float trackWidth = width * 0.22;
  for (float x : lanes) {
    fill(160, 155, 145);
    noStroke();
    rectMode(CENTER);
    rect(x, height / 2.0, trackWidth, height);

    fill(110, 75, 45);
    float offset = (frameCount * gameSpeed) % 40;
    for (float y = -40 + offset; y < height + 40; y += 40) {
      rect(x, y, trackWidth * 0.85, 10, 3);
    }

    fill(210, 215, 220);
    rect(x - trackWidth * 0.3, height / 2.0, 6, height);
    rect(x + trackWidth * 0.3, height / 2.0, 6, height);
  }
}

void spawnPattern() {
  int laneIndex = int(random(3));
  String[] types = {"train", "jump_bar", "duck_bar"};
  String type = types[int(random(3))];
  obstacles.add(new Obstacle(laneIndex, type));

  int coinLane = (laneIndex + int(random(1, 3))) % 3;
  for (int i = 0; i < 3; i++) {
    coins.add(new Coin(coinLane, -50 - i * 45));
  }
}

class Corgi {
  int lane = 1;
  float x, y, z = 0, vz = 0;
  boolean isDucking = false;
  int duckTimer = 0;

  Corgi() {
    x = lanes[lane];
    y = height * 0.8;
  }

  void move(int dir) {
    lane = constrain(lane + dir, 0, 2);
  }

  void jump() {
    if (z == 0) {
      vz = 14;
      isDucking = false;
    }
  }

  void duck() {
    if (z > 0) vz = -15;
    isDucking = true;
    duckTimer = 42;
  }

  void update() {
    x = lerp(x, lanes[lane], 0.25);
    z += vz;
    if (z > 0) {
      vz -= 0.8;
    } else {
      z = 0;
      vz = 0;
    }
    if (isDucking) {
      duckTimer--;
      if (duckTimer <= 0) isDucking = false;
    }
  }

  void display() {
    pushMatrix();
    translate(x, y - z);

    fill(0, 0, 0, 50);
    noStroke();
    ellipse(0, z + 25, 45 - z * 0.2, 20);

    float scaleY = isDucking ? 0.55 : 1.0;
    float bounce = (z == 0) ? sin(frameCount * 0.35) * 3 : 0;
    scale(1, scaleY);
    translate(0, bounce);

    // 몸통 & 식빵 엉덩이
    fill(235, 155, 65);
    rectMode(CENTER);
    rect(0, 5, 42, 52, 20);

    fill(255, 250, 240);
    ellipse(0, 22, 34, 22);
    float tailWag = sin(frameCount * 0.5) * 6;
    ellipse(tailWag, 26, 14, 14);

    // 짧은 뒷발
    float legOffset = sin(frameCount * 0.4) * 6;
    fill(255);
    ellipse(-14, 24 + legOffset, 12, 14);
    ellipse(14, 24 - legOffset, 12, 14);

    // 쫑긋한 귀
    fill(220, 130, 50);
    triangle(-20, -15, -28, -42, -6, -24);
    triangle(20, -15, 28, -42, 6, -24);
    fill(255, 195, 195);
    triangle(-18, -18, -24, -36, -9, -24);
    triangle(18, -18, 24, -36, 9, -24);

    // 머리 & 흰색 무늬
    fill(240, 165, 75);
    ellipse(0, -15, 44, 38);
    fill(255);
    ellipse(0, -18, 12, 26);

    // 볼터치
    fill(255, 130, 140, 160);
    ellipse(-15, -10, 10, 7);
    ellipse(15, -10, 10, 7);

    popMatrix();
  }
}

class Obstacle {
  int lane;
  float x, y = -80;
  String type;

  Obstacle(int lane, String type) {
    this.lane = lane;
    this.x = lanes[lane];
    this.type = type;
  }

  void update() {
    y += gameSpeed;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rectMode(CENTER);

    if (type.equals("train")) {
      fill(65, 105, 180);
      rect(0, 0, 56, 110, 10);
      fill(95, 140, 215);
      rect(0, -5, 46, 90, 6);
      fill(255, 240, 150);
      ellipse(-16, 45, 10, 10);
      ellipse(16, 45, 10, 10);
    } else if (type.equals("jump_bar")) {
      fill(230, 70, 70);
      rect(0, 0, 62, 20, 5);
      fill(255);
      rect(-15, 0, 10, 20);
      rect(15, 0, 10, 20);
      fill(255, 230, 0);
      textAlign(CENTER, CENTER);
      textSize(11);
      text("JUMP", 0, 0);
    } else if (type.equals("duck_bar")) {
      fill(90);
      rect(-28, 0, 6, 35);
      rect(28, 0, 6, 35);
      fill(255, 175, 0);
      rect(0, -12, 66, 24, 5);
      fill(30);
      textAlign(CENTER, CENTER);
      textSize(11);
      text("DUCK", 0, -12);
    }
    popMatrix();
  }

  boolean hits(Corgi c) {
    if (lane != c.lane) return false;
    float distY = abs(y - c.y);
    if (type.equals("train")) return distY < 60;
    if (type.equals("jump_bar")) return distY < 22 && c.z < 25;
    if (type.equals("duck_bar")) return distY < 22 && !c.isDucking;
    return false;
  }

  boolean offscreen() {
    return y > height + 100;
  }
}

class Coin {
  int lane;
  float x, y;

  Coin(int lane, float y) {
    this.lane = lane;
    this.x = lanes[lane];
    this.y = y;
  }

  void update() {
    y += gameSpeed;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    float w = abs(sin(frameCount * 0.1)) * 18 + 8;
    fill(255, 215, 0);
    stroke(210, 150, 0);
    strokeWeight(2);
    ellipse(0, 0, w, 24);
    popMatrix();
  }

  boolean hits(Corgi c) {
    return lane == c.lane && abs(y - c.y) < 35;
  }

  boolean offscreen() {
    return y > height + 50;
  }
}

void drawUI() {
  fill(255);
  textSize(24);
  textAlign(LEFT, TOP);
  text("SCORE: " + score, 20, 20);
}

void drawGameOver() {
  fill(0, 160);
  rectMode(CORNER);
  rect(0, 0, width, height);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(36);
  text("GAME OVER", width / 2.0, height * 0.42);
  textSize(22);
  text("Score: " + score, width / 2.0, height * 0.5);
  textSize(16);
  fill(255, 220, 100);
  text("Press SPACE to Restart", width / 2.0, height * 0.58);
}

void keyPressed() {
  if (gameOver && key == ' ') {
    obstacles.clear();
    coins.clear();
    score = 0;
    gameSpeed = 5.5;
    corgi = new Corgi();
    gameOver = false;
    return;
  }
  if (keyCode == LEFT) corgi.move(-1);
  else if (keyCode == RIGHT) corgi.move(1);
  else if (keyCode == UP) corgi.jump();
  else if (keyCode == DOWN) corgi.duck();
}
