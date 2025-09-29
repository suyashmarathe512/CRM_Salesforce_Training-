/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadRecordUpdateServicesMock
* @Description:   Utility class for setting up test data and simulating exceptions in LeadRecordUpdateServices tests.
***************************************************************************************************/
@isTest
public class LeadRecordUpdateServicesMock {
    public static void setupRestContext(String requestBodyJson) {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;
        request.requestBody = Blob.valueOf(requestBodyJson);
    }
    public static String getValidRequestBody(){
        return '[{"FirstName":"Test","LastName":"Lead","NewEmail":"changed.lead@example.com","NewPhone":"0987654321"}]';
    }
    public static String getNoLeadRequestBody(){
        return '[{"FirstName":"Unknown","LastName":"Test","NewEmail":"unknown@test.com","NewPhone":"1234567890"}]';
    }
    public static String getInvalidJsonRequestBody(){
        return 'invalid json';
    }
    public static String getMissingDataRequestBody(){
        return '[{"LastName":"Test","NewEmail":"abc.test@example.com","NewPhone":"1234567890"}]';
    }
    public static String getDMLExceptionRequestBody(){
        return '[{"FirstName":"Test","LastName":"Lead","NewEmail":"invalidemail","NewPhone":"1234567890"}]';
    }
    public static String getCalloutExceptionRequestBody(){
        throw new CalloutException('Callout Exception');
    }
    public static String getEmptyRequestBody(){
        return '';
    }
}
