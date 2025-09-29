/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadDeletionTest
* @Description:   Test class for LeadDeletion with 100% code coverage.
***************************************************************************************************/
@isTest
public with sharing class LeadDeletionTest {
    private static void setupRestContext() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testSuccessfulLeadDeletion
* @Description:   Test method to test successful lead deletion.
***************************************************************************************************/
    @isTest
    static void testSuccessfulLeadDeletion() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test.lead@example.com',
            Phone = '1234567890',
            Company = 'Test Company'
        );
        insert testLead;
        setupRestContext();
        RestContext.request.requestBody = Blob.valueOf(LeadDeletionMock.getRequestBody('success'));
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
        List<Lead> deletedLeads = [SELECT Id FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(0, deletedLeads.size());
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testSuccessfulMultipleLeadDeletion
* @Description:   Test method to test multiple lead deletion.
***************************************************************************************************/
    @isTest
    static void testSuccessfulMultipleLeadDeletion() {
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 2; i++) {
            testLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead',
                Email = 'test.lead@example.com',
                Phone = '1234567890',
                Company = 'Test Company ' + i
            ));
        }
        insert testLeads;
        setupRestContext();
        RestContext.request.requestBody = Blob.valueOf(LeadDeletionMock.getRequestBody('multiple'));
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
        List<Lead> deletedLeads = [SELECT Id FROM Lead WHERE Id IN :testLeads];
        System.assertEquals(0, deletedLeads.size());
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testNoLeadFound
* @Description:   Test method to test no lead found.
***************************************************************************************************/
    @isTest
    static void testNoLeadFound() {
        setupRestContext();
        RestContext.request.requestBody = Blob.valueOf(LeadDeletionMock.getRequestBody('noLead'));
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(404, RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testEmptyRequestBody
* @Description:   Test method to test empty request body.
***************************************************************************************************/
    @isTest
    static void testEmptyRequestBody() {
        setupRestContext();
        RestContext.request.requestBody = Blob.valueOf(LeadDeletionMock.getRequestBody('empty'));
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(404, RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testInvalidJSON
* @Description:   Test method to test invalid JSON format.
***************************************************************************************************/
    @isTest
    static void testInvalidJSON() {
        setupRestContext();
        RestContext.request.requestBody = Blob.valueOf(LeadDeletionMock.getRequestBody('invalidJson'));
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testMissingFirstName
* @Description:   Test method to test missing FirstName.
***************************************************************************************************/
    @isTest
    static void testMissingFirstName() {
        setupRestContext();
        RestContext.request.requestBody = Blob.valueOf(LeadDeletionMock.getRequestBody('missingFirstName'));
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(404, RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testCalloutException
* @Description:   Test method to test callout exception handling.
***************************************************************************************************/
    @isTest
    static void testCalloutException() {    
        setupRestContext();
        RestContext.request.requestBody = Blob.valueOf(LeadDeletionMock.getRequestBody('calloutException'));
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(500, RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testDMLException
* @Description:   Test method to test DML exception handling.
***************************************************************************************************/
    @isTest
    static void testDMLException() {
        setupRestContext();
        RestContext.request.requestBody = Blob.valueOf(LeadDeletionMock.getRequestBody('dmlException'));
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(404, RestContext.response.statusCode);
    }
}
