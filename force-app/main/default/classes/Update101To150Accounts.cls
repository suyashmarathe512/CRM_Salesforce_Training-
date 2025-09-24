/***************************************************************************************************
* @Author:        CRM Developer
* @className:     Update101To150Accounts
* @Description:   This class implements queueable job that updates the 101-150 accounts' name.
***************************************************************************************************/
public with sharing class Update101To150Accounts implements Queueable {
    public void execute(QueueableContext context) {
        List<Account> accountsToUpdate = [SELECT 
                                                Id, Name 
                                            FROM 
                                                Account 
                                            WHERE 
                                                IsPersonAccount = false 
                                            LIMIT 
                                                50 
                                            OFFSET 
                                                100];
        if (!accountsToUpdate.isEmpty()) {
            for (Account acc : accountsToUpdate) {
                acc.Name = 'CTI - ' + acc.Name;
            }
            update accountsToUpdate;
        }
    }
}
