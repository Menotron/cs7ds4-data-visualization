public class City {
  private float lonc = 0.0f;
  private float latc = 0.0f;
  private String city = "";
  
  public City(String longitude, String latitude, String cityName) {
    this.lonc = Float.parseFloat(longitude);
    this.latc = Float.parseFloat(latitude);
    this.city = cityName;
    }
  public float getLonc() {
        return lonc;
    }
  public float getLatc() {
        return latc;
    }
  public String getCity() {
        return city;
    }
}
