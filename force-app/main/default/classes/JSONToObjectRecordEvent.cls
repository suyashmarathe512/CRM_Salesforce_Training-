/***************************************************************************************************
* @Author:        CRM Developer
* @className:     JSONToObjectRecordEvent
* @Description:   This class creates a record based on the JSON input.
***************************************************************************************************/
public with sharing class JSONToObjectRecordEvent{
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     JSONEvents
* @Description:   This method dynamically creates a insert a record in respective SObject
                     based on the JSON input.
***************************************************************************************************/
    public void JSONEvents(){
        List<Event> pendingEvents=[SELECT 
                                        Id,Description
                                    FROM 
                                        Event
                                    ];
        Map<Id,SObject> eventToSObject=new Map<Id,SObject>();
        for(Event ev:pendingEvents){
            if(ev.Description!=null && ev.Description.startsWith('{')){
                try{
                    Map<String,Object> jsonMap=(Map<String,Object>)JSON.deserializeUntyped(ev.Description);
                    String strObj=(String)jsonMap.get('ObjectName');
                    SObject obj=Schema.getGlobalDescribe().get(strObj).newSObject();
                    Map<String,Object> map2=(Map<String,Object>)jsonMap.get('JSON');
                    for(String field:map2.keySet()){
                        obj.put(field,map2.get(field));
                    }
                    eventToSObject.put(ev.Id,obj);
                }catch(Exception e){
                    ev.Description='ERROR while preparing: '+e.getMessage();
                }
            }
        }
        if(!eventToSObject.values().isEmpty()){
            Map<Id, Event> eventMap=new Map<Id, Event>(pendingEvents);
            List<Id> eventIds=new List<Id>(eventToSObject.keySet());
            Database.SaveResult[] results=Database.insert(eventToSObject.values(), false);
            for(Integer i=0;i<results.size();i++){
                Id evId=eventIds[i];
                Event ev=eventMap.get(evId);
                if(!results[i].isSuccess()){
                    ev.Description='ERROR on insert: '+results[i].getErrors()[0].getMessage();
                }else{
                    ev.Description='Inserted successfully '+'Record Id: '+results[i].getId();
                }
            }
        }
        if(!pendingEvents.isEmpty()){
            update pendingEvents;
        }
    }
}
