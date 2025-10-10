public with sharing class GetAccounts {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAllAccounts() {
        return [SELECT Id, Name, Type, Phone, Website, Industry, Rating, AnnualRevenue, OwnerId FROM Account ORDER BY CreatedDate DESC LIMIT 50];
    }
}