PImage map;
Table data;

void setup() {
  size(1000,1000);
  map = loadImage("Snow-Cholera-Map-Clean.jpg");
  data = loadTable("snow_pixelcoords.csv","header");
}

void draw() {
  image(map,0,0,1000,1000);
  fill(255,0,0);
  for(TableRow row:data.rows()) {
    int size_scale = row.getInt("count") >= 0 ? 2 * row.getInt("count") : 0;
    
    ellipse(row.getFloat("x_screen"),row.getFloat("y_screen"),size_scale,size_scale);
  }
}
