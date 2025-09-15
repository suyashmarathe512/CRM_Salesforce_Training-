/***************************************************************************************************
* @Author:        CRM Developer
* @className:     JSONToObjectRecordEvent
* @Description:   This class creates a record based on the JSON input.
***************************************************************************************************/
public class JSONToObjectRecordEvent{
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     processEvent
* @Description:   This method dynamically creates a insert a record in respective SObject
                     based on the JSON input.
***************************************************************************************************/
    public void processEvents() {
        List<Event> pendingEvents = [
            SELECT 
                Id, Location, Description
            FROM 
                Event
            WHERE 
                Location != null
            ];
        Map<Id, SObject> eventToSObject = new Map<Id, SObject>();
        for (Event ev : pendingEvents) {
            if(ev.Description != null && ev.Description.startsWith('{')){
                try {
                    String objectName = ev.Location;
                    Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
                    if (sObjType == null) {
                        ev.Description = 'ERROR: Object ' + objectName + ' does not exist';
                        continue;
                    }
                    Type t = Type.forName(objectName);
                    if (t == null) {
                        ev.Description = 'ERROR: Type ' + objectName + ' does not exist';
                        continue;
                    }
                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(ev.Description);
                    String dataJson = JSON.serialize(jsonMap);
                    SObject sobj = (SObject) JSON.deserialize(dataJson, t);
                    eventToSObject.put(ev.Id, sobj);
                } catch (Exception e) {
                    ev.Description = 'ERROR while preparing: ' + e.getMessage();
                }
            }
        }
        if (!eventToSObject.values().isEmpty()) {
            Map<Id, Event> eventMap = new Map<Id, Event>(pendingEvents);
            List<Id> eventIds = new List<Id>(eventToSObject.keySet());
            Database.SaveResult[] results = Database.insert(eventToSObject.values(), false);
            for (Integer i = 0; i < results.size(); i++) {
                Id evId = eventIds[i];
                Event ev = eventMap.get(evId);
                if (!results[i].isSuccess()) {
                    ev.Description = 'ERROR on insert: ' + results[i].getErrors()[0].getMessage();
                } else {
                    ev.Description = 'Inserted successfully';
                }
            }
        }

        if (!pendingEvents.isEmpty()) {
            update pendingEvents;
        }
    }
}
