/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadServices
* @Description:   This class handles Lead operations in Salesforce: create, delete, and update based on First Name, Last Name, Email and Phone values.
***************************************************************************************************/
@RestResource(urlMapping='/LeadServices/*')
global with sharing class LeadServices {
    global class CustomValidationException extends Exception {}
/***************************************************************************************************
* @Author:        CRM Developer
* @ClassName:     Wrapper
* @Description:   This class wraps the input parameters for the Lead operations.
***************************************************************************************************/
    global class Wrapper {
        public String FirstName;
        public String LastName;
        public String Email;
        public String Phone;
        public String NewEmail;
        public String NewPhone;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @ClassName:     ResponseWrapper
* @Description:   This class wraps the response parameters for consistent JSON output.
***************************************************************************************************/
    global class ResponseWrapper {
        public String status;
        public String message;
        public String LeadId;
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
* @MethodName:    validateWrapper
* @Param 1 :        w: stores the wrapper
* @Description:   Validates a single wrapper for required fields.
***************************************************************************************************/
    private static void validateWrapper(Wrapper w) {
        if(String.isBlank(w.FirstName) || String.isBlank(w.LastName)){
            throw new CustomValidationException('Missing required data: FirstName and LastName are required.');
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    logError
* @Param1:     classMethod: stores the name of the class causing error
* @Param2:     recordId: stores the id of the record causing error
* @Param3:     requestBody: stores the request body
* @Param4:     operation: stores the operation type
* @Param5:     e: stores the exception
* @Description:   This method logs the error in the Log__c object.
***************************************************************************************************/
    private static void logError(String classMethod, Id recordId, String requestBody, String operation, Exception e) {
        Logs__c log = new Logs__c();
        log.Error_Causing_Class_Method__c = classMethod;
        log.Error_Causing_Record_Id__c = (recordId != null) ? String.valueOf(recordId) : '';
        log.Message_Long__c = e.getMessage();
        log.Operation__c = operation;
        log.Severity__c = 'High';
        log.Stack_Trace__c = e.getStackTraceString();
        log.Status__c = 'Failed';
        log.Type__c = e.getTypeName();
        log.User_Context__c = UserInfo.getUserName();
        log.Request_Body__c = requestBody;
        log.Lead__c = recordId;
        insert log;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    createLead
* @Description:   This method creates new Leads in Salesforce with partial success support.
***************************************************************************************************/
    @HttpPost
    global static void createLead(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (String.isNotBlank(req.requestBody.toString())){
            try{
                List<Wrapper> inputWrappers = (List<Wrapper>)System.JSON.deserialize(req.requestBody.toString(), List<Wrapper>.class);
                List<ResponseWrapper> responseList = new List<ResponseWrapper>();
                List<Lead> leadsToInsert = new List<Lead>();
                Map<Integer, String> validationErrors = new Map<Integer, String>();
                for (Integer i = 0; i < inputWrappers.size(); i++) {
                    try {
                        validateWrapper(inputWrappers[i]);
                        Lead l = new Lead();
                        l.FirstName = inputWrappers[i].FirstName;
                        l.LastName = inputWrappers[i].LastName;
                        l.Email = inputWrappers[i].Email;
                        l.Phone = inputWrappers[i].Phone;
                        leadsToInsert.add(l);
                    } catch (CustomValidationException cvEx) {
                        validationErrors.put(i, cvEx.getMessage());
                    }
                }
                Database.SaveResult[] results = Database.insert(leadsToInsert, false);
                Integer resultIndex = 0;
                for (Integer i = 0; i < inputWrappers.size(); i++) {
                    ResponseWrapper resp = new ResponseWrapper();
                    if (validationErrors.containsKey(i)) {
                        resp.status = 'error';
                        resp.message = validationErrors.get(i);
                        resp.LeadId = null;
                    } else {
                        Database.SaveResult sr = results[resultIndex];
                        if (sr.isSuccess()) {
                            resp.status = 'success';
                            resp.message = 'Lead created successfully';
                            resp.LeadId = sr.getId();
                        } else {
                            resp.status = 'error';
                            resp.message = sr.getErrors()[0].getMessage();
                            resp.LeadId = null;
                            logError('LeadServices.createLead', null, req.requestBody.toString(), 'Insert Lead via REST', new DmlException(sr.getErrors()[0].getMessage()));
                        }
                        resultIndex++;
                    }
                    responseList.add(resp);
                }
                Boolean hasError = false;
                for (ResponseWrapper resp : responseList) {
                    if (resp.status == 'error') {
                        hasError = true;
                        break;
                    }
                }
                res.responseBody = Blob.valueOf(JSON.serialize(responseList));
                res.statusCode = hasError ? 404 : 200;
            }catch(System.JSONException jsonEx){
                logError('LeadServices.createLead', null, req.requestBody.toString(), 'Insert Lead via REST', jsonEx);
                sendErrorResponse(res, 'Invalid JSON format', 400);
            }catch(Exception e){
                logError('LeadServices.createLead', null, req.requestBody.toString(), 'Insert Lead via REST', e);
                sendErrorResponse(res, e.getMessage(), 500);
            }
        }else{
            sendErrorResponse(res, 'Request body is empty', 400);
        }
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    deleteLead
* @Description:   This method deletes Leads in Salesforce with partial success support.
***************************************************************************************************/
    @HttpDelete
    global static void deleteLead(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('Request is ' + req);
        if (String.isNotBlank(req.requestBody.toString())){
            try{
                List<Wrapper> inputWrappers = (List<Wrapper>)System.JSON.deserialize(req.requestBody.toString(), List<Wrapper>.class);
                List<ResponseWrapper> responseList = new List<ResponseWrapper>();
                List<Lead> leadsToDelete = new List<Lead>();
                Map<Integer, String> validationErrors = new Map<Integer, String>();
                List<String> firstNames = new List<String>();
                List<String> lastNames = new List<String>();
                List<String> emails = new List<String>();
                List<String> phones = new List<String>();
                for (Wrapper w : inputWrappers) {
                    firstNames.add(w.FirstName);
                    lastNames.add(w.LastName);
                    emails.add(w.Email);
                    phones.add(w.Phone);
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
                                            :lastNames 
                                        AND 
                                            Email 
                                        IN 
                                            :emails 
                                        AND 
                                            Phone 
                                        IN 
                                            :phones];
                for (Integer i = 0; i < inputWrappers.size(); i++) {
                    try {
                        validateWrapper(inputWrappers[i]);
                        List<Lead> matchingLeads = new List<Lead>();
                        for (Lead l : allLeads) {
                            if (l.FirstName == inputWrappers[i].FirstName && l.LastName == inputWrappers[i].LastName && l.Email == inputWrappers[i].Email && l.Phone == inputWrappers[i].Phone) {
                                matchingLeads.add(l);
                            }
                        }
                        if (matchingLeads.isEmpty()) {
                            validationErrors.put(i, 'No Lead found for FirstName: ' + inputWrappers[i].FirstName + ', LastName: ' + inputWrappers[i].LastName);
                        } else {
                            leadsToDelete.addAll(matchingLeads);
                        }
                    } catch (CustomValidationException cvEx) {
                        validationErrors.put(i, cvEx.getMessage());
                    }
                }
                Database.DeleteResult[] results = Database.delete(leadsToDelete, false);
                Integer resultIndex = 0;
                for (Integer i = 0; i < inputWrappers.size(); i++) {
                    ResponseWrapper resp = new ResponseWrapper();
                    if (validationErrors.containsKey(i)) {
                        resp.status = 'error';
                        resp.message = validationErrors.get(i);
                        resp.LeadId = null;
                    } else {
                        Database.DeleteResult dr = results[resultIndex];
                        if (dr.isSuccess()) {
                            resp.status = 'success';
                            resp.message = 'Lead deleted successfully';
                            resp.LeadId = dr.getId();
                        } else {
                            resp.status = 'error';
                            resp.message = dr.getErrors()[0].getMessage();
                            resp.LeadId = null;
                            logError('LeadServices.deleteLead', null, req.requestBody.toString(), 'Delete Lead via REST', new DmlException(dr.getErrors()[0].getMessage()));
                        }
                        resultIndex++;
                    }
                    responseList.add(resp);
                }
                Boolean hasError = false;
                for (ResponseWrapper resp : responseList) {
                    if (resp.status == 'error') {
                        hasError = true;
                        break;
                    }
                }
                res.responseBody = Blob.valueOf(JSON.serialize(responseList));
                res.statusCode = hasError ? 404 : 200;
            }catch(System.JSONException jsonEx){
                logError('LeadServices.deleteLead', null, req.requestBody.toString(), 'Delete Lead via REST', jsonEx);
                sendErrorResponse(res, 'Invalid JSON format', 400);
            }catch(Exception e){
                logError('LeadServices.deleteLead', null, req.requestBody.toString(), 'Delete Lead via REST', e);
                sendErrorResponse(res, e.getMessage(), 500);
            }
        }else{
            sendErrorResponse(res, 'Request body is empty', 400);
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    getLeadsToUpdateMap
* @Param 1 :        wrappers: stores the list of wrappers
* @Description:   Gets map of Leads to update from wrappers and errors for not found.
***************************************************************************************************/
    private static Map<Id, Lead> getLeadsToUpdateMap(List<Wrapper> wrappers, Map<Integer, String> errors){
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
        for (Integer i = 0; i < wrappers.size(); i++) {
            Wrapper w = wrappers[i];
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
                errors.put(i, 'No Lead found for FirstName: ' + w.FirstName + ', LastName: ' + w.LastName);
            }
        }
        return leadMap;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    updateLead
* @Description:   This method updates Leads in Salesforce with partial success support.
***************************************************************************************************/
    @HttpPatch
    global static void updateLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (String.isBlank(req.requestBody.toString())) {
            sendErrorResponse(res, 'Request body is empty', 400);
            return;
        }
        try {
            List<Wrapper> wrappers = (List<Wrapper>)JSON.deserialize(req.requestBody.toString(), List<Wrapper>.class);
            List<ResponseWrapper> responseList = new List<ResponseWrapper>();
            Map<Integer, String> validationErrors = new Map<Integer, String>();
            Map<Integer, String> notFoundErrors = new Map<Integer, String>();
            for (Integer i = 0; i < wrappers.size(); i++) {
                try {
                    validateWrapper(wrappers[i]);
                } catch (CustomValidationException cvEx) {
                    validationErrors.put(i, cvEx.getMessage());
                }
            }
            Map<Id, Lead> leadMap = getLeadsToUpdateMap(wrappers, notFoundErrors);
            List<Lead> leadsToUpdate = new List<Lead>(leadMap.values());
            Database.SaveResult[] results = Database.update(leadsToUpdate, false);
            Integer resultIndex = 0;
            for (Integer i = 0; i < wrappers.size(); i++) {
                ResponseWrapper resp = new ResponseWrapper();
                if (validationErrors.containsKey(i)) {
                    resp.status = 'error';
                    resp.message = validationErrors.get(i);
                    resp.LeadId = null;
                } else if (notFoundErrors.containsKey(i)) {
                    resp.status = 'error';
                    resp.message = notFoundErrors.get(i);
                    resp.LeadId = null;
                } else {
                    Database.SaveResult ur = results[resultIndex];
                    if (ur.isSuccess()) {
                        resp.status = 'success';
                        resp.message = 'Lead updated successfully';
                        resp.LeadId = ur.getId();
                    } else {
                        resp.status = 'error';
                        resp.message = ur.getErrors()[0].getMessage();
                        resp.LeadId = null;
                        logError('LeadServices.updateLead', null, req.requestBody.toString(), 'Update Lead via REST', new DmlException(ur.getErrors()[0].getMessage()));
                    }
                    resultIndex++;
                }
                responseList.add(resp);
            }
            Boolean hasError = false;
            for (ResponseWrapper resp : responseList) {
                if (resp.status == 'error') {
                    hasError = true;
                    break;
                }
            }
            res.responseBody = Blob.valueOf(JSON.serialize(responseList));
            res.statusCode = hasError ? 404 : 200;
        } catch (JSONException jsonEx) {
            logError('LeadServices.updateLead', null, req.requestBody.toString(), 'updateLead', jsonEx);
            sendErrorResponse(res, 'Invalid JSON format', 400);
        } catch (Exception e) {
            logError('LeadServices.updateLead', null, req.requestBody.toString(), 'updateLead', e);
            sendErrorResponse(res, e.getMessage(), 500);
        }
    }
}
/*
[{
    "FirstName": "Test",
    "LastName": "Service",
    "Email": "test.service@ts.com",
    "Phone": "1234567890"
}]

For Delete:
[{
    "FirstName": "Test",
    "LastName": "Service",
    "Email": "test.service@ts.com",
    "Phone": "1234567890"
}]

For Update:
[{
    "FirstName": "Test",
    "LastName": "Service",
    "NewEmail": "test.service@ts.com",
    "NewPhone": "1234567890"
}]
*/