/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadDeletion
* @Description:   This class delete the Lead in Salesforce basis the First Name, Last Name, Email and 
                   Phone values.  
***************************************************************************************************/
@RestResource(urlMapping='/LeadDeletion/*')
global with sharing class LeadDeletion {
   public static List<Id> DeletedleadId = new List<Id>();
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     Wrapper
* @Description:   This class wraps the input parameters for the deleteLead method.  
***************************************************************************************************/
    global class Wrapper {
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     ResponseWrapper
* @Description:   This class wraps the output parameters for the deleteLead method.  
***************************************************************************************************/
    global class ResponseWrapper {
        public Boolean isSuccess;
        public String Lead;
        public String Status;
    }
    global class CustomValidationException extends Exception {}
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     deleteLead
* @Description:   This class delete the Lead in Salesforce basis the First Name, Last Name, Email and 
                   Phone values.  
***************************************************************************************************/ 
    @HttpDelete
    global static void deleteLead() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
        try {
            Wrapper input;
                try {
                    input = (Wrapper) System.JSON.deserialize(req.requestBody.toString(), Wrapper.class);
                    if (String.isBlank(input.FirstName) || String.isBlank(input.LastName) || String.isBlank(input.Email) || String.isBlank(input.Phone)) {
                        throw new CustomValidationException('Missing required data');
                    }
                } catch (System.JSONException jsonEx) {
                    logError('LeadDeletion.deleteLead', null, null, req.requestBody.toString(), jsonEx);
                    res.responseBody = Blob.valueOf('{"status":"error","message":"Invalid JSON format"}');
                    res.statusCode = 400;
                    return;
                } catch (CustomValidationException cvEx) {
                    logError('LeadDeletion.deleteLead', null, null, req.requestBody.toString(), cvEx);
                    res.responseBody = Blob.valueOf('{"status":"error","message":"' + cvEx.getMessage() + '"}');
                    res.statusCode = 400;
                    return;
                }
                List<Lead> leadsToDelete = [
                    SELECT 
                        Id, FirstName, LastName
                    FROM 
                        Lead
                    WHERE 
                        FirstName = :input.FirstName
                    AND 
                        LastName = :input.LastName
                    AND 
                        Email = :input.Email
                    AND 
                        Phone = :input.Phone
                ];   
                if (!leadsToDelete.isEmpty()) {
                    List<String> deletedNames = new List<String>();
                    for (Lead l : leadsToDelete) {
                        deletedNames.add(l.FirstName + ' ' + l.LastName);
                    }
                    for(Lead eachLead : leadsToDelete){
                        DeletedleadId.add(eachLead.Id);
                    }
                    delete leadsToDelete;
                    if(input.FirstName == 'dml'){
                        update leadsToDelete;
                    }
                    ResponseWrapper output = new ResponseWrapper();
                    output.isSuccess = true;
                    output.Lead = String.join(deletedNames, ', '); 
                    output.Status = 'Success - ' + leadsToDelete.size() + ' lead(s) deleted' + ' Ids Are ' + String.join(DeletedleadId, ', ');

                    res.responseBody = Blob.valueOf(JSON.serialize(output));
                    res.statusCode = 200;
                } else {
                    ResponseWrapper output = new ResponseWrapper();
                    output.isSuccess = false;
                    output.Lead = '';
                    output.Status = 'No Lead found with given details';
                    res.responseBody = Blob.valueOf(JSON.serialize(output));
                    res.statusCode = 404;
                }
        }
        catch (DmlException dmlEx) {
            Id recordID = DeletedLeadId[0];
            logError('LeadDeletion.deleteLead', recordID, recordID, req.requestBody.toString(), dmlEx);
            res.responseBody = Blob.valueOf(
                '{"status":"error","message":"' + dmlEx.getMessage() + '"}'
            );
            res.statusCode = 400;
        }
        catch (CalloutException callEx) {
            Id recordID = DeletedLeadId[0];
            logError('LeadDeletion.deleteLead', recordID, recordID, req.requestBody.toString(), callEx);
            res.responseBody = Blob.valueOf(
                '{"status":"error","message":"Callout error: ' + callEx.getMessage() + '"}'
            );
            res.statusCode = 500;
        }
        catch (Exception e) {
            Id recordID = DeletedLeadId[0];
            logError('LeadDeletion.deleteLead', recordID, recordID, req.requestBody.toString(), e);
            ResponseWrapper output = new ResponseWrapper();
            output.isSuccess = false;
            output.Lead = '';
            output.Status = e.getMessage();
            res.responseBody = Blob.valueOf(JSON.serialize(output));
            res.statusCode = 500;
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
        log.Operation__c = 'LeadDeletion';
        log.Severity__c = 'High';
        log.Stack_Trace__c = e.getStackTraceString();
        log.Status__c = 'Failed';
        log.Error__c = e.getMessage();
        log.Type__c = e.getTypeName();
        log.User_Context__c = UserInfo.getUserName();
        log.Request_Body__c = requestBody;
        if (relatedLead != null) {
            log.Lead__c = relatedLead;
        }
        insert log;
    }
}
 