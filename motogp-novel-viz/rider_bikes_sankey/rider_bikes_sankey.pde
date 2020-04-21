import java.util.Map;
import java.util.ArrayList;
import java.util.stream.Collectors;
import java.util.List;
import java.util.HashMap;
import processing.pdf.*;


Table rider_bikes;
PFont f1; 
ArrayList<String> riders = new ArrayList<String>();
ArrayList<String> prevPrint = new ArrayList<String>();
ArrayList<RiderData> riderData = new ArrayList<RiderData>();

void setup() {

  size(1200, 3000, PDF, "output.pdf");
  smooth();

  f1 = createFont("ARIAL", 100, true);
  textFont(f1);

  rider_bikes = loadTable("rider_bikes.csv", "header");
  for (TableRow row : rider_bikes.rows()) {
    riders.add(row.getString("Rider"));
  }
  List distinct_riders = riders.stream().distinct().collect(Collectors.toList());

  for (Object rider : distinct_riders) {
    HashMap<String, Integer> bike_point_map = new HashMap<String, Integer>();
    HashMap<String, String> bike_color_map = new HashMap<String, String>();

    for (TableRow row : rider_bikes.rows()) {
      if (row.getString("Rider").equals(rider.toString())) {
        bike_point_map.put(row.getString("Bike"), row.getInt("Points"));
        bike_color_map.put(row.getString("Bike"), row.getString("BkClr"));
      }
    }

    riderData.add(new RiderData(rider.toString(), bike_point_map, bike_color_map));
  }
}

void draw() {
  background(#FFFFFF);
  noFill();

  translate(0, 50);
  int totalValues = 0; 
  HashMap<String, Integer> DEST = new HashMap<String, Integer>(); 
  for (RiderData ORIGIN : riderData) { 
    ORIGIN.total = 0; 
    for (Map.Entry SET : ORIGIN.values.entrySet()) { 
      String dest = (String)SET.getKey(); 
      int num = (Integer)SET.getValue(); 
      if (DEST.containsKey(dest)) 
        DEST.put(dest, DEST.get(dest)+num); 
      else DEST.put(dest, num); 
      ORIGIN.total += num; 
      totalValues += num;
    }
  }

  float accum = 0; 
  HashMap<String, Float> posYd = new HashMap<String, Float>(); 
  for (Map.Entry SET : DEST.entrySet()) { 
    String dest = (String)SET.getKey(); 
    float H = map((Integer)SET.getValue(), 0, totalValues, 0, height); 
    posYd.put(dest, accum); 
    accum += H;
  }

  float posYo = 0; 
  for (RiderData ORIGIN : riderData) { 
    for (Map.Entry SET : ORIGIN.values.entrySet()) { 
      String dest = (String)SET.getKey();
      float H = map((Integer)SET.getValue(), 0, totalValues, 0, height);

      String hex_colour = ORIGIN.colour.get(dest);
      int c = Integer.parseInt(hex_colour, 16);
      c = color(red(c), green(c), blue(c));

      stroke(c, 150); 
      strokeWeight(H); 
      bezier(150, posYo+H/2, width/2, posYo+H/2, width/2, posYd.get(dest)+H/2, width, posYd.get(dest)+H/2); 
      noFill();    
      posYo += H; 
      posYd.put(dest, posYd.get(dest)+H/2);
    }
  }
  posYo = 0;
  stroke(0);
  strokeWeight(2);
  fill(0);
  rect(0, -50, 180, height);
  fill(0);
  textSize(20);
  strokeWeight(10);
  textAlign(CENTER);
  text("BEZIER CHART RELATING RIDER SUCCESS WITH CONSTRUCTORS", width/2, -10);
  textSize(15);
  textAlign(RIGHT);
  text("CONSTRUCTOR", width -10, -10);
  fill(255);
  stroke(255);
  textAlign(LEFT);
  text("RIDER", 10, -10);

  int i = 1;
  for (RiderData ORIGIN : riderData) { 
    for (Map.Entry SET : ORIGIN.values.entrySet()) { 
      String dest = (String)SET.getKey();
      float H = map((Integer)SET.getValue(), 0, totalValues, 0, height);

      String hex_colour = ORIGIN.colour.get(dest);
      int c = Integer.parseInt(hex_colour, 16);
      c = color(red(c), green(c), blue(c));

      textSize(15);
      if (!prevPrint.contains(dest)) {
        fill(0);
        stroke(0);
        textAlign(RIGHT);
        text(dest, width -10, posYd.get(dest)+H/2);
        fill(0, 150);
        stroke(0);
        float sw = map(i, 1, 95, 17, 420);
        strokeWeight(sw/3);
        line(width/2  - 45 + 10*i, height - 70, width/2 - 45 + 10*i + 30, height - 70);
        i++;
      }
      if (!prevPrint.contains(ORIGIN.name)) {
        fill(255);
        stroke(255);
        textAlign(LEFT);
        text(ORIGIN.name, 10, posYo+H/3 + 30);
        strokeWeight(2);
        stroke(255);
        line(0, posYo+H/3 - 5, 180, posYo+H/3 - 5);
      }
      prevPrint.add(dest);
      prevPrint.add(ORIGIN.name);
      fill(c, 150);
      stroke(c, 150);
      strokeWeight(10);
      line(150, posYo+H/2, 160, posYo+H/2);
      noFill();    
      posYo += H; 
      posYd.put(dest, posYd.get(dest)+H/2);
    }
  }
  fill(0);
  stroke(0);
  textAlign(LEFT);
  text("Points Legend ", width/2 - 180, height - 65);
  text("17", width/2 - 60, height - 65);
  text("420", width/2 + 210, height - 65);
  exit();
}
