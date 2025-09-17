/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadRecordUpdateServices
* @Description:   This class update the Lead in Salesforce basis the First Name, Last Name,  New Email and 
                    New Phone values.  
***************************************************************************************************/
@RestResource(urlMapping='/UpdateLead/*')
global with sharing class LeadRecordUpdateServices {
    public static List<Id> IdLeadUpdated = new List<Id>();
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadWrapper
* @Description:   This class wraps the input parameters for the updateLead method.  
***************************************************************************************************/
    global class LeadWrapper {
        public String FirstName;
        public String LastName;
        public String NewEmail;
        public String NewPhone;
    }
    global class CustomValidationException extends Exception {}
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     updateLead
* @Description:   This class update the Lead in Salesforce basis the First Name, Last Name,  New Email and 
                    New Phone values.
***************************************************************************************************/
@HttpPatch
    global static void updateLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (String.isNotBlank(req.requestBody.toString())) {
            LeadWrapper input;
                try {
                    input = (LeadWrapper) System.JSON.deserialize(req.requestBody.toString(), LeadWrapper.class);
                    if (String.isBlank(input.FirstName) || String.isBlank(input.LastName)) {
                        throw new CustomValidationException('Missing required data');
                    }
                } catch (System.JSONException jsonEx) {
                    logError('LeadRecordUpdateServices.updateLead', null, null, req.requestBody.toString(), jsonEx);
                    res.responseBody = Blob.valueOf('{"status":"error","message":"Invalid JSON format"}');
                    res.statusCode = 400;
                    return;
                } catch (CustomValidationException cvEx) {
                    logError('LeadRecordUpdateServices.updateLead', null, null, req.requestBody.toString(), cvEx);
                    res.responseBody = Blob.valueOf('{"status":"error","message":"' + cvEx.getMessage() + '"}');
                    res.statusCode = 400;
                    return;
                }

            try {
                List<Lead> leadsToUpdate = [
                    SELECT Id, FirstName, LastName, Email, Phone
                    FROM Lead
                    WHERE FirstName = :input.FirstName
                    AND LastName = :input.LastName
                ];
                System.debug(leadsToUpdate);
                if (!leadsToUpdate.isEmpty()) {
                    for (Lead l : leadsToUpdate) {
                        IdLeadUpdated.add(l.Id);
                        l.Email = input.NewEmail;
                        l.Phone = input.NewPhone;
                    }
                    update leadsToUpdate;
                    res.responseBody = Blob.valueOf(
                        '{"isSuccess":true,' +
                        '"LeadId":"' + IdLeadUpdated+  '",' +
                        '"Status":"Success"}'
                    );
                    res.statusCode = 200;
                } else {
                    res.responseBody = Blob.valueOf(
                        '{"isSuccess":false,"Lead":"","Status":"No Lead found with given FirstName and LastName"}'
                    );
                    res.statusCode = 404;
                }
            } catch (DmlException dmlEx) {
                system.debug(IdLeadUpdated);
                Id recordID = IdLeadUpdated[0];
                logError('LeadRecordUpdateServices.updateLead', recordID, recordID, req.requestBody.toString(), dmlEx);
                res.responseBody = Blob.valueOf(
                    '{"isSuccess":false,"Lead":"","Status":"' + dmlEx.getMessage() + '"}'
                );
                res.statusCode = 400;
            }
            catch (CalloutException callEx) {
                system.debug(IdLeadUpdated);
                Id recordID = IdLeadUpdated[0];
                logError('LeadRecordUpdateServices.updateLead', recordID, recordID, req.requestBody.toString(), callEx);
                res.responseBody = Blob.valueOf(
                    '{"isSuccess":false,"Lead":"","Status":"Callout error: ' + callEx.getMessage() + '"}'
                );
                res.statusCode = 500;   
            }
            catch (Exception e) {
                system.debug(IdLeadUpdated);
                Id recordID = IdLeadUpdated[0];
                logError('LeadRecordUpdateServices.updateLead', recordID, recordID, req.requestBody.toString(), e);
                res.responseBody = Blob.valueOf(
                    '{"isSuccess":false,"Lead":"","Status":"' + e.getMessage() + '"}'
                );
                res.statusCode = 500;
            }
        } else {
            res.responseBody = Blob.valueOf(
                '{"isSuccess":false,"Lead":"","Status":"Request body is empty"}'
            );
            res.statusCode = 400;
        }
        system.debug(IdLeadUpdated);
        IdLeadUpdated.clear();
        system.debug(IdLeadUpdated);

    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     logError
* @Param1:     classMethod: stores the name of the class causing error
* @Param2:     recordId: stores the id of the record causing error
* @Param3:     relatedLead: stores the related lead Id
* @Param4:     requestBody: stores the request body
* @Param5:     errorMessage: stores the error message
* @Description:   This method logs the error in the Logs__c object.
***************************************************************************************************/
    private static void logError(String classMethod, Id recordId, Id relatedLead, String requestBody, Exception errorMessage) {
        Logs__c log = new Logs__c();
        log.Error_Causing_Class_Method__c = classMethod;
        log.Error_Causing_Record_Id__c = (recordId != null) ? String.valueOf(recordId) : '';
        log.Message_Long__c = errorMessage.getMessage();
        log.Operation__c = 'LeadUpdate';
        log.Severity__c = 'High';
        log.Stack_Trace__c = errorMessage.getStackTraceString();
        log.Status__c = 'Failed';
        log.Error__c = errorMessage.getMessage();
        log.Type__c = errorMessage.getTypeName();
        log.User_Context__c = UserInfo.getUserName();
        log.Request_Body__c = requestBody;
        if (relatedLead != null) {
            log.Lead__c = relatedLead;
        }
        insert log;
    }
}