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
        public Set<Id> LeadIds;
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
        for (Wrapper w : wrappers) {
            if (String.isBlank(w.FirstName)||String.isBlank(w.LastName)) {
                throw new CustomValidationException('Missing required data: FirstName and LastName are required.');
            }
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    getLeadsToUpdateMap
* @Param 1 :        wrappers: stores the list of wrappers
* @Description:   Gets map of Leads to update from wrappers.
***************************************************************************************************/
private static Map<Id, Lead> getLeadsToUpdateMap(List<Wrapper> wrappers){
        List<String> firstNames = new List<String>();
        List<String> lastNames = new List<String>();
        for (Wrapper w : wrappers){
            firstNames.add(w.FirstName);
            lastNames.add(w.LastName);
        }
        List<Lead> allLeads = [SELECT
                                    Id, FirstName, LastName, Email, Phone
                                FROM
                                    Lead
                                WHERE
                                    FirstName
                                IN
                                    :firstNames
                                AND
                                    LastName
                                IN
                                    :lastNames];
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        for (Wrapper w : wrappers) {
            Boolean found = false;
            for (Lead l : allLeads) {
                if (l.FirstName == w.FirstName && l.LastName == w.LastName) {
                    l.Email = w.NewEmail;
                    l.Phone = w.NewPhone;
                    leadMap.put(l.Id, l);
                    found = true;
                    break;
                }
            }
            if (!found) {
                throw new CustomValidationException('No Lead found for FirstName: ' + w.FirstName + ', LastName: ' + w.LastName);
            }
        }
        return leadMap;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    updateLead
* @Description:   This class update the Lead in Salesforce basis the First Name, Last Name, Email and
                   Phone values.
***************************************************************************************************/
@HttpPatch
global static void updateLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (String.isBlank(req.requestBody.toString())) {
            sendErrorResponse(res, 'Request body is empty', 400);
            return;
        }
        Set<Id> leadIds;
        try {
            List<Wrapper> wrappers = (List<Wrapper>)JSON.deserialize(req.requestBody.toString(), List<Wrapper>.class);
            validateWrappers(wrappers);
            Map<Id, Lead> leadMap = getLeadsToUpdateMap(wrappers);
            List<Lead> leadsToUpdate = new List<Lead>(leadMap.values());
            leadIds = new Set<Id>(leadMap.keySet());
            update leadsToUpdate;
            ResponseWrapper successResp = new ResponseWrapper();
            successResp.status = 'success';
            successResp.message = 'Leads updated successfully';
            successResp.LeadIds = leadIds;
            res.responseBody = Blob.valueOf(JSON.serialize(successResp));
            res.statusCode = 200;
        } catch (JSONException jsonEx) {
            logError('LeadRecordUpdateServices.updateLead',null, req.requestBody.toString(), jsonEx);
            sendErrorResponse(res, 'Invalid JSON format',400);
        } catch (CustomValidationException cvEx) {
            logError('LeadRecordUpdateServices.updateLead', null, req.requestBody.toString(), cvEx);
            sendErrorResponse(res, cvEx.getMessage(), 404);
        }catch (DmlException dmlEx){
            Id relatedLeadId = (leadIds == null || leadIds.isEmpty()) ? null: new List<Id>(leadIds).get(0);
            logError('LeadRecordUpdateServices.updateLead',relatedLeadId, req.requestBody.toString(), dmlEx);
            sendErrorResponse(res, dmlEx.getMessage(), 415);
        } catch (CalloutException callEx) {
            logError('LeadRecordUpdateServices.updateLead',null, req.requestBody.toString(), callEx);
            sendErrorResponse(res, 'Callout error: ' + callEx.getMessage(), 500);
        } catch (Exception e) {
            logError('LeadRecordUpdateServices.updateLead',null, req.requestBody.toString(), e);
            sendErrorResponse(res, e.getMessage(), 500);
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
private static void logError(String classMethod,Id relatedLead, String requestBody, Exception e) {
        Logs__c errorLog = new Logs__c(
            Error_Causing_Class_Method__c = classMethod,
            Error_Causing_Record_Id__c = (relatedLead != null) ? String.valueOf(relatedLead) : '',
            Message_Long__c = e.getMessage(),
            Operation__c = 'updateLead',
            Severity__c = 'High',
            Stack_Trace__c = e.getStackTraceString(),
            Status__c = 'Failed',
            Type__c = e.getTypeName(),
            User_Context__c = UserInfo.getUserName(),
            Request_Body__c = requestBody,
            Lead__c = relatedLead
        );
        insert errorLog;
    }
}
