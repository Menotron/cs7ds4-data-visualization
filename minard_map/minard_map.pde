import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.gicentre.geomap.*; 
import org.gicentre.utils.spatial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 


GeoMap geoMap;                // Gicentre GeoMap object for rendering EU map.
WebMercator proj;             // Web Mercator projection object
PVector tlCorner, brCorner;   // Map corners in WebMercator coordinates.

String[][] fileData;
int numRows;

ArrayList<City> cityData = new ArrayList<City>();
ArrayList<Temp> tempData = new ArrayList<Temp>();
ArrayList<Army> armyData = new ArrayList<Army>();

// Origin of Map shapefile to be rendered (Changed from 0,0 to allow scalaing)
float mapOriginX = -4000.0f;
float mapOriginY = -7000.0f;

// Geo Map boundaries
float mapLeft = -31.265747f;
float mapRight = 69.07032f;
float mapTop = 81.857368f;
float mapBot = 32.397476f;

// Global variables to store temp info of a segment
float prevX, prevY;
int prevStroke, strokeColour = #E35239;

// Variables used for animating the plot
int term = 0;
boolean renderOnce = false;

public void setup() {
  fullScreen();     // Load the viz. in fullscreen mode (Tested on 1080p device)
  smooth(1);        // anti-aliasing
  loadData("minard-data.csv");  // Load data into corresponding ArrayList
  initMap();        // Initialize GeoMap from the given shapefile using the projection specified.
  delay(200);
}

public void draw() {
  delay(100);
  if (!renderOnce) {              // This section of code is rendered once before setting the flag.
    background(202, 226, 245);    // Ocean colour
    fill(#d2ebae);                // Land colour
    stroke(0, 30);                // Boundary colour
    geoMap.draw();

    fill(0);
    stroke(0);
    textSize(10);

    // Code to draw graph for plotting the temperature duing retreat
    // Y axis is divided into 4 sections with temp range from 0 degree to -30 degrees.
    for (int i = 0; i<4; i++) 
    { 
      float y = height - 400 + (i * 30);
      strokeWeight(0.5);
      line(300, y, width - 300, y);
      textAlign(RIGHT);
      strokeWeight(2);
      text(0f - i * 10 + "\u00B0" + "C", width - 250, y);
    }

    // Loop to plot temperature against longitude in the retreat path
    for (Temp tmp : tempData) {
      float lont = tmp.getLont();
      float temp = tmp.getTemp();
      int days = tmp.getDays();
      String month = tmp.getMonth();
      String day = tmp.getDay();
      PVector scrCoord = geoToScreen(proj.transformCoords(new PVector(lont, (mapTop+mapBot)/2)));
      float y = height - 400 - temp * 3;
      placeMarker(scrCoord.x, y, #8aa9ff, map(days, 1, 10, 10, 20)); // The size of the marker is scaled based on the number of days.
      fill(0);
      stroke(0);
      strokeWeight(2);
      textSize(12);
      textAlign(CENTER);
      text(month + " " + day + ": " + temp + "\u00B0", scrCoord.x + 20, y + 25);
      if (tempData.indexOf(tmp) != 0) {
        fill(0);
        stroke(0);
        strokeWeight(2);
        line(prevX, prevY, scrCoord.x, y);
      }
      prevX = scrCoord.x;
      prevY = y;
    }
  }

  // Iterate over the armyData collection and plot segments of path in the attact nad retreat direction 
  // For the three divison of army. 
  // Only one segmet is additively plotted per run (term) for the animation effect.
  // Once the term equals to the last index of the collection, the entire path is plotted for several terms giving a stationary view.
  for (Army ar : armyData) {
    float lonp = ar.getLonp();
    float latp = ar.getLatp();
    int surv = ar.getSurv();
    String dir = ar.getDir();
    int div = ar.getDiv();
    PVector scrCoord = geoToScreen(proj.transformCoords(new PVector(lonp, latp)));
    float strokeWeight = map(surv, 4000, 340000, 2, 40); // The thickness of the path segmet is mapped to the number of survivers in that division.
    strokeWeight(strokeWeight);
    int index = armyData.indexOf(ar);

    if (term >= index) {
      if (index != 0 && div == 1) {
        strokeColour = dir.equals("A") ? #E35239 : #AD9C99;
        stroke(prevStroke);
        line(prevX, prevY, scrCoord.x, scrCoord.y);
      }
      if (index != 35 && div == 2) {
        strokeColour = dir.equals("A") ? #E35239 : #AD9C99;
        stroke(prevStroke);
        line(prevX, prevY, scrCoord.x, scrCoord.y);
      }
      if (index != 45 && div == 3) {
        strokeColour = dir.equals("A") ? #E35239 : #AD9C99;
        stroke(prevStroke);
        line(prevX, prevY, scrCoord.x, scrCoord.y);
      }
      fill(#d2ebae);
      noStroke();
      strokeWeight(0);
      rect(300, height/2 -15, 150,70);
      rect(300, height/2 + 30 -15, 150,70);
      fill(0);
      stroke(0);
      text("Lat: " + latp, 400, height/2);
      text("Lon: " + lonp, 400, height/2 + 30);
      strokeWeight(strokeWeight);
    }
    if (index == 0 || index == 35 || index == 45 || index == 50) {
      if (index == 50)
        div = 4;
      if (!renderOnce) { // Used to display legend
        stroke(0);
        textAlign(RIGHT);
        text(surv, width -300, height/2 - 100 - div * 50 + 5);
        line(width -410, height/2 - 100 - div * 50, width -380, height/2 -100 - div * 50);
      }
      prevStroke = #E35239;
    } else {
      prevStroke = strokeColour;
    }
    prevX = scrCoord.x;
    prevY = scrCoord.y;
  }

  // Loop to mark the city points on to the underlying map.
  // geoToScreen method is usd to translate the geo coordinated to screen (raster coordinates)
  for (City ct : cityData) {
    float lonc = ct.getLonc();
    float latc = ct.getLatc();
    String city = ct.getCity();
    PVector scrCoord = geoToScreen(proj.transformCoords(new PVector(lonc, latc)));
    placeMarker(scrCoord.x, scrCoord.y, 0, 5);
    textSize(15);
    strokeWeight(1);
    textAlign(CENTER);
    text(city, scrCoord.x-20, scrCoord.y+20);
  }
  if (!renderOnce) {// Legend and other texts
    fill(0);
    stroke(0);
    strokeWeight(2);
    textSize(15);
    textAlign(CENTER);
    pushMatrix();
    translate(width/2, height/2);
    rotate(HALF_PI);
    text("Temperature", 180, -730);
    popMatrix();
    text("Longitude", width/2, height - 400 + 4 * 30);
    textAlign(CENTER);
    text("ARMY SIZE", width -350, height/2 - 100 - 4 * 50 - 20);
    text("DIRECTION", width -350, height/2 - 30);

    text("Temperature at various places during retreat", width/2, height - 420);
    textAlign(RIGHT);
    textSize(12);
    text("The size of the circle encodes the number of days the army survived in that temperature.", width - 300, height - 280);

    strokeWeight(5);
    textSize(25);
    textAlign(CENTER);
    text("MINARD'S DEPICTION OF NAPOLEON'S 1812 CAMPAIGN TO MOSCOW", width/2, 80);

    textSize(12);
    textAlign(RIGHT);
    strokeWeight(5);
    text("ATTACK", width -300, height/2);
    fill(#E35239);
    stroke(#E35239);
    rect(width -400, height/2 -10, 20, 10);
    fill(0);
    stroke(0);
    text("RETREAT", width -300, height/2 + 30);
    fill(#AD9C99);
    stroke(#AD9C99);
    rect(width -400, height/2 +20, 20, 10);
  }
  renderOnce = true;
  term ++;

  if (term > 81) {
    term = 0;
    renderOnce = false;
  }
  saveFrame("Demo.jpg");
  //}
}

public void loadData(String fileName) {
  String[] file = loadStrings(fileName); 
  numRows = file.length;  
  fileData = new String[numRows][];
  for (int i = 0; i < file.length; i++) {
    if (trim(file[i]).length() == 0 | i == 0) {
      continue;
    }
    fileData[i] = split(file[i], ",");
    if (fileData[i][0]!= null && !fileData[i][0].isEmpty())
      cityData.add(new City(fileData[i][0], fileData[i][1], fileData[i][2]));
    if (fileData[i][3]!= null && !fileData[i][3].isEmpty())
      tempData.add(new Temp(fileData[i][3], fileData[i][4], fileData[i][5], fileData[i][6], fileData[i][7]));
    if (fileData[i][8]!= null && !fileData[i][8].isEmpty())
      armyData.add(new Army(fileData[i][8], fileData[i][9], fileData[i][10], fileData[i][11], fileData[i][12]));
  }
}

public void initMap() {
  geoMap = new GeoMap(mapOriginX, mapOriginY, width+6000, height+9000, this);  // Create the geoMap object.
  geoMap.readFile("Europe");  // Read shapefile.
  proj = new WebMercator();
  tlCorner = proj.transformCoords(new PVector(mapLeft, mapTop));
  brCorner = proj.transformCoords(new PVector(mapRight, mapBot));
}

public PVector geoToScreen(PVector geo)
{
  return new PVector(map(geo.x, tlCorner.x, brCorner.x, mapOriginX, width+2000), 
    map(geo.y, tlCorner.y, brCorner.y, mapOriginY, height+2000));
}

public void placeMarker(float x, float y, int colour, float size) {
  fill(colour);
  stroke(0);
  ellipse(x, y, size, size);
}
