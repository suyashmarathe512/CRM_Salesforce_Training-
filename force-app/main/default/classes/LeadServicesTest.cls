/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadServicesTest
* @Description:   Test class for LeadServices with 100% code coverage.
***************************************************************************************************/
@isTest
public with sharing class LeadServicesTest{
    private static void setupRestContext(){
        RestRequest req=new RestRequest();
        RestResponse res=new RestResponse();
        RestContext.request=req;
        RestContext.response=res;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testSuccessfulLeadCreation
* @Description:   Test method to test successful lead creation.
***************************************************************************************************/
    @isTest
    static void testSuccessfulLeadCreation(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getRequestBody('success'));
        Test.startTest();
        LeadServices.createLead();
        Test.stopTest();
        System.assertEquals(200,RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testSuccessfulMultipleLeadCreation
* @Description:   Test method to test multiple lead creation.
***************************************************************************************************/
    @isTest
    static void testSuccessfulMultipleLeadCreation(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getRequestBody('multiple'));
        Test.startTest();
        LeadServices.createLead();
        Test.stopTest();
        System.assertEquals(200,RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testEmptyRequestBody
* @Description:   Test method to test empty request body.
***************************************************************************************************/
    @isTest
    static void testEmptyRequestBody(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getRequestBody('empty'));
        Test.startTest();
        LeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testInvalidJSON
* @Description:   Test method to test invalid JSON format.
***************************************************************************************************/
    @isTest
    static void testInvalidJSON(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getRequestBody('invalidJson'));
        Test.startTest();
        LeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testMissingFirstName
* @Description:   Test method to test missing FirstName.
***************************************************************************************************/
    @isTest
    static void testMissingFirstName(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getRequestBody('missingFirstName'));
        Test.startTest();
        LeadServices.createLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testException
* @Description:   Test method to test Invalid Email
***************************************************************************************************/
    @isTest
    static void testException() {
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getRequestBody('invalidEmail'));
        Test.startTest();
        LeadServices.createLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testCalloutException
* @Description:   Test method to test CalloutException catch block.
***************************************************************************************************/
    @isTest
    static void testCalloutException(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getRequestBody('calloutException'));
        Test.startTest();
        LeadServices.createLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testSuccessfulLeadDeletion
* @Description:   Test method to test successful lead deletion.
***************************************************************************************************/
    @isTest
    static void testSuccessfulLeadDeletion(){
        Lead l = new Lead(FirstName='LeadServices', LastName='Test', Email='LeadServices.Test@example.com', Phone='1234567890');
        insert l;
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getDeleteRequestBody('success'));
        Test.startTest();
        LeadServices.deleteLead();
        Test.stopTest();
        System.assertEquals(200,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testNoLeadsFoundDeletion
* @Description:   Test method to test no leads found for deletion.
***************************************************************************************************/
    @isTest
    static void testNoLeadsFoundDeletion(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getDeleteRequestBody('noLead'));
        Test.startTest();
        LeadServices.deleteLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testEmptyRequestBodyDeletion
* @Description:   Test method to test empty request body for deletion.
***************************************************************************************************/
    @isTest
    static void testEmptyRequestBodyDeletion(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getDeleteRequestBody('empty'));
        Test.startTest();
        LeadServices.deleteLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testInvalidJSONDeletion
* @Description:   Test method to test invalid JSON for deletion.
***************************************************************************************************/
    @isTest
    static void testInvalidJSONDeletion(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getDeleteRequestBody('invalidJson'));
        Test.startTest();
        LeadServices.deleteLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testMissingFirstNameDeletion
* @Description:   Test method to test missing FirstName for deletion.
***************************************************************************************************/
    @isTest
    static void testMissingFirstNameDeletion(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getDeleteRequestBody('missingFirstName'));
        Test.startTest();
        LeadServices.deleteLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testSuccessfulLeadUpdate
* @Description:   Test method to test successful lead update.
***************************************************************************************************/
    @isTest
    static void testSuccessfulLeadUpdate(){
        Lead l = new Lead(FirstName='LeadServices', LastName='Test', Email='old@example.com', Phone='0000000000');
        insert l;
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getUpdateRequestBody('success'));
        Test.startTest();
        LeadServices.updateLead();
        Test.stopTest();
        System.assertEquals(200,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testEmptyRequestBodyUpdate
* @Description:   Test method to test empty request body for update.
***************************************************************************************************/
    @isTest
    static void testEmptyRequestBodyUpdate(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getUpdateRequestBody('empty'));
        Test.startTest();
        LeadServices.updateLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testInvalidJSONUpdate
* @Description:   Test method to test invalid JSON for update.
***************************************************************************************************/
    @isTest
    static void testInvalidJSONUpdate(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getUpdateRequestBody('invalidJson'));
        Test.startTest();
        LeadServices.updateLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testMissingFirstNameUpdate
* @Description:   Test method to test missing FirstName for update.
***************************************************************************************************/
    @isTest
    static void testMissingFirstNameUpdate(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getUpdateRequestBody('missingFirstName'));
        Test.startTest();
        LeadServices.updateLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testNoLeadFoundUpdate
* @Description:   Test method to test no lead found for update.
***************************************************************************************************/
    @isTest
    static void testNoLeadFoundUpdate(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getUpdateRequestBody('noLead'));
        Test.startTest();
        LeadServices.updateLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
    @isTest
    static void testUpdateDmlException(){
        Lead l = new Lead(FirstName='LeadServices', LastName='Test', Email='old@example.com', Phone='0000000000');
        insert l;
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getUpdateRequestBody('DMLException'));
        Test.startTest();
        LeadServices.updateLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testPartialSuccessCreate
* @Description:   Test method to test partial success in lead creation.
***************************************************************************************************/
    @isTest
    static void testPartialSuccessCreate(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getRequestBody('partialCreate'));
        Test.startTest();
        LeadServices.createLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testPartialSuccessDelete
* @Description:   Test method to test partial success in lead deletion.
***************************************************************************************************/
    @isTest
    static void testPartialSuccessDelete(){
        Lead existingLead = new Lead(FirstName='Existing', LastName='Lead', Email='existing@example.com', Phone='1234567890');
        insert existingLead;
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getDeleteRequestBody('partialDelete'));
        Test.startTest();
        LeadServices.deleteLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testPartialSuccessUpdate
* @Description:   Test method to test partial success in lead update.
***************************************************************************************************/
    @isTest
    static void testPartialSuccessUpdate(){
        Lead existingLead = new Lead(FirstName='Existing', LastName='Lead', Email='old@example.com', Phone='0000000000');
        insert existingLead;
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(LeadServicesTestMock.getUpdateRequestBody('partialUpdate'));
        Test.startTest();
        LeadServices.updateLead();
        Test.stopTest();
        System.assertEquals(404,RestContext.response.statusCode);
    }
}
