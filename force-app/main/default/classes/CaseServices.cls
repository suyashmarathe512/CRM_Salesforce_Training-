@RestResource(urlMapping='/caseservice')
global with sharing class CaseServices {
    public class RequestWrapper {
        public String contactId;
        public String Subject;
        public String Status;
        public String Priority;
    }
    public class ResponseWrapper {
        public String message;
        public List<Case> cases;

    }
    public static Boolean validateContactId(String contactId, RestResponse res) {
        if (String.isBlank(contactId)) {
            ResponseWrapper errorResp = new ResponseWrapper();
            errorResp.message = 'Invalid contactId: contactId cannot be null or empty';
            errorResp.cases = new List<Case>();
            res.responseBody = Blob.valueOf(JSON.serialize(errorResp));
            res.statusCode = 400;
            return false;
        } else {
            if ([SELECT 
                    Id 
                FROM 
                    Contact 
                WHERE 
                    Id = :contactId].size() > 0) {
                return true;
            } else {
                ResponseWrapper errorResp = new ResponseWrapper();
                errorResp.message = 'Invalid contactId: Contact does not exist';
                errorResp.cases = new List<Case>();
                res.responseBody = Blob.valueOf(JSON.serialize(errorResp));
                res.statusCode = 400;
                return false;
            }
        }
    }
    @HttpGET
    global static void getCasesOfContacts() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RequestWrapper reqBody = (RequestWrapper) JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);
        String contactId = reqBody.contactId;
        if (!validateContactId(contactId, res)) {
            return;
        }
        try {
            List<Case> cases = [SELECT
                                    Id, Subject, Status, Priority
                                FROM
                                    Case
                                WHERE
                                    ContactId = :contactId];

            ResponseWrapper successResp = new ResponseWrapper();
            if (cases.isEmpty()) {
                successResp.message = 'No cases found for the specified contact';
            } else {
                successResp.message = 'Cases retrieved successfully';
            }
            successResp.cases = cases;
            res.responseBody = Blob.valueOf(JSON.serialize(successResp));
            res.statusCode = 200;
        } catch (Exception e) {
            ResponseWrapper errorResp = new ResponseWrapper();
            errorResp.message = 'Error retrieving cases: ' + e.getMessage();
            errorResp.cases = new List<Case>();
            res.responseBody = Blob.valueOf(JSON.serialize(errorResp));
            res.statusCode = 500;
        }
    }
    @HttpPOST
    global static void createCase() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RequestWrapper reqBody = (RequestWrapper) JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);
        String contactId = reqBody.contactId;
        String subject = reqBody.Subject;
        String status = reqBody.Status;
        String priority = reqBody.Priority;
        if (!validateContactId(contactId, res)) {
            return;
        }
        try {
            Case newCase = new Case(
                Subject = subject,
                Status = status,
                Priority = priority,
                ContactId = contactId,
                OwnerId = UserInfo.getUserId()
            );
            insert newCase;
            ResponseWrapper successResp = new ResponseWrapper();
            successResp.message = 'Case created successfully';
            successResp.cases = new List<Case>{newCase};
            res.responseBody = Blob.valueOf(JSON.serialize(successResp));
            res.statusCode = 200;
            if(priority == 'High') {
                    Task highPriorityTask = new Task(
                        Subject = 'Initial High Priority Case Review',
                        Status = 'Not Started',
                        Priority = 'High',
                        WhatId = newCase.Id,
                        OwnerId = UserInfo.getUserId()
                    );
                insert highPriorityTask;
            }
        } catch (Exception e) {
            ResponseWrapper errorResp = new ResponseWrapper();
            errorResp.message = 'Error creating case: ' + e.getMessage();
            errorResp.cases = new List<Case>();
            res.responseBody = Blob.valueOf(JSON.serialize(errorResp));
            res.statusCode = 500;
        }
    }
    @HttpPatch
    global static void updateCase() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String caseId = req.params.get('caseId');
        RequestWrapper reqBody = (RequestWrapper) JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);
        String subject = reqBody.Subject;
        String status = reqBody.Status;
        String priority = reqBody.Priority;
        try {
            Case updatedCase = new Case(
                Id = caseId,
                Subject = subject,
                Status = status,
                Priority = priority
                );
            update updatedCase;
            ResponseWrapper successResp = new ResponseWrapper();
            successResp.message = 'Case updated successfully';
            successResp.cases = new List<Case>{updatedCase};
            res.responseBody = Blob.valueOf(JSON.serialize(successResp));
            res.statusCode = 200;
        } catch (Exception e) {
            ResponseWrapper errorResp = new ResponseWrapper();
            errorResp.message = 'Error updating case: ' + e.getMessage();
            errorResp.cases = new List<Case>();
            res.responseBody = Blob.valueOf(JSON.serialize(errorResp));
            res.statusCode = 500;
        }

    }
}