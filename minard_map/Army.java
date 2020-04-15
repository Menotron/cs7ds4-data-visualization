public class Army {
  private float lonp = 0.0f;
  private float latp = 0.0f;
  private int surv = 0;
  private String dir = "";
  private int div = 0;
  
  public Army(String longitude, String latitude, String survivors, String direction, String division) {
    this.lonp = Float.parseFloat(longitude);
    this.latp = Float.parseFloat(latitude);
    this.surv = Integer.parseInt(survivors);
    this.dir = direction;
    this.div = Integer.parseInt(division);
    }
  public float getLonp() {
        return lonp;
    }
  public float getLatp() {
        return latp;
    }
  public int getSurv() {
        return surv;
    }
  public String getDir() {
        return dir;
    }
  public int getDiv() {
        return div;
    }
}
