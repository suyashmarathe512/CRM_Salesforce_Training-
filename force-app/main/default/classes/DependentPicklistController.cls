public with sharing class DependentPicklistController {
    @AuraEnabled(cacheable=true)
    public static List<Country__c> getCountries() {
        try {
            // Query the custom setting and order by name
            return [SELECT Name FROM Country__c ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Fetches all cities that match the selected country.
     */
    @AuraEnabled(cacheable=true)
    public static List<City__c> getCities(String countryName) {
        try {
            // Query the City__c custom setting using the Country__c text field
            return [SELECT Name FROM City__c 
                    WHERE Country__c = :countryName 
                    ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}