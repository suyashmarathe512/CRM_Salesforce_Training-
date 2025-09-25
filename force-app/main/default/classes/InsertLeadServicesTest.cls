/***************************************************************************************************
* @Author:        CRM Developer
* @className:     InsertLeadServicesTest
* @Description:   Test class for InsertLeadServices with 100% code coverage.
***************************************************************************************************/
@isTest
public with sharing class InsertLeadServicesTest{
    private static void setupRestContext(){
        RestRequest req=new RestRequest();
        RestResponse res=new RestResponse();
        RestContext.request=req;
        RestContext.response=res;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testSuccessfulLeadCreation
* @Description:   Test method to test successful lead creation.
***************************************************************************************************/
    @isTest
    static void testSuccessfulLeadCreation(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(InsertLeadServicesTestMock.getRequestBody('success'));
        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(201,RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testSuccessfulMultipleLeadCreation
* @Description:   Test method to test multiple lead creation.
***************************************************************************************************/
    @isTest
    static void testSuccessfulMultipleLeadCreation(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(InsertLeadServicesTestMock.getRequestBody('multiple'));
        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(201,RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testEmptyRequestBody
* @Description:   Test method to test empty request body.
***************************************************************************************************/
    @isTest
    static void testEmptyRequestBody(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(InsertLeadServicesTestMock.getRequestBody('empty'));
        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testInvalidJSON
* @Description:   Test method to test invalid JSON format.
***************************************************************************************************/
    @isTest
    static void testInvalidJSON(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(InsertLeadServicesTestMock.getRequestBody('invalidJson'));
        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testMissingFirstName
* @Description:   Test method to test invalid JSON format.
***************************************************************************************************/
    @isTest
    static void testMissingFirstName(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(InsertLeadServicesTestMock.getRequestBody('missingFirstName'));
        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testException
* @Description:   Test method to test Invalid Email
***************************************************************************************************/
    @isTest
    static void testException() {
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(InsertLeadServicesTestMock.getRequestBody('invalidEmail'));
        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400,RestContext.response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testCalloutException
* @Description:   Test method to test CalloutException catch block.
***************************************************************************************************/
    @isTest
    static void testCalloutException(){
        setupRestContext();
        RestContext.request.requestBody=Blob.valueOf(InsertLeadServicesTestMock.getRequestBody('calloutException'));
        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(500,RestContext.response.statusCode);
    }
}
