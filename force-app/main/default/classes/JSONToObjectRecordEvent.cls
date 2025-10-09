/***************************************************************************************************
* @Author:        CRM Developer
* @className:     JSONToObjectRecordEvent
* @Description:   This class creates a record based on the JSON input. Implements Batchable for processing and scheduling.
***************************************************************************************************/
public with sharing class JSONToObjectRecordEvent implements Database.Batchable<SObject>{
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     start
* @param1:          Database.BatchableContext
* @Description:   This method is called by the 
                        batch process to retrieve the events to be processed.
***************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT
                                            Id, Description 
                                        FROM 
                                            Event]);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     execute
* @param1:          Database.BatchableContext
* @param2:          List<Event>
* @Description:   This method is called by the batch process to process the events.
***************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Event> events){
        Map<Id,SObject> eventToSObject=new Map<Id,SObject>();
        for(Event ev:events){
            if(ev.Description!=null && ev.Description.startsWith('{') && ev.Description.endsWith('}')){
                try{
                    Map<String,Object> jsonMap=(Map<String,Object>)JSON.deserializeUntyped(ev.Description);
                    String strObj=(String)jsonMap.get('ObjectName');
                    SObject obj=Schema.getGlobalDescribe().get(strObj).newSObject();
                    Map<String,Object> map2=(Map<String,Object>)jsonMap.get('JSON');
                    for(String field:map2.keySet()){
                        Schema.DescribeFieldResult fieldDescribe = obj.getSObjectType().getDescribe().fields.getMap().get(field).getDescribe();
                        Schema.DisplayType fieldType = fieldDescribe.getType();
                        Object value = map2.get(field);
                        try{
                            if(fieldType == Schema.DisplayType.DATE){
                                obj.put(field, Date.valueOf((String)value));
                            }else if(fieldType == Schema.DisplayType.DATETIME){
                                obj.put(field, DateTime.valueOf((String)value));
                            }else{
                                obj.put(field, value);
                            }
                        }catch(Exception e){
                            ev.Description += ' - ERROR parsing field ' + field + ': ' + e.getMessage();
                        }
                    }
                    eventToSObject.put(ev.Id,obj);
                }catch(Exception e){
                    ev.Description += ' - ERROR while preparing: '+e.getMessage();
                }
            }
        }
        if(!eventToSObject.values().isEmpty()){
            Map<Id, Event> eventMap=new Map<Id, Event>(events);
            List<Id> eventIds=new List<Id>(eventToSObject.keySet());
            Database.SaveResult[] results=Database.insert(eventToSObject.values(), false);
            for(Integer i=0;i<results.size();i++){
                Id evId=eventIds[i];
                Event ev=eventMap.get(evId);
                if(!results[i].isSuccess()){
                    ev.Description += ' - ERROR on insert: '+results[i].getErrors()[0].getMessage();
                }else{
                    ev.Description += ' - Inserted successfully Record Id: '+results[i].getId();
                }
            }
        }
        update events;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     finish
* @param1:          Database.BatchableContext
* @Description:   This method is called by the batch process to finish the batch process.
***************************************************************************************************/
    public void finish(Database.BatchableContext bc){
        System.debug('Batch processing completed.');
    }
}