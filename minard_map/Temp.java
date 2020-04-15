public class Temp {
  private float lont = 0.0f;
  private float temp = 0.0f;
  private int days = 0;
  private String month = "";
  private String day = "";
  
  public Temp(String longitude, String latitude, String days, String month, String day) {
    this.lont = Float.parseFloat(longitude);
    this.temp = Float.parseFloat(latitude);
    this.days = Integer.parseInt(days);
    this.month = month;
    this.day = day;
    }
    
  public float getLont() {
        return lont;
    }
  public float getTemp() {
        return temp;
    }
  public int getDays() {
        return days;
    }
  public String getMonth() {
        return month;
    }
  public String getDay() {
        return day;
    }
}
