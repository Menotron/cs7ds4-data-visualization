import peasy.*;

PeasyCam cam;
PFont f1; 
Table races_per_track;
float radiusOfEarth = 200;

PImage earth;
PShape globe;

float viewAngle = 0;
PVector xAxis = new PVector(1, 0, 0);
boolean showLabel = false;
boolean showGP = true;
boolean showOthers = true;

void setup() {
  size(200, 200, P3D);
  frameRate(10);
  smooth();
  f1 = createFont("ARIAL", 100, true);
  textFont(f1);
  earth = loadImage("earth.5400x2700.png");
  races_per_track = loadTable("races_per_track.csv", "header");

  noStroke();
  globe = createShape(SPHERE, radiusOfEarth);
  globe.setTexture(earth);

  cam = new PeasyCam(this, 1000);
  cam.setDistance(600, 5000);
  cam.setMinimumDistance(400);
  cam.setMaximumDistance(700);
}


void draw() {
  background(0);
  noFill();
  shape(globe);
  //if (frameCount%300 == 0) {
  //  showLabel = !showLabel;
  // }

  for (TableRow row : races_per_track.rows ()) {
    float lat = row.getFloat("Lat");
    float lon = row.getFloat("Lon");
    int numRaces = row.getInt("Times");
    String track = row.getString("Track");
    String country = row.getString("Country");
    String classType  = row.getString("Class");

    float theta = radians(lat);
    float phi = radians(lon) + PI;
    float x = radiusOfEarth * cos(theta) * cos(phi);
    float y = -radiusOfEarth * sin(theta);
    float z = -radiusOfEarth * cos(theta) * sin(phi);

    float barHeight = numRaces;
    float maxh = 274;
    barHeight = map(barHeight, 0, maxh, 30, 300);

    PVector barPos = new PVector(x, y, z);
    float angleB = PVector.angleBetween(xAxis, barPos);
    PVector rotationAxis = xAxis.cross(barPos);
    if (classType.equals("MotoGP") && showGP)
      fill(150, 0, 0);
    else if (classType.equals("Other") && showOthers)
      fill(10, 0, 100);
    else
      continue;
    strokeWeight(0);
    pushMatrix();
    translate(x, y, z);
    rotate(angleB, rotationAxis.x, rotationAxis.y, rotationAxis.z);
    box(barHeight, 2, 2);
    textSize(6);
    fill(255);
    stroke(0);
    strokeWeight(10);
    //rotateX(viewAngle);
    if (mousePressed && (showGP || showOthers))
      text(track + ", " + country, barHeight/2 + 2, 2, 0);
    else
      text(numRaces, barHeight/2 + 2, 2, 0);

    popMatrix();
  }
  viewAngle+= 0.01;

  cam.beginHUD();
  fill(255);
  stroke(100);
  arc(100, width/2, 80, 80, PI, TWO_PI);
  strokeWeight(1);
  line(60, width/2 - 40, 60, width/2 -200);
  textSize(15);
  line(60, width/2 - 40, 140, width/2 - 40);
  text("0", 140 + 5, width/2 - 40);
  line(50, width/2 - 60, 70, width/2 - 60);
  text("2", 75, width/2 - 60);
  line(50, width/2 - 180, 70, width/2 - 180);
  text("274", 75, width/2 - 180);

  textAlign(CENTER);
  text("Number of Events", 100, width/2 - 230);
  textAlign(CENTER);
  text("Circuit Type", 80, 70);
  textSize(15);
  textAlign(LEFT);
  strokeWeight(5);
  text("MotoGP", 50, 100);
  fill(150, 0, 0);
  stroke(150, 0, 0);
  rect(130, 90, 40, 10);
  fill(255);
  stroke(100);
  text("Other", 50, 130);
  textSize(10);
  text("Click to view", 130, 70);
  textSize(20);
  textAlign(LEFT);
  text("MOTOGP CIRCUITS ACROSS THE GLOBE", width/2 - 200, 80);
  fill(10, 0, 100);
  stroke(10, 0, 100);
  rect(130, 120, 40, 10);


  if (mousePressed) {
    if (mouseX > 130 && mouseX < 130 + 40 && mouseY > 90 && mouseY < 100) 
      showGP = !showGP;
    if (mouseX > 130 && mouseX < 130 + 40 && mouseY > 120 && mouseY < 130) 
      showOthers = !showOthers;
  }


  cam.endHUD();
}
