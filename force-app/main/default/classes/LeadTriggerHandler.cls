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
* @Param 2 :        isUpdate: stores the boolean value for update
* @Description:   This method serializes the list of leads to JSON format.
***************************************************************************************************/
    private static String serializeLeadsToJson(List<Lead> leads, Boolean isUpdate) {
        List<Wrapper> wrappers = new List<Wrapper>();
        for (Lead lead : leads) {
            Wrapper w = new Wrapper();
            w.FirstName = lead.FirstName;
            w.LastName = lead.LastName;
            if (isUpdate) {
                w.NewEmail = lead.Email;
                w.NewPhone = lead.Phone;
            } else {
                w.Email = lead.Email;
                w.Phone = lead.Phone;
            }
            wrappers.add(w);
        }
        return JSON.serialize(wrappers);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     afterInsert
* @Param 1 :        leads: stores the list of leads
* @Description:   This method is called after the insert of leads and makes an HTTP callout to the LeadServices endpoint.
***************************************************************************************************/
    public static void afterInsert(List<Lead> newLeads) {
        String jsonString = serializeLeadsToJson(newLeads, false);
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
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     Wrapper
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
}
