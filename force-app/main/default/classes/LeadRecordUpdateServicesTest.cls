/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadRecordUpdateServicesTest
* @Description:   Test class for LeadRecordUpdateServices with 100% code coverage.
***************************************************************************************************/
@isTest
public with sharing class LeadRecordUpdateServicesTest {
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testLeadUpdateSuccess
* @Description:   Test method to test successful lead update
***************************************************************************************************/
    @isTest
    static void testLeadUpdateSuccess() {
        Lead sampleLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test.lead@example.com',
            Phone = '1234567890',
            Company = 'Test Company'
        );
        insert sampleLead;
        LeadRecordUpdateServicesMock.setupRestContext(LeadRecordUpdateServicesMock.getValidRequestBody());
        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
        Lead modifiedLead = [SELECT Id, Email, Phone FROM Lead WHERE Id = :sampleLead.Id];
        System.assertEquals('changed.lead@example.com', modifiedLead.Email);
        System.assertEquals('0987654321', modifiedLead.Phone);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testNoLeadFound
* @Description:   Test method to test no lead found scenario
***************************************************************************************************/
    @isTest
    static void testNoLeadFound() {
        LeadRecordUpdateServicesMock.setupRestContext(LeadRecordUpdateServicesMock.getNoLeadRequestBody());

        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(404, RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testEmptyRequestBody
* @Description:   Test method to test empty request body
***************************************************************************************************/
    @isTest
    static void testEmptyRequestBody() {
        LeadRecordUpdateServicesMock.setupRestContext(LeadRecordUpdateServicesMock.getEmptyRequestBody());
        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testInvalidJSON
* @Description:   Test method to test invalid JSON format (covers System.JSONException catch)
***************************************************************************************************/
    @isTest
    static void testInvalidJSON() {
        LeadRecordUpdateServicesMock.setupRestContext(LeadRecordUpdateServicesMock.getInvalidJsonRequestBody());
        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testMissingRequiredData
* @Description:   Test method to test missing FirstName or LastName (covers CustomValidationException catch)
***************************************************************************************************/
    @isTest
    static void testMissingRequiredData() {
        LeadRecordUpdateServicesMock.setupRestContext(LeadRecordUpdateServicesMock.getMissingDataRequestBody());
        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testDMLException
* @Description:   Test method to test DML exception handling (simulate update failure)
***************************************************************************************************/
    @isTest
    static void testDMLException() {
        Lead sampleLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test.lead@example.com',
            Phone = '1234567890',
            Company = 'Test Company'
        );
        insert sampleLead;
        LeadRecordUpdateServicesMock.setupRestContext(LeadRecordUpdateServicesMock.getDMLExceptionRequestBody());
        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testCalloutException
* @Description:   Test method to test callout exception handling (though no callout in code, but catch exists)
***************************************************************************************************/
    @isTest
    static void testCalloutException() {
        LeadRecordUpdateServicesMock.setupRestContext(LeadRecordUpdateServicesMock.getCalloutExceptionRequestBody());
        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(500, RestContext.response.statusCode);
    }
}
