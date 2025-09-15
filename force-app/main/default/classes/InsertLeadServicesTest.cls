/***************************************************************************************************
* @Author:        CRM Developer
* @className:     InsertLeadServicesTest
* @Description:   Test class for InsertLeadServices with 100% code coverage.
***************************************************************************************************/
@isTest
public with sharing class InsertLeadServicesTest {
/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testSuccessfulLeadCreation
* @Description:   Test method to test successful lead creation.
***************************************************************************************************/
    @isTest
    static void testSuccessfulLeadCreation() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        String json = '[{"FirstName":"LeadServices","LastName":"Test","Email":"john.doe@example.com","Phone":"1234567890"}]';
        req.requestBody = Blob.valueOf(json);

        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();

        System.assertEquals(201, res.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testSuccessfulMultipleLeadCreation
* @Description:   Test method to test multiple lead creation.
***************************************************************************************************/
    @isTest
    static void testSuccessfulMultipleLeadCreation() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '[{"FirstName":"LeadServices","LastName":"Test2","Email":"john.doe@example.com","Phone":"1234567890"},' +
                      '{"FirstName":"LeadServices","LastName":"Test3","Email":"jane.smith@example.com","Phone":"0987654321"}]';
        req.requestBody = Blob.valueOf(json);

        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(201, res.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testEmptyRequestBody
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
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testInvalidJSON
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
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testMissingFirstName
* @Description:   Test method to test invalid JSON format.
***************************************************************************************************/
    @isTest
    static void testMissingFirstName() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '[{"LastName":"Doe","Email":"john.doe@example.com","Phone":"1234567890"}]';
        req.requestBody = Blob.valueOf(json);

        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testException
* @Description:   Test method to test Invalid Email
***************************************************************************************************/
    @isTest
    static void testException() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '[{"FirstName":"John","LastName":"Doe","Email":"john.doeexample.com","Phone":"1234567890"}]';
        req.requestBody = Blob.valueOf(json);
        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethdodName:     testCalloutException
* @Description:   Test method to test CalloutException catch block.
***************************************************************************************************/
    @isTest
    static void testCalloutException() {    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        String json = '[{"FirstName":"LeadServices","LastName":"CallOut","Email":"john.doe@example.com","Phone":"1234567890"}]';
        req.requestBody = Blob.valueOf(json);

        Test.setMock(HttpCalloutMock.class, new UnauthorizedEndpointResponse());

        Test.startTest();
        InsertLeadServices.createLead();
        Test.stopTest();

        System.assertEquals(500, res.statusCode);
    }

    public class UnauthorizedEndpointResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            throw new CalloutException('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
        }
    }
}
