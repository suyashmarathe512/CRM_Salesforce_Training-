@isTest
public with sharing class CaseServicesTest {
    @TestSetup
    static void makeData(){
        Contact contact = new Contact(LastName = 'Test Contact');
        insert contact;
    }
    @isTest
    static void testGetCasesOfContact(){
        Contact contact = [SELECT 
                                Id 
                            FROM 
                                Contact 
                            WHERE 
                                LastName = 'Test Contact' 
                            LIMIT 1];
        RestRequest req = new RestRequest();
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        CaseServices.getCasesOfContact();
        Test.stopTest();
    }
}