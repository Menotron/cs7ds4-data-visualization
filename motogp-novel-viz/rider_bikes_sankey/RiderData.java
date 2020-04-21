import java.util.HashMap;

class RiderData {

  String name;
  HashMap<String, Integer> values; 
  HashMap<String, String> colour;

  int total = 0;

  RiderData(String name_, 
    HashMap<String, Integer> values_, HashMap<String, String> colour_) {

    name = name_;
    values = values_;
    colour = colour_;
  }
}
