/***************************************************************************************************
* @Author:        CRM Developer
* @className:     Update101To150Accounts
* @Description:   This class implements queueable job that updates the 101-150 accounts' name.
***************************************************************************************************/
public with sharing class Update101To150Accounts implements Queueable {
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     execute
* @Description:   This class implements queueable job that updates the 101-150 accounts' name.
***************************************************************************************************/
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
