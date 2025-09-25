/***************************************************************************************************
* @Author:        CRM Developer
* @className:     SolveMixDMLError
* @Description:   This class helps to solve the mix DML error. 
***************************************************************************************************/
public with sharing class SolveMixDMLError{
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     insertUserAsync
* @Description:   This method insert the user asynchronously.
***************************************************************************************************/
    @future
    public static void insertUserAsync(String username, String email, String lastName, String firstName, String alias, String profileId , Id UserRoleId) {
        User newUser = new User(
            Username = username,
            Email = email,
            LastName = lastName,
            FirstName = firstName,
            Alias = alias,
            ProfileId = profileId,
            UserRoleId = UserRoleId,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            );
        insert newUser;
        System.debug('New User Created: ' + newUser);
    } 
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     insertUsersolveMixDMLErrorAsync
* @Description:   This method inserts the account and call future method to insert the user.
***************************************************************************************************/
    public static void solveMixDMLError() {
        Id profileId = [SELECT 
                            Id 
                        FROM 
                            Profile 
                        WHERE 
                            Name = 'Standard Platform User' 
                        LIMIT 1].Id;
        Id UserRoleId = [SELECT 
                            Id 
                        FROM 
                            UserRole 
                        WHERE 
                            Name = 'Manager' 
                        LIMIT 1].Id;
        insertUserAsync('testuser534cv@example.com', 'testuser@example.com', 'Test', 'User', 'tuser', profileId, UserRoleId);
        Account newAccount = new Account(Name = 'Test Account');
        insert newAccount;
        system.debug('New Account Created' + newAccount);
    }

}
/*
solveMixDMLError.solveMixDMLError();
*/
