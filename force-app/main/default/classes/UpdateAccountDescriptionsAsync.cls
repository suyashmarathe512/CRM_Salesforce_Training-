/***************************************************************************************************
* @Author:        CRM Developer
* @className:     UpdateAccountDescriptionsAsync
* @Description:   This class implments future method that updates the account's description.  
***************************************************************************************************/
public with sharing class UpdateAccountDescriptionsAsync {
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     updateAccountDescriptions
* @Description:   This class implments future method that updates the account's description.  
***************************************************************************************************/
    @future
    public static void updateAccountDescriptions() {
        try {
            List<Account> accountsToUpdate = [SELECT 
                                                    Id, Description 
                                            FROM 
                                                Account 
                                            LIMIT 50000];
            for (Account acc : accountsToUpdate) {
                acc.Description = 'Account Description';
            }
            update accountsToUpdate;
        } catch (Exception e) {
            System.debug('Error updating accounts: ' + e.getMessage());
        }
    }
}
// UpdateAccountDescriptionsAsync.updateAccountDescriptions();
