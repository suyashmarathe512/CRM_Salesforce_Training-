/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadDeletionTest
* @Description:   Test class for LeadDeletion with 100% code coverage.
***************************************************************************************************/
@isTest
public with sharing class LeadDeletionTest {

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testSuccessfulLeadDeletion
* @Description:   Test method to test successful lead deletion.
***************************************************************************************************/
    @isTest
    static void testSuccessfulLeadDeletion() {
        // Create test lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test.lead@example.com',
            Phone = '1234567890',
            Company = 'Test Company'
        );
        insert testLead;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '{"FirstName":"Test","LastName":"Lead","Email":"test.lead@example.com","Phone":"1234567890"}';
        req.requestBody = Blob.valueOf(json);

        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();

        System.assertEquals(200, res.statusCode);
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
        // Create test leads with same details
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
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '{"FirstName":"Test","LastName":"Lead","Email":"test.lead@example.com","Phone":"1234567890"}';
        req.requestBody = Blob.valueOf(json);

        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(200, res.statusCode);
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
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '{"FirstName":"Unknown","LastName":"Test","Email":"Unlnown@Test.com","Phone":"1234567890"}';
        req.requestBody = Blob.valueOf(json);

        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();

        System.assertEquals(404, res.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testEmptyRequestBody
* @Description:   Test method to test empty request body.
***************************************************************************************************/
    @isTest
    static void testEmptyRequestBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        req.requestBody = Blob.valueOf('');

        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testInvalidJSON
* @Description:   Test method to test invalid JSON format.
***************************************************************************************************/
    @isTest
    static void testInvalidJSON() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        req.requestBody = Blob.valueOf('invalid json');

        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testMissingFirstName
* @Description:   Test method to test missing FirstName.
***************************************************************************************************/
    @isTest
    static void testMissingFirstName() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '{"LastName":"Test","Email":"abc.test@example.com","Phone":"1234567890"}';
        req.requestBody = Blob.valueOf(json);
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testCalloutException
* @Description:   Test method to test callout exception handling.
***************************************************************************************************/
    @isTest
    static void testCalloutException() {    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        String json = '[{"FirstName":"LeadServices","LastName":"CallOut","Email":"LeadServices.CallOut@example.com","Phone":"1234567890"}]';
        req.requestBody = Blob.valueOf(json);
        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());
        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }
    public class UnauthorizedEndpointResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            throw new CalloutException('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testDMLException
* @Description:   Test method to test DML exception handling.
***************************************************************************************************/
    @isTest
    static void testDMLException() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '{"FirstName": "dml","LastName":"test","Email":"dml.test@example.com","Phone":"1234567890"}';
        req.requestBody = Blob.valueOf(json);

        Test.startTest();
        LeadDeletion.deleteLead();
        Test.stopTest();

        System.assertEquals(404, res.statusCode);
    }
}
