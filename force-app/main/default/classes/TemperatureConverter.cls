public class TemperatureConverter {
    // Takes a Fahrenheit temperature and returns the Celsius equivalent.
    public static Decimal fahrenheitToCelsius(Decimal fh) {
        Decimal cs = (fh - 32) * 5 / 9;
        return cs.setScale(2);
    }
    
    // Method 2: Celsius to Fahrenheit 
    public static Decimal celsiusToFahrenheit(Decimal cs) {
        Decimal fh = (cs * 9 / 5) + 32;
        return fh.setScale(2);
    }
}