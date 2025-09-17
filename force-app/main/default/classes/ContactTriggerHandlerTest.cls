/***************************************************************************************************
* @Author:        CRM Developer
* @className:     ContactTriggerHandlerTest
* @Description:   This class tests the ContactTriggerHandler functionality including duplicate checks and account association.
***************************************************************************************************/
@isTest
public class ContactTriggerHandlerTest {
    /***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    setupTestData
* @Description:   This method sets up test data including accounts with different website formats.
***************************************************************************************************/
      @testSetup
    static void setupTestData() {
        Account acc1 = new Account(Name='Test Acc WWW', Website='www.test.com');
        Account acc2 = new Account(Name='Test Acc HTTPS', Website='https://secure.com');
        Account acc3 = new Account(Name='Test Acc Other', Website='www.other.com');
        insert new List<Account>{acc1, acc2, acc3};
    }

    /***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    testDuplicateFound
* @Description:   This method tests the duplicate contact detection functionality.
***************************************************************************************************/
    @isTest
    static void testDuplicateFound() {
        Contact c1 = new Contact(LastName='Test1', Email='dup@test.com', Phone='11111');
        insert c1;  
        Contact c2 = new Contact(LastName='Test2', Email='dup@test.com', Phone='11111');
        Test.startTest();
        try {
            insert c2;
            System.assert(false, 'Expected duplicate exception');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('already exists'));
        }
        Test.stopTest();
    }
    /***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    testNoDuplicate
* @Description:   This method tests that unique contacts are inserted without errors.
***************************************************************************************************/
    @isTest
    static void testNoDuplicate() {
        Contact c1 = new Contact(LastName='Unique1', Email='u1@test.com', Phone='22222');
        Contact c2 = new Contact(LastName='Unique2', Email='u2@test.com', Phone='33333');
        Test.startTest();
        insert new List<Contact>{c1, c2};
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Contact WHERE Email LIKE 'u%@test.com']);
    }
    /***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    testAssociateAccount_www
* @Description:   This method tests account association for contacts with www domain emails.
***************************************************************************************************/
    @isTest
    static void testAssociateAccount_www() {
        Account acc = [SELECT Id FROM Account WHERE Website = 'www.test.com' LIMIT 1];        
        Contact c = new Contact(LastName='User1', Email='abc@test.com');
        Test.startTest();
        insert c;
        Test.stopTest();     
        Contact con = [SELECT AccountId FROM Contact WHERE Id=:c.Id];
        System.assertEquals(acc.Id, con.AccountId, 'Should associate with www.test.com');
    }
    /***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    testAssociateAccount_https
* @Description:   This method tests account association for contacts with https domain emails.
***************************************************************************************************/
    @isTest
    static void testAssociateAccount_https() {
        Account acc1 = [SELECT Id FROM Account WHERE Website = 'https://secure.com' LIMIT 1];
        Contact c = new Contact(LastName='User2', Email='abc@secure.com');
        Test.startTest();
        insert c;
        Test.stopTest();
        Contact con = [SELECT AccountId FROM Contact WHERE Id=:c.Id];
        System.assertEquals(acc1.Id, con.AccountId, 'Should associate with https://secure.com');
    }
    /***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    testNoMatchingAccount
* @Description:   This method tests that contacts are not associated when no matching account website is found.
***************************************************************************************************/
    @isTest
    static void testNoMatchingAccount() {
        Account acc = [SELECT Id FROM Account WHERE Website = 'www.other.com' LIMIT 1];    
        Contact c = new Contact(LastName='User3', Email='abc@nomatch.com');
        Test.startTest();
        insert c;
        Test.stopTest(); 
        Contact con = [SELECT AccountId FROM Contact WHERE Id=:c.Id];
        System.assertEquals(null, con.AccountId, 'Should not associate when no match');
    }
}