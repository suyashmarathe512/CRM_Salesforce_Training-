/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadServices
* @Description:   This class handles Lead operations in Salesforce: create, delete, and update based on Lead records.
***************************************************************************************************/
@RestResource(urlMapping='/LeadServices')
global with sharing class LeadServices {
    global class CustomValidationException extends Exception {}
/***************************************************************************************************
* @Author:        CRM Developer
* @ClassName:     ResponseWrapper
* @Description:   This class wraps the response parameters for consistent JSON output.
***************************************************************************************************/
    global class ResponseWrapper{
        public String status;
        public String message;
        public String LeadId;
    }

    private class DmlResponse {
        public List<ResponseWrapper> responseList;
        public Boolean hasError;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    sendErrorResponse
* @Param 1 :        res: stores the RestResponse object
* @Param 2 :        message: stores the error message
* @Param 3 :        statusCode: stores the status code
* @Description:   Helper method to send error responses.
***************************************************************************************************/
    private static void sendErrorResponse(RestResponse res, String message, Integer statusCode){
        ResponseWrapper errorResp = new ResponseWrapper();
        errorResp.status = 'error';
        errorResp.message = message;
        res.responseBody = Blob.valueOf(JSON.serialize(errorResp));
        res.statusCode = statusCode;
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
        try {
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
            if (recordId != null) {
                log.Lead__c = recordId;
            }
            insert log;
        } catch (Exception logEx) {
            System.debug('Failed to log error: ' + logEx.getMessage());
        }
    }

/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    processSaveResults
* @Param1:     results: List of Database.SaveResult
* @Param2:     classMethod: Method name for logging
* @Param3:     requestBody: Request body for logging
* @Param4:     operation: Operation type for logging
* @Param5:     successMessage: Message for successful operations
* @Description:   Helper method to process save results (insert/update).
***************************************************************************************************/
    private static DmlResponse processSaveResults(Database.SaveResult[] results, String classMethod, String requestBody, String operation, String successMessage) {
        DmlResponse dmlResp = new DmlResponse();
        dmlResp.responseList = new List<ResponseWrapper>();
        dmlResp.hasError = false;
        for (Database.SaveResult sr : results) {
            ResponseWrapper resp = new ResponseWrapper();
            if (sr.isSuccess()) {
                resp.status = 'success';
                resp.message = successMessage;
                resp.LeadId = sr.getId();
            }else{
                resp.status = 'error';
                resp.message = sr.getErrors()[0].getMessage();
                resp.LeadId = null;
                dmlResp.hasError = true;
                logError(classMethod, sr.getId(), requestBody, operation, new DmlException(sr.getErrors()[0].getMessage()));
            }
            dmlResp.responseList.add(resp);
        }
        return dmlResp;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:    processDeleteResults
* @Param1:     results: List of Database.DeleteResult
* @Param2:     classMethod: Method name for logging
* @Param3:     requestBody: Request body for logging
* @Param4:     operation: Operation type for logging
* @Param5:     successMessage: Message for successful operations
* @Description:   Helper method to process delete results.
***************************************************************************************************/
    private static DmlResponse processDeleteResults(Database.DeleteResult[] results, String classMethod, String requestBody, String operation, String successMessage) {
        DmlResponse dmlResp = new DmlResponse();
        dmlResp.responseList = new List<ResponseWrapper>();
        dmlResp.hasError = false;
        for (Database.DeleteResult dr : results) {
            ResponseWrapper resp = new ResponseWrapper();
            if (dr.isSuccess()) {
                resp.status = 'success';
                resp.message = successMessage;
                resp.LeadId = dr.getId();
            } else {
                resp.status = 'error';
                resp.message = dr.getErrors()[0].getMessage();
                resp.LeadId = null;
                dmlResp.hasError = true;
                logError(classMethod, dr.getId(), requestBody, operation, new DmlException(dr.getErrors()[0].getMessage()));
            }
            dmlResp.responseList.add(resp);
        }
        return dmlResp;
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
                List<Lead> leads = (List<Lead>)JSON.deserialize(req.requestBody.toString(), List<Lead>.class);
                Database.SaveResult[] results = Database.insert(leads, false);
                DmlResponse dmlResp = processSaveResults(results, 'LeadServices.createLead', req.requestBody.toString(), 'Insert Lead via REST', 'Lead created successfully');
                res.responseBody = Blob.valueOf(JSON.serialize(dmlResp.responseList));
                res.statusCode = dmlResp.hasError ? 404 : 200;
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
        if (String.isNotBlank(req.requestBody.toString())){
            try{
                List<Lead> leads = (List<Lead>)JSON.deserialize(req.requestBody.toString(), List<Lead>.class);
                Set<String> externalIds = new Set<String>();
                for (Lead lead : leads) {
                    if (lead.JSONProviderRemoteID__c != null) {
                        externalIds.add(lead.JSONProviderRemoteID__c);
                    }
                }
                Map<String, Id> externalIdToLeadId = new Map<String, Id>();
                if (!externalIds.isEmpty()) {
                    for (Lead existingLead : [SELECT
                                                Id, JSONProviderRemoteID__c
                                            FROM
                                                Lead
                                            WHERE
                                                JSONProviderRemoteID__c
                                            IN
                                                :externalIds]){
                        externalIdToLeadId.put(existingLead.JSONProviderRemoteID__c, existingLead.Id);
                    }
                }
                List<Lead> leadsToDelete = new List<Lead>();
                for (Lead lead : leads) {
                    if (lead.JSONProviderRemoteID__c != null && externalIdToLeadId.containsKey(lead.JSONProviderRemoteID__c)) {
                        Lead toDelete = new Lead(Id = externalIdToLeadId.get(lead.JSONProviderRemoteID__c));
                        leadsToDelete.add(toDelete);
                    }
                }
                if (!leadsToDelete.isEmpty()) {
                    Database.DeleteResult[] results = Database.delete(leadsToDelete, false);
                    DmlResponse dmlResp = processDeleteResults(results, 'LeadServices.deleteLead', req.requestBody.toString(), 'Delete Lead via REST', 'Lead deleted successfully');
                    res.responseBody = Blob.valueOf(JSON.serialize(dmlResp.responseList));
                    res.statusCode = dmlResp.hasError ? 404 : 200;
                } else {
                    sendErrorResponse(res, 'No valid leads to delete', 400);
                }
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
* @MethodName:    updateLead
* @Description:   This method updates Leads in Salesforce with partial success support.
***************************************************************************************************/
    @HttpPatch
    global static void updateLead() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (String.isNotBlank(req.requestBody.toString())){
            try{
                List<Lead> leads = (List<Lead>)JSON.deserialize(req.requestBody.toString(), List<Lead>.class);
                Set<String> externalIds = new Set<String>();
                for (Lead lead : leads) {
                    if (lead.JSONProviderRemoteID__c != null) {
                        externalIds.add(lead.JSONProviderRemoteID__c);
                    }
                }
                Map<String, Id> externalIdToLeadId = new Map<String, Id>();
                if (!externalIds.isEmpty()) {
                    for (Lead existingLead : [SELECT
                                                Id, JSONProviderRemoteID__c
                                                FROM
                                                    Lead
                                                WHERE
                                                    JSONProviderRemoteID__c
                                                IN
                                                    :externalIds]){
                        externalIdToLeadId.put(existingLead.JSONProviderRemoteID__c, existingLead.Id);
                    }
                }
                List<Lead> leadsToUpdate = new List<Lead>();
                for (Lead lead : leads) {
                    if (lead.JSONProviderRemoteID__c != null && externalIdToLeadId.containsKey(lead.JSONProviderRemoteID__c)) {
                        lead.Id = externalIdToLeadId.get(lead.JSONProviderRemoteID__c);
                        leadsToUpdate.add(lead);
                    }
                }
                if (!leadsToUpdate.isEmpty()) {
                    Database.SaveResult[] results = Database.update(leadsToUpdate, false);
                    DmlResponse dmlResp = processSaveResults(results, 'LeadServices.updateLead', req.requestBody.toString(), 'Update Lead via REST', 'Lead updated successfully');
                    res.responseBody = Blob.valueOf(JSON.serialize(dmlResp.responseList));
                    res.statusCode = dmlResp.hasError ? 404 : 200;
                } else {
                    sendErrorResponse(res, 'No valid leads to update', 400);
                }
            }catch(System.JSONException jsonEx){
                logError('LeadServices.updateLead', null, req.requestBody.toString(), 'Update Lead via REST', jsonEx);
                sendErrorResponse(res, 'Invalid JSON format', 400);
            }catch(Exception e){
                logError('LeadServices.updateLead', null, req.requestBody.toString(), 'Update Lead via REST', e);
                sendErrorResponse(res, e.getMessage(), 500);
            }
        }else{
            sendErrorResponse(res, 'Request body is empty', 400);
        }
    }
}
