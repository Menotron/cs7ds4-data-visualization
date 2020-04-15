void setup() {
  size(1000, 911);
  PImage map = loadImage("Snow-Cholera-Map-Clean.jpg");
  image(map, 0, 0);
}

void draw() {
  Table data = loadTable("snow_pixelcoords.csv", "header");

  for (TableRow row : data.rows()) {
    int size_scale = row.getInt("count") >= 0 ? 2 * row.getInt("count") : 0;
    if (row.getInt("count") == -999) { 
      fill(0, 0, 255);
      rect(row.getFloat("x_screen"), row.getFloat("y_screen"), 10, 10);
    } else {
      fill(255, 0, 0);
      ellipse(row.getFloat("x_screen"), row.getFloat("y_screen"), size_scale, size_scale);
    }
  }
  saveFrame("Output.png");
  noLoop();
}
