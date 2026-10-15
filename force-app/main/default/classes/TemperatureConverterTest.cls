@isTest
private class TemperatureConverterTest {
    
    @isTest
    static void testWarmTemp() {
        // 1. Prepare test data
        Decimal fahrenheit = 70;
        
        // 2. Call the method to test
        Test.startTest();
        Decimal celsius = TemperatureConverter.fahrenheitToCelsius(fahrenheit);
        Test.stopTest();
        
        // 3. Verify the results match expectations
        Assert.areEqual(21.11, celsius, 'The temperature conversion did not match the expected Celsius value.');
    }
    
    @isTest
    static void testCelsiusToFahrenheit() {
        Test.startTest();
        Decimal result = TemperatureConverter.celsiusToFahrenheit(20);
        Test.stopTest();
        Assert.areEqual(68.00, result);
    }
}