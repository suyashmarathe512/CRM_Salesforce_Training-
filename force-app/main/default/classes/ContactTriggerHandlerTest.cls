@isTest
public class ContactTriggerHandlerTest {
    //Update for the review.
    
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
    
    @isTest
    static void testNoDuplicate() {
        Contact c1 = new Contact(LastName='Unique1', Email='u1@test.com', Phone='22222');
        Contact c2 = new Contact(LastName='Unique2', Email='u2@test.com', Phone='33333');
        Test.startTest();
        insert new List<Contact>{c1, c2};
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Contact WHERE Email LIKE 'u%@test.com']);
    }

    @isTest
    static void testAssociateAccount_www() {
        Account acc = new Account(Name='Acc1', Website='www.test.com');
        insert acc;
        
        Contact c = new Contact(LastName='User1', Email='abc@test.com');
        Test.startTest();
        insert c;
        Test.stopTest();
        
        Contact con = [SELECT AccountId FROM Contact WHERE Id=:c.Id];
        System.assertEquals(acc.Id, con.AccountId, 'Should associate with www.test.com');
    }
    
    @isTest
    static void testAssociateAccount_https() {
        Account acc1 = new Account(Name='Acc2', Website='https://secure.com');
        insert acc1;
        
        Contact c = new Contact(LastName='User2', Email='abc@secure.com');
        Test.startTest();
        insert c;
        Test.stopTest();
        
        Contact con = [SELECT AccountId FROM Contact WHERE Id=:c.Id];
        System.assertEquals(acc1.Id, con.AccountId, 'Should associate with https://secure.com');
    }
    
    @isTest
    static void testNoMatchingAccount() {
        Account acc = new Account(Name='Acc3', Website='www.other.com');
        insert acc;
        
        Contact c = new Contact(LastName='User3', Email='abc@nomatch.com');
        Test.startTest();
        insert c;
        Test.stopTest();
        
        Contact con = [SELECT AccountId FROM Contact WHERE Id=:c.Id];
        System.assertEquals(null, con.AccountId, 'Should not associate when no match');
    }
    
    @isTest
    static void testEmailMissing() {
        Contact c = new Contact(LastName='NoEmail');
        Test.startTest();
        try {
            insert c;
            System.assert(false, 'Expected email error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Email address is required'));
        }
        Test.stopTest();
    }
}