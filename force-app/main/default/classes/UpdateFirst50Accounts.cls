/***************************************************************************************************
* @Author:        CRM Developer
* @className:     UpdateFirst50Accounts
* @Description:   This class implements queueable job that updates the first 50 accounts' name.
***************************************************************************************************/
public with sharing class UpdateFirst50Accounts implements Queueable {
    public void execute(QueueableContext context) {
        List<Account> accountsToUpdate = [SELECT 
                                                Id, Name 
                                            FROM 
                                                Account 
                                            WHERE 
                                                IsPersonAccount = false
                                            AND 
                                                Name LIKE 'JOB%'
                                            LIMIT  
                                                50];
        if (!accountsToUpdate.isEmpty()) {
            for (Account acc : accountsToUpdate) {
                acc.Name = 'CTI - ' + acc.Name;
            }
            update accountsToUpdate;
        }
    }
}
