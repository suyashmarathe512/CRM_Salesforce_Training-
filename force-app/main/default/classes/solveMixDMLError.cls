public with sharing class mixDMLErrorFutureMethod {
    @future
    public static void insertUserAsync(String username, String email, String lastName, String firstName, String alias, String communityNickname, String profileId) {
        User newUser = new User(
            Username = username,
            Email = email,
            LastName = lastName,
            FirstName = firstName,
            Alias = alias,
            ProfileId = profileId
        );
        insert newUser;

        System.debug('New User Created: ' + newUser);
    }
    
    public static void solveMixDMLError() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        insertUserAsync('testuser@example.com', 'testuser@example.com', 'Test', 'User', 'tuser', 'testuser', profileId);

        Account newAccount = new Account(Name = 'Test Account');
        insert newAccount;
        system.debug('New Account Created' + newAccount);
    }

}
/*
mixDMLErrorFutureMethod.insertUserAsync(
    'newuser@example.com', 
    'newuser@example.com', 
    'UserLastName', 
    'UserFirstName', 
    'nuser',
    [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
);
mixDMLErrorFutureMethod.solveMixDMLError();
*/