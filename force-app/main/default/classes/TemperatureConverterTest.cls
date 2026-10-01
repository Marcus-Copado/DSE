@isTest
private class TemperatureConverterTest {
    
    @isTest
    static void testFahrenheitToCelsius() {
        Test.startTest();
        Decimal result = TemperatureConverter.fahrenheitToCelsius(70);
        Test.stopTest();
        Assert.areEqual(21.11, result);
    }
    
    @isTest
    static void testCelsiusToFahrenheit() {
        Test.startTest();
        Decimal result = TemperatureConverter.celsiusToFahrenheit(20);
        Test.stopTest();
        Assert.areEqual(68.00, result);
    }
}
