@isTest
public with sharing class AccountsInformationControllerTest {

    @TestSetup
    static void makeData() {
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test Account A', Email_Address__c = 'testA@example.com', Phone = '1234567890', Website = 'www.testA.com'));
        testAccounts.add(new Account(Name = 'Test Account B', Email_Address__c = 'testB@example.com', Phone = '0987654321', Website = 'www.testB.com'));
        testAccounts.add(new Account(Name = 'Another Account', Email_Address__c = 'another@example.com', Phone = '1111111111', Website = 'www.another.com'));
        insert testAccounts;
    }
    @isTest
    static void testSearchAccounts_BlankTerm() {
        AccountsInformationController controller = new AccountsInformationController();
        controller.searchTerm = '';
        Test.startTest();
        controller.searchAccounts();
        Test.stopTest();
        System.assert(controller.accountCount > 0, 'Should have accounts');
    }
    @isTest
    static void testSearchAccounts_ShortTerm() {
        AccountsInformationController controller = new AccountsInformationController();
        controller.searchTerm = 'Te';
        Test.startTest();
        controller.searchAccounts();
        Test.stopTest();
        System.assert(controller.accountCount > 0, 'Should have all accounts since term < 3');
    }
    @isTest
    static void testSearchAccounts_ValidTerm() {
        AccountsInformationController controller = new AccountsInformationController();
        controller.searchTerm = 'Test';
        Test.startTest();
        controller.searchAccounts();
        Test.stopTest();
        System.assert(controller.accountCount >= 2, 'Should have at least 2 accounts matching Test');
    }
    @isTest
    static void testClearSearch() {
        AccountsInformationController controller = new AccountsInformationController();
        controller.searchTerm = 'Test';
        controller.searchAccounts();
        Test.startTest();
        controller.clearSearch();
        Test.stopTest();
        System.assertEquals('', controller.searchTerm, 'Search term should be cleared');
    }
    @isTest
    static void testAlphabetSearch_All() {
        AccountsInformationController controller = new AccountsInformationController();
        controller.selectedAlphabet = 'All';
        Test.startTest();
        controller.alphabetSearch();
        Test.stopTest();
        System.assert(controller.accountCount > 0, 'Should have all accounts');
    }
    @isTest
    static void testAlphabetSearch_Specific() {
        AccountsInformationController controller = new AccountsInformationController();
        controller.selectedAlphabet = 'A';
        Test.startTest();
        controller.alphabetSearch();
        Test.stopTest();
        for (Account acc : controller.accounts) {
            System.assert(acc.Name.startsWith('A'), 'Account name should start with A');
        }
    }
    @isTest
    static void testDeleteAccountRemote_Success() {
        Account testAcc = [SELECT 
                                Id 
                            FROM 
                                Account 
                            WHERE 
                                Name = 'Test Account A' 
                            LIMIT 1];
        Test.startTest();
        String result = AccountsInformationController.deleteAccountRemote(testAcc.Id);
        Test.stopTest();
        System.assertEquals('success', result, 'Should return success');
        List<Account> deletedAcc = [SELECT 
                                        Id 
                                    FROM 
                                        Account 
                                    WHERE 
                                        Id = :testAcc.Id];
        System.assertEquals(0, deletedAcc.size(), 'Account should be deleted');
    }
}
