public with sharing class updateAccountDescriptionsAsync {
    @future
    public static void updateAccountDescriptions() {
        List<Account> accountsToUpdate = [SELECT Id, Description FROM Account];
        for (Account acc : accountsToUpdate) {
            if(acc.Description == null || acc.Description == ''){
                acc.Description = 'Account Description';
            }
        }
        update accountsToUpdate;
    }
}
//updateAccountDescriptionsAsync.updateAccountDescriptions();