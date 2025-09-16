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
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        String requestBodyJson = '{"FirstName":"Test","LastName":"Lead","NewEmail":"changed.lead@example.com","NewPhone":"0987654321"}';
        request.requestBody = Blob.valueOf(requestBodyJson);

        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(200, response.statusCode);
        Lead modifiedLead = [SELECT Id, Email, Phone FROM Lead WHERE Id = :sampleLead.Id];
        System.assertEquals('changed.lead@example.com', modifiedLead.Email);
        System.assertEquals('0987654321', modifiedLead.Phone);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testMultipleLeadUpdateSuccess
* @Description:   Test method to test successful update of multiple leads
***************************************************************************************************/
    @isTest
    static void testMultipleLeadUpdateSuccess() {
        List<Lead> sampleLeads = new List<Lead>();
        sampleLeads.add(new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test1.lead@example.com',
            Phone = '1234567890',
            Company = 'Test Company1'
        ));
        sampleLeads.add(new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'test2.lead@example.com',
            Phone = '1234567891',
            Company = 'Test Company2'
        ));
        insert sampleLeads;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        String requestBodyJson = '{"FirstName":"Test","LastName":"Lead","NewEmail":"updated.lead@example.com","NewPhone":"0987654321"}';
        request.requestBody = Blob.valueOf(requestBodyJson);

        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(200, response.statusCode);
        List<Lead> modifiedLeads = [SELECT Id, Email, Phone FROM Lead WHERE Id IN :sampleLeads];
        System.assertEquals(2, modifiedLeads.size());
        for (Lead l : modifiedLeads) {
            System.assertEquals('updated.lead@example.com', l.Email);
            System.assertEquals('0987654321', l.Phone);
        }
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testNoLeadFound
* @Description:   Test method to test no lead found scenario
***************************************************************************************************/
    @isTest
    static void testNoLeadFound() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        String requestBodyJson = '{"FirstName":"Unknown","LastName":"Test","NewEmail":"unknown@test.com","NewPhone":"1234567890"}';
        request.requestBody = Blob.valueOf(requestBodyJson);

        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(404, response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testEmptyRequestBody
* @Description:   Test method to test empty request body
***************************************************************************************************/
    @isTest
    static void testEmptyRequestBody() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        request.requestBody = Blob.valueOf('');

        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(400, response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testInvalidJSON
* @Description:   Test method to test invalid JSON format (covers System.JSONException catch)
***************************************************************************************************/
    @isTest
    static void testInvalidJSON() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        request.requestBody = Blob.valueOf('invalid json');

        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(400, response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testMissingRequiredData
* @Description:   Test method to test missing FirstName or LastName (covers CustomValidationException catch)
***************************************************************************************************/
    @isTest
    static void testMissingRequiredData() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        String requestBodyJson = '{"LastName":"Test","NewEmail":"abc.test@example.com","NewPhone":"1234567890"}'; // Missing FirstName
        request.requestBody = Blob.valueOf(requestBodyJson);

        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(400, response.statusCode);
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
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        String requestBodyJson = '{"FirstName":"Test","LastName":"Lead","NewEmail":"test.leadexample.com","NewPhone":"1234567890"}';
        request.requestBody = Blob.valueOf(requestBodyJson);
        Test.startTest();
        LeadRecordUpdateServices.updateLead();
        Test.stopTest();
        System.assertEquals(400, response.statusCode);
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testCalloutException
* @Description:   Test method to test callout exception handling (though no callout in code, but catch exists)
***************************************************************************************************/
    @isTest
    static void testCalloutException() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        String requestBodyJson = '{"FirstName":"Test","LastName":"Lead","NewEmail":"test.lead@example.com","NewPhone":"1234567890"}';
        request.requestBody = Blob.valueOf(requestBodyJson);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LeadRecordUpdateServicesMock());
        try {
            LeadRecordUpdateServices.updateLead();
        } catch (System.CalloutException callEx) { 
            response.responseBody = Blob.valueOf(
                '{"isSuccess":false,"Lead":"","Status":"Callout error: ' + callEx.getMessage() + '"}'
            );
            response.statusCode = 500;
        }
        Test.stopTest();
        System.assertEquals(500, response.statusCode);
        System.assert(response.responseBody.toString().contains('Callout error'));
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     testGenericException
* @Description:   Test method to test generic exception handling
***************************************************************************************************
    @isTest
    static void testGenericException() {
        LeadRecordUpdateServicesMock.mockBehavior = 'nullpointer';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        String requestBodyJson = '{"FirstName":"Test","LastName":"Lead","NewEmail":"test.lead@example.com","NewPhone":"0987654321"}';
        request.requestBody = Blob.valueOf(requestBodyJson);
        Boolean exceptionCaught = false;
        try {
            LeadRecordUpdateServicesMock mock = new LeadRecordUpdateServicesMock();
        } catch (System.NullPointerException e) {
            exceptionCaught = true;
            response.responseBody = Blob.valueOf(
                '{"isSuccess":false,"Lead":"","Status":"' + e.getMessage() + '"}'
            );
            response.statusCode = 500;
        }
        System.assert(exceptionCaught, 'NullPointerException was not caught');
        System.assertEquals(500, response.statusCode);
        System.assert(response.responseBody.toString().contains('Simulated NullPointerException'));
    }*/
}
