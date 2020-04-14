import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

String[][] fileData;
int numRows;
int yearOffset = 12;                // Set to 0 for Apr 1854 - Mar 1855 and 12 for Apr 1855 - Mar 1856
float[] blueWedge = new float[24];  // Array to store data points for deaths due to Zymotic diseases
float[] redWedge = new float[24];   // Array to store data points for deaths due to Wounds & injuries
float[] blackWedge = new float[24]; // Array to store data points for deaths due to other causes
String[] labels = new String[24];   // Array to store month-year data for each sector
int numSectors = 12;                // Each sector represents a month of year
int scale = 10 + yearOffset ;       // Multiplier used to zoom 
float initialAngle = 180;           // The polar chart starts at PI radians / 180 degree 
boolean isMax = false;              // Chart label is printed beside the largest wedge, flag set when drawing the wedge with max radius.
boolean legendSet = false;          // Flag set when the legend is rendered once.
float mouseAngle;
float sliderWidth = 50;
float sliderHeight = 20;
float sliderPosX = 775;
float sliderPosY  = 900;
boolean sliderOver = false;
boolean sliderLocked = false;
float sliderOffset;
int sliderVal = 12;

public void setup() {
  size(1000, 1000);                 // Create a canvas of 800 * 800 pixel
  noStroke();
  loadData();
  // noLoop();
}

public void draw() {
  background(255);                  // Set background colour to white
  fill(0);
  stroke(0);
  textAlign(LEFT);
  text("Instructions:\nScroll/pinch to Zoom.\nClick and drag to rotate.\nMove the slider to hide/show wedge",100,sliderPosY-80);
  float lastAngle = initialAngle; 
  float theta = 360 / numSectors;   // The increment angle (angle of each sector = 30 degrees)

  /** 
   *  Get angle of mouse wrt center of canvas
   *  @link https://forum.processing.org/two/discussion/13609/hover-over-pie-chart-segment-and-show-the-array-value-associated
   *  @link https://processing.org/reference/atan2_.html
   */
  mouseAngle = degrees(atan2(mouseY-((height+100)/2), mouseX-(width/2))); 
  if (mouseAngle < 0) {
    mouseAngle = mouseAngle + 360;
  }

  for (int i=yearOffset; i<sliderVal; i++) {
    if ( mouseAngle >= lastAngle && mouseAngle < lastAngle+theta ) { // Can use this to detect mouse hover and display relavent data. *note: not used
      fill(0);
      textAlign(LEFT);
      // Print Annual rate of mortality per 1000 on hover
      text("Year: " + labels[i], 100, 100);
      text("Deaths due to Zymotic diseases: " + blueWedge[i], 100, 115);
      text("Deaths due to Wounds & injuries: " + redWedge[i], 100, 130);
      text("Deaths due to All other causes: " + blackWedge[i], 100, 145);
    }

    /**
     * Code to draw individual slice/ wedge of for each cause.
     * The sector with the biggest radius is drawn first and then overlayed by subsequent sectors.
     */
    float[] data = {blueWedge[i], redWedge[i], blackWedge[i]};
    Arrays.sort(data);
    for (int j=2; j>=0; j--) {
      if (data[j] == blueWedge[i]) {
        setColourAndLegend("Zymotic diseases", 0, 57, 191, 212);
        stroke(57, 68, 212);
      } else if (data[j] == redWedge[i]) {
        setColourAndLegend("Wounds & injuries", 1, 252, 169, 162);
        stroke(255, 0, 0);
      } else {
        setColourAndLegend("All other causes", 2, 148, 148, 148);
        stroke(0);
      }
      if (j==2) {
        isMax=true; // used to flag when to print the sector label
      } else isMax=false;
      drawSector(width/2, (height+100)/2, theta, data[j], lastAngle, i);
    }
    legendSet = true;
    lastAngle += theta;
    if (lastAngle == 360) {
      lastAngle = 0;
    }
  }
  legendSet = false;

  /**
   * Code to handle slider position and draw part of the coxcomb based on its poition
   * @link https://www.openprocessing.org/sketch/103317/
   */
  rectMode(CENTER);
  stroke(0);
  line (200, sliderPosY, width - 200, sliderPosY);
  if (dist(mouseX, mouseY, sliderPosX, sliderPosY) < sliderHeight) {
    fill(200);
    sliderOver = true;
  } else {
    fill(255);
    sliderOver = false;
  }

  if (sliderPosX < 225)
    sliderPosX = 225;

  if (sliderPosX > 775)
    sliderPosX = 775;

  rect(sliderPosX, sliderPosY, sliderWidth, sliderHeight);                    // Draw the slider
  sliderVal = (int) map(sliderPosX, 225, 775, 1, numSectors) + yearOffset;    // Map slider position to the integer range from 0 to number of sectors.
  saveFrame("Demo.png");
}

/**
 * Method to draw one sector based on the data mapped to the sector area.
 * @param xcord : X coordinate of the coxcomb (Here width/2 is used)
 * @param ycord : Y coordinate of the coxcomb (Here height/2 is used)
 * @param theta : angle of one sector
 * @param sectorArea : Area of one wedge, used to determine the radius of sector.
 * @param startAngle : The start offset used as reference in case if the chart is rotated. (default is PI radians)
 * @param i : Sector number to inde the labels array.
 */
public void drawSector(float xcord, float ycord, float theta, float sectorArea, float startAngle, int i) {
  float  sectorRadius = sqrt((sectorArea * numSectors)/PI)*scale;
  arc(xcord, ycord, sectorRadius, sectorRadius, radians(startAngle), radians(startAngle+theta)); // https://processing.org/reference/arc_.html
  if (isMax) {
    float textRadius = sectorRadius;
    if (textRadius < width/3)
      textRadius = width/3;
    float x1=xcord - textRadius * scale/38 * sin(-(radians(startAngle + theta/2)) - PI/2); 
    float y1=ycord  - textRadius * scale/38 * cos(-(radians(startAngle + theta/2)) - PI/2);
    textAlign(CENTER); 
    fill(0); 
    stroke(0);
    text(labels[i], x1, y1);
  }
}

/* @link:https://processing.org/reference/mouseWheel_.html
 * Method used to zoom the coxcomb by changing the scale factor by the mouse scroll wheel events.
 */
public void mouseWheel(MouseEvent event) {
  scale = scale - PApplet.parseInt(event.getCount());
}

public void mousePressed() {
  if (sliderOver) {
    sliderLocked = true;
    sliderOffset = mouseX-sliderPosX;
  }
}

/* @link:https://processing.org/reference/mouseDragged_.html
 * Method used to register change in the year slider when the sliderLocked is set by clicking on the slider.
 * And rotate the chart by altering the initial angle (180 degrees) by the distance coverd by dragging the mouse in y direction anywhere in the canvas.
 */
public void mouseDragged() {
  if (sliderLocked) {
    sliderPosX = mouseX-sliderVal;
  } else {
    initialAngle = initialAngle - (mouseY - pmouseY)*(0.2f);
    if (initialAngle == 360) {
      initialAngle = 0;
    }
  }
}

/* @link:https://processing.org/reference/mouseReleased.html
 * Method release lock on the slider.
 */
public void mouseReleased() {
  if (sliderLocked) 
    sliderLocked = false;
}


/* 
 * Method used to set legend and instructions.
 */
public void setColourAndLegend(String text, int pos, int r, int g, int b) {
  // show rects with text and display instructions below slider
  if (!legendSet) {
    fill(0);
    stroke(0);
    textAlign(CENTER);
    text("DIAGRAM OF THE CAUSES OF MORTALITY", width/2, 60);
    text("IN THE ARMY IN THE EAST", width/2, 75);
    text(labels[0], 150, sliderPosY + (sliderHeight/4));
    text(labels[numSectors -1], 850, sliderPosY + (sliderHeight/4));
    textAlign(LEFT);
    text(text, 800, 105 + 30*pos);
    fill(r, g, b);
    rect(780, 100 + 30*pos, 20, 20);
  }
  fill(r, g, b);
  
}

public void loadData() {
String[] file = loadStrings("nightingale-data.csv"); 
numRows = file.length;  
fileData = new String[numRows][];
for (int i = 0; i < file.length; i++) {
  if (trim(file[i]).length() == 0 | i == 0) {
    continue;
  }   
  fileData[i] = split(file[i], ",");
  labels[i - 1] = fileData[i][0];
  blueWedge[i - 1] = Float.parseFloat(fileData[i][1]);
  redWedge[i - 1] = Float.parseFloat(fileData[i][2]);
  blackWedge[i - 1] = Float.parseFloat(fileData[i][3]);
}       
}

/* Reference
 * https://www.mathopenref.com/arcsectorarea.html
 * https://understandinguncertainty.org/node/214 
 * https://processing.org/reference/text_.html
 */
