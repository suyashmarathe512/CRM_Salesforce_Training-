public with sharing class AccountTriggerHandler {
    public static Boolean HasRun = false;
    public static void cloneRecord(List<Account> newAccounts) {
        if(HasRun) {
            return;
                   }
       	HasRun = true;
        List<Account> clonedAccounts = new List<Account>();
        for(Account acc : newAccounts) {
            Account clonedAcc = acc.clone();
            clonedAcc.Name = acc.Name + ' - Clone';
            clonedAccounts.add(clonedAcc);
        }
        Database.SaveResult[] results = Database.insert(clonedAccounts, false);
    }
}