/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadRecordUpdateServicesMock
* @Description:   Mock class for simulating callouts and generic exceptions in LeadRecordUpdateServices tests.
***************************************************************************************************/
@isTest
global class LeadRecordUpdateServicesMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse response = new HTTPResponse();
        throw new System.CalloutException('Simulated callout exception');
    }
}
