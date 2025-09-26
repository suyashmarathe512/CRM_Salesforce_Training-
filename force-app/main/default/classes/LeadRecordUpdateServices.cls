/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadRecordUpdateServices
* @Description:   This class update the Lead in Salesforce basis the First Name, Last Name, Email and
                   Phone values.
***************************************************************************************************/
@RestResource(urlMapping='/UpdateLead/*')
global with sharing class LeadRecordUpdateServices{
    global class CustomValidationException extends Exception{}
/***************************************************************************************************
* @Author:        CRM Developer
* @ClassName:     Wrapper
* @Description:   This class wraps the input parameters for the updateLead method.
***************************************************************************************************/
     global class Wrapper{
        public String FirstName;
        public String LastName;
        public String NewEmail;
        public String NewPhone;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @ClassName:     ResponseWrapper
* @Description:   This class wraps the response parameters for consistent JSON output.
***************************************************************************************************/
     global class ResponseWrapper{
        public String status;
        public String message;
        public List<String> LeadIds;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    sendErrorResponse
* @Param 1 :        res: stores the RestResponse object
* @Param 2 :        message: stores the error message
* @Param 3 :        statusCode: stores the status code
* @Description:   Helper method to send error responses.
***************************************************************************************************/
    private static void sendErrorResponse(RestResponse res, String message, Integer statusCode) {
        ResponseWrapper errorResp = new ResponseWrapper();
        errorResp.status = 'error';
        errorResp.message = message;
        res.responseBody = Blob.valueOf(JSON.serialize(errorResp));
        res.statusCode = statusCode;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    validateWrappers
* @Param 1 :        wrappers: stores the list of wrappers
* @Description:   Validates the list of wrappers for required fields.
***************************************************************************************************/
    private static void validateWrappers(List<Wrapper> wrappers) {
        for(Wrapper w : wrappers){
            if(String.isBlank(w.FirstName) || String.isBlank(w.LastName)){
                throw new CustomValidationException('Missing required data: FirstName and LastName are required.');
            }
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    updateLeadsFromWrappers
* @param 1 :        wrappers: stores the list of wrappers
* @Description:   Updates Leads from wrappers, returns list of IDs.
***************************************************************************************************/
    private static List<String> updateLeadsFromWrappers(List<Wrapper> wrappers) {
        List<Lead> leadsToUpdate = new List<Lead>();
        List<String> leadIds = new List<String>();
        for (Wrapper w : wrappers){
            List<Lead> matchingLeads = [SELECT 
                                            Id, Email, Phone 
                                        FROM Lead WHERE FirstName = :w.FirstName AND LastName = :w.LastName LIMIT 1];
            if (matchingLeads.isEmpty()) {
                throw new CustomValidationException('No Lead found for the given FirstName and LastName.');
            }
            Lead l = matchingLeads[0];
            l.Email = w.NewEmail;
            l.Phone = w.NewPhone;
            leadsToUpdate.add(l);
            leadIds.add(l.Id);
        }
        update leadsToUpdate;
        return leadIds;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    updateLead
* @Description:   This class update the Lead in Salesforce basis the First Name, Last Name, Email and
                   Phone values.
***************************************************************************************************/
@HttpPatch
    global static void updateLead(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('Request is ' + req);
        if (String.isNotBlank(req.requestBody.toString())){
            try{
                List<Wrapper> inputWrappers = (List<Wrapper>)System.JSON.deserialize(req.requestBody.toString(), List<Wrapper>.class);
                validateWrappers(inputWrappers);
                List<String> leadIds = updateLeadsFromWrappers(inputWrappers);
                ResponseWrapper successResp = new ResponseWrapper();
                successResp.status = 'success';
                successResp.message = 'Leads updated successfully';
                successResp.LeadIds = leadIds;
                res.responseBody = Blob.valueOf(JSON.serialize(successResp));
                res.statusCode = 200;
            }catch(System.JSONException jsonEx){
                logError('LeadRecordUpdateServices.updateLead', null, null, req.requestBody.toString(), jsonEx);
                sendErrorResponse(res, 'Invalid JSON format', 400);
            }catch(CustomValidationException cvEx){
                logError('LeadRecordUpdateServices.updateLead', null, null, req.requestBody.toString(), cvEx);
                if (cvEx.getMessage().contains('No Lead found')) {
                    sendErrorResponse(res, cvEx.getMessage(), 404);
                } else {
                    sendErrorResponse(res, cvEx.getMessage(), 400);
                }
            }catch(DmlException dmlEx){
                logError('LeadRecordUpdateServices.updateLead', null, null, req.requestBody.toString(), dmlEx);
                sendErrorResponse(res, dmlEx.getMessage(), 400);
            }catch(CalloutException callEx){
                logError('LeadRecordUpdateServices.updateLead', null, null, req.requestBody.toString(), callEx);
                sendErrorResponse(res, 'Callout error: ' + callEx.getMessage(), 500);
            }catch(Exception e){
                logError('LeadRecordUpdateServices.updateLead', null, null, req.requestBody.toString(), e);
                sendErrorResponse(res, e.getMessage(), 500);
            }
        }else{
            sendErrorResponse(res, 'Request body is empty', 400);
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     logError
* @Param1:     classMethod: stores the name of the class causing error
* @Param2:     recordId: stores the id of the record causing error
* @Param3:     relatedLead: stores the related lead Id
* @Param4:     requestBody: stores the request body
* @Param5:     e: stores the exception
* @Description:   This class logs the error in the Log__c object.
***************************************************************************************************/
    private static void logError(String classMethod,Id recordId,Id relatedLead,String requestBody,Exception e) {
        Logs__c log=new Logs__c();
        log.Error_Causing_Class_Method__c=classMethod;
        log.Error_Causing_Record_Id__c=(recordId != null)?String.valueOf(recordId):'';
        log.Message_Long__c=e.getMessage();
        log.Operation__c='Update Lead via REST';
        log.Severity__c='High';
        log.Stack_Trace__c=e.getStackTraceString();
        log.Status__c='Failed';
        log.Type__c=e.getTypeName();
        log.User_Context__c=UserInfo.getUserName();
        log.Request_Body__c=requestBody;
        log.Lead__c=relatedLead;
        insert log;
    }
}