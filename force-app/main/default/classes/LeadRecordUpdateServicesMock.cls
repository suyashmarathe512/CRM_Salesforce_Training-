/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadRecordUpdateServicesMock
* @Description:   Mock class for simulating callouts and generic exceptions in LeadRecordUpdateServices tests.
***************************************************************************************************/
@isTest
global class LeadRecordUpdateServicesMock implements HttpCalloutMock {
    public static String mockBehavior;

    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        if (mockBehavior == 'Update') {
            response.setStatusCode(200);
            response.setBody('{"status":"success"}');
            RestRequest restReq = new RestRequest();
            RestResponse restRes = new RestResponse();
            RestContext.request = restReq;
            RestContext.response = restRes;
            String requestBodyJson = '{"FirstName":"Test","LastName":"Lead","NewEmail":"changed.lead@example.com","NewPhone":"0987654321"}';
            restReq.requestBody = Blob.valueOf(requestBodyJson);
        } else {
            throw new System.CalloutException('Simulated callout exception');
        }
        return response;
    }
}
