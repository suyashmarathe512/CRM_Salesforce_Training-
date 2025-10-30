/***************************************************************************************************
* @Author:        CRM Developer
* @className:     AccountTriggerHandler
* @Description:   This class handles the logic for populating the Capital__c field on Account records
*                 based on the Country__c field using both Custom Settings and Custom Metadata Types.
***************************************************************************************************/
public class AccountTriggerHandler{
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     populateCapitalFromSetting
* @param:         List<Account> newAccounts
* @Description:   This method populates the Capital__c field on Account records using Custom Settings.
***************************************************************************************************/
    public static void populateCapitalFromSetting(List<Account> newAccounts){
        Map<String, Country_vs_Capital__c> capitalMap = Country_vs_Capital__c.getAll();
        for (Account acc : newAccounts) {
            if (acc.Country__c != null && capitalMap.containsKey(acc.Country__c)){
                Country_vs_Capital__c setting = capitalMap.get(acc.Country__c);
                acc.Capital__c = setting.Capital__c;
            }
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     populateCapitalFromMDT
* @param:         List<Account> newAccounts
* @Description:   This method populates the Capital__c field on Account records using Custom Metadata Types.
***************************************************************************************************/
    public static void populateCapitalFromMDT(List<Account> newAccounts){
        Set<String> countryNames = new Set<String>();
        for(Account acc : newAccounts) {
            if(acc.Country__c != null) {
                countryNames.add(acc.Country__c);
            }
        }
        Map<String, Country_vs_Capital_metadata__mdt> capitalMap = new Map<String, Country_vs_Capital_metadata__mdt>();
        for(Country_vs_Capital_metadata__mdt mdt : [SELECT
                                                        DeveloperName, Capital__c
                                                    FROM
                                                        Country_vs_Capital_metadata__mdt
                                                    WHERE
                                                        DeveloperName
                                                    IN
                                                        :countryNames]){
            capitalMap.put(mdt.DeveloperName, mdt);
        }
        for (Account acc : newAccounts){
            if (acc.Country__c != null && capitalMap.containsKey(acc.Country__c)){
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
List<Country_vs_Capital__c> settingsList = [SELECT 
                                                Name, Capital__c 
                                           FROM 
                                                Country_vs_Capital__c 
                                           WHERE 
                                                Name = 'France'];
System.debug('Capital of France: ' + settingsList[0].Capital__c);


Custom Metadata Type usage examples:
List<Country_vs_Capital_metadata__mdt> allMetadata = [SELECT 
                                                Label, DeveloperName, Capital__c 
                                            FROM 
                                                Country_vs_Capital_metadata__mdt];
for(Country_vs_Capital_metadata__mdt mdt : allMetadata) {
    System.debug('MDT Record: ' + mdt.Label + ':' + mdt.Capital__c);
}
*/