/***************************************************************************************************
* @Author:        CRM Developer
* @className:     AccountPrefixUpdater
* @Description:   This class implements queueable job that updates account names with prefix based on offset.
***************************************************************************************************/
public with sharing class AccountPrefixUpdater implements Queueable {
    private Integer offset;
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     AccountPrefixUpdater
* @Description:   Constructor to set the offset for the update.
***************************************************************************************************/
    public AccountPrefixUpdater(Integer offset) {
        this.offset = offset;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     execute
* @Description:   Executes the appropriate update method based on offset.
***************************************************************************************************/
    public void execute(QueueableContext context) {
        if (offset == 0) {
            updateAccounts(0);
        } else if (offset == 50) {
            updateAccounts(50);
        } else if (offset == 100) {
            updateAccounts(100);
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     updateAccounts
* @Description:   method to perform the account update with given offset.
***************************************************************************************************/
    public void updateAccounts(Integer offset) {
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
                                            :offset];
        if (!accountsToUpdate.isEmpty()) {
            for (Account acc : accountsToUpdate) {
                acc.Name = 'CTI - ' + acc.Name;
            }
            update accountsToUpdate;
        }
    }
}
