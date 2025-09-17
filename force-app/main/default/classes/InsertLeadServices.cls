/***************************************************************************************************
* @Author:        CRM Developer
* @className:     InsertLeadServices
* @Description:   This class create a new Lead in Salesforce basis the First Name, Last Name, Email and 
                   Phone values.  
***************************************************************************************************/
@RestResource(urlMapping='/InsertLead/*')
global with sharing class InsertLeadServices {
    global class CustomValidationException extends Exception {}
/***************************************************************************************************
* @Author:        CRM Developer
* @ClassName:     Wrapper
* @Description:   This class wraps the input parameters for the createLead method.  
***************************************************************************************************/
     global class Wrapper {
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    createLead
* @Description:   This class create a new Lead in Salesforce basis the First Name, Last Name, Email and 
                   Phone values.
***************************************************************************************************/
    @HttpPost
    global static void createLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;    
        System.debug('Request is ' + req);
        if (String.isNotBlank(req.requestBody.toString())) {
            try {
                List<Wrapper> inputWrappers;
                try {
                    inputWrappers = (List<Wrapper>) System.JSON.deserialize(req.requestBody.toString(), List<Wrapper>.class);
                    for (Wrapper w : inputWrappers) {
                        if (String.isBlank(w.FirstName) || String.isBlank(w.LastName)) {
                            throw new CustomValidationException('Missing required data: FirstName and LastName are required.');
                        }
                    }
                } catch (System.JSONException jsonEx) {
                    logError('InsertLeadServices.createLead', null, null, req.requestBody.toString(), jsonEx);
                    res.responseBody = Blob.valueOf('{"status":"error","message":"Invalid JSON format"}');
                    res.statusCode = 400;
                    return;
                } catch (CustomValidationException cvEx) {
                    logError('InsertLeadServices.createLead', null, null, req.requestBody.toString(), cvEx);
                    res.responseBody = Blob.valueOf('{"status":"error","message":"' + cvEx.getMessage() + '"}');
                    res.statusCode = 400;
                    return;
                }
                List<Lead> newLeads = new List<Lead>();
                for (Wrapper w : inputWrappers) {
                    Lead l = new Lead();
                    l.FirstName = w.FirstName;
                    l.LastName  = w.LastName;
                    l.Email     = w.Email;
                    l.Phone     = w.Phone;
                    newLeads.add(l);
                }
                insert newLeads;
                List<String> leadIds = new List<String>();
                for (Lead l : newLeads) {
                    leadIds.add(l.Id);
                }
                res.responseBody = Blob.valueOf(
                    '{"status":"success","message":"Leads created successfully","LeadIds":'
                    + JSON.serialize(leadIds) + '}'
                );
                res.statusCode = 201;
            }
            catch (DmlException dmlEx) {
                logError('InsertLeadServices.createLead', null, null, req.requestBody.toString(), dmlEx);
                res.responseBody = Blob.valueOf(
                    '{"status":"error","message":"' + dmlEx.getMessage() + '"}'
                );
                res.statusCode = 400;
            }
            catch (CalloutException callEx) {
                logError('InsertLeadServices.createLead', null, null, req.requestBody.toString(), callEx);
                res.responseBody = Blob.valueOf(
                    '{"status":"error","message":"Callout error: ' + callEx.getMessage() + '"}'
                );
                res.statusCode = 500;
            }
            catch (Exception e) {
                logError('InsertLeadServices.createLead', null, null, req.requestBody.toString(), e);
                res.responseBody = Blob.valueOf(
                    '{"status":"error","message":"' + e.getMessage() + '"}'
                );
                res.statusCode = 500;
            }
        } else {
            res.responseBody = Blob.valueOf(
                '{"status":"error","message":"Request body is empty"}'
            );
            res.statusCode = 400;
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
    private static void logError(String classMethod, Id recordId, Id relatedLead, String requestBody, Exception e) {
        Logs__c log = new Logs__c();
        log.Error_Causing_Class_Method__c = classMethod;
        log.Error_Causing_Record_Id__c = (recordId != null) ? String.valueOf(recordId) : '';
        log.Message_Long__c = e.getMessage();
        log.Operation__c = 'Insert Lead via REST';
        log.Severity__c = 'High';
        log.Stack_Trace__c = e.getStackTraceString();
        log.Status__c = 'Failed';
        log.Error__c = e.getMessage();
        log.Type__c = e.getTypeName();
        log.User_Context__c = UserInfo.getUserName();
        log.Request_Body__c = requestBody;
        log.Lead__c = relatedLead;
        insert log;
            
    }
}	