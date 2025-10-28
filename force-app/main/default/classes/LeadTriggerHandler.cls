/***************************************************************************************************
* @Author:        CRM Developer
* @className:     LeadTriggerHandler
* @Description:   This class handles the trigger logic for the Lead object and makes an HTTP callout to the LeadServices endpoint.
***************************************************************************************************/
global class LeadTriggerHandler {
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     makeHttpCallout
* @Description:   This method makes an HTTP callout to the LeadServices endpoint to create, update, or delete Leads.
***************************************************************************************************/
    @future(callout=true)
    public static void makeHttpCallout(String jsonString, String method) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:LeadORG/services/apexrest/LeadServices');
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonString);
            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() != 200) {
                System.debug('HTTP callout failed: ' + res.getStatusCode() + ' ' + res.getStatus());
            }
            System.debug(res.getStatusCode() + ' ' + res.getBody());
        } catch (Exception e) {
            System.debug('HTTP callout failed: ' + e.getMessage());
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     serializeLeadsToJson
* @Param 1 :        leads: stores the list of leads
* @Param 2 :        removeId: stores the boolean value to remove Id field
* @Description:   This method serializes the list of leads to JSON format, filtering out problematic fields.
***************************************************************************************************/
    private static String serializeLeadsToJson(List<Lead> leads, Boolean removeId) {
        List<Map<String, Object>> leadMaps = new List<Map<String, Object>>();
        Set<String> fieldsToRemove = new Set<String>{
            'CreatedDate', 'LastModifiedDate', 'OwnerId', 'CreatedById', 'LastModifiedById', 'SystemModstamp',
            'IsDeleted', 'IsConverted', 'ConvertedDate', 'ConvertedAccountId', 'ConvertedContactId', 'ConvertedOpportunityId',
            'MasterRecordId', 'IsUnreadByOwner', 'LastActivityDate', 'LastViewedDate', 'LastReferencedDate',
            'Jigsaw', 'JigsawContactId', 'CleanStatus', 'CompanyDunsNumber', 'DandbCompanyId', 'EmailBouncedReason',
            'EmailBouncedDate', 'IndividualId', 'HasOptedOutOfEmail', 'HasOptedOutOfFax', 'DoNotCall', 'IsEmailBounced',
            'PhotoUrl', 'CanSendEmail', 'SendEmailOptIn', 'attributes', 'LastModifiedByID', 'CreatedByID', 'IsPriorityRecord', 'LastTransferDate'
        };
        if (removeId) {
            fieldsToRemove.add('Id');
        }
        for (Lead lead : leads) {
            Map<String, Object> leadMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(lead));
            for (String field : fieldsToRemove) {
                leadMap.remove(field);
            }
            // Add the external unique field for update/delete
            if (lead.CunningGoatID__c != null) {
                leadMap.put('JSONProviderRemoteID__c', lead.CunningGoatID__c);
            }
            leadMaps.add(leadMap);
        }
        return JSON.serialize(leadMaps);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     afterInsert
* @Param 1 :        leads: stores the list of leads
* @Description:   This method is called after the insert of leads and makes an HTTP callout to the LeadServices endpoint.
***************************************************************************************************/
    public static void afterInsert(List<Lead> newLeads) {
        String jsonString = serializeLeadsToJson(newLeads, true);
        makeHttpCallout(jsonString, 'POST');
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     afterUpdate
* @Param 1 :        leads: stores the list of leads
* @Description:   This method is called after the Update of leads and makes an HTTP callout to the LeadServices endpoint.
***************************************************************************************************/
    public static void afterUpdate(List<Lead> updatedLeads) {
        String jsonString = serializeLeadsToJson(updatedLeads, true);
        makeHttpCallout(jsonString, 'PATCH');
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     afterDelete
* @Param 1 :        leads: stores the list of leads
* @Description:   This method is called after the Delete of leads and makes an HTTP callout to the LeadServices endpoint.
***************************************************************************************************/
    public static void afterDelete(List<Lead> deletedLeads) {
        String jsonString = serializeLeadsToJson(deletedLeads, false);
        makeHttpCallout(jsonString, 'DELETE');
    }
}
