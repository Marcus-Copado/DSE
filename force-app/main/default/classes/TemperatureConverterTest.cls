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
    static void testFreezingPoint() {
        Test.startTest();
        Decimal celsius = TemperatureConverter.fahrenheitToCelsius(32);
        Test.stopTest();
        
        Assert.areEqual(0, celsius, '32 Fahrenheit should be exactly 0 Celsius.');
    }
    
    @isTest
    static void testBoilingPoint() {
        Test.startTest();
        Decimal celsius = TemperatureConverter.fahrenheitToCelsius(212);
        Test.stopTest();
        
        // Alternative syntax using older System.assertEquals structure
        System.assertEquals(100, celsius, '212 Fahrenheit should be exactly 100 Celsius.');
    }
}