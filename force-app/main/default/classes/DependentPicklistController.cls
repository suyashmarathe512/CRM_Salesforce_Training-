/***************************************************************************************************
* @Author:        CRM Developer
* @className:     DependentPicklistController
* @Description:   This class is to retrieve countries and their dependent cities from custom settings
                    for a dependent picklist in Lightning Component.
***************************************************************************************************/
public with sharing class DependentPicklistController {
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     getCountries
* @Description:   This method returns a list of countries from custom settings.
***************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Country__c> getCountries() {
        try {
            return [SELECT 
                        Name 
                    FROM 
                        Country__c 
                    ORDER BY 
                        Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     getCities
* @param:         countryName - Name of the country to filter cities
* @Description:   This method returns a list of cities from custom settings.
***************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<City__c> getCities(String countryName) {
        try {
            return [SELECT 
                        Name 
                    FROM 
                        City__c 
                    WHERE 
                        Country__c = :countryName 
                    ORDER BY 
                        Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}