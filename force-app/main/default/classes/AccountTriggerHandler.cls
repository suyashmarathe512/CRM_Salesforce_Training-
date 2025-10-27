public class AccountTriggerHandler {

    // This method uses the Custom Setting
    public static void populateCapitalFromSetting(List<Account> newAccounts) {

        // Get ALL records from the custom setting. 
        // This is very efficient and uses Salesforce's cache.
        // It returns a Map where the Key is the 'Name' field (e.g., "India")
        Map<String, Country_vs_Capital__c> capitalMap = Country_vs_Capital__c.getAll();

        // Loop through every Account the trigger is about to save
        for (Account acc : newAccounts) {

            // Check if a Country was selected AND if that country exists in our map
            if (acc.Country__c != null && capitalMap.containsKey(acc.Country__c)) {

                // If it exists, get the setting record and assign its capital
                Country_vs_Capital__c setting = capitalMap.get(acc.Country__c);
                acc.Capital__c = setting.Capital__c;
            }
        }
    }
    public static void populateCapitalFromMetadata(List<Account> newAccounts) {
        Set<String> countryNames = new Set<String>();
        for(Account acc : newAccounts) {
            if(acc.Country__c != null) {
                countryNames.add(acc.Country__c);
            }
        }

        if(countryNames.isEmpty()) {
            return; // No countries to process
        }

        // 2. Query the Custom Metadata Type for matching records
        // Note: We query by DeveloperName (the 'API Name' of the record)
        Map<String, Country_vs_Capital__mdt> capitalMap = new Map<String, Country_vs_Capital__mdt>();
        for(Country_vs_Capital__mdt mdt : [SELECT DeveloperName, Capital__c 
                                        FROM Country_vs_Capital__mdt 
                                        WHERE DeveloperName IN :countryNames]) {
            capitalMap.put(mdt.DeveloperName, mdt);
        }

        // 3. Loop through the accounts and populate the capital
        for (Account acc : newAccounts) {
            if (acc.Country__c != null && capitalMap.containsKey(acc.Country__c)) {

                // Get the metadata record and assign its capital
                acc.Capital__c = capitalMap.get(acc.Country__c).Capital__c;
            }
        }
    }
}
/*
custom setting usage examples:
Map<String, Country_vs_Capital__c> allSettingsMap = Country_vs_Capital__c.getAll();
Country_vs_Capital__c indiaSetting = allSettingsMap.get('India');
System.debug('Capital of India: ' + indiaSetting.Capital__c);
Country_vs_Capital__c usaSetting = Country_vs_Capital__c.getInstance('USA');
System.debug('Capital of USA: ' + usaSetting.Capital__c);
List<Country_vs_Capital__c> settingsList = [SELECT Name, Capital__c 
                                           FROM Country_vs_Capital__c 
                                           WHERE Name = 'France'];
System.debug('Capital of France: ' + settingsList[0].Capital__c);


Custom Metadata Type usage examples:
List<Country_vs_Capital__mdt> allMetadata = [SELECT Label, DeveloperName, Capital__c 
                                            FROM Country_vs_Capital__mdt];
for(Country_vs_Capital__mdt mdt : allMetadata) {
    System.debug('MDT Record: ' + mdt.Label + ' -> ' + mdt.Capital__c);
}
*/