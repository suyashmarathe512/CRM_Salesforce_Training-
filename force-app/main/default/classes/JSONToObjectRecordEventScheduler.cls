/***************************************************************************************************
* @Author:        CRM Developer
* @className:     JSONToObjectRecordEventScheduler
* @Description:   This is the scheduler for the Class JSONToObjectRecordEvent
***************************************************************************************************/
public with sharing class JSONToObjectRecordEventScheduler implements Schedulable {
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     execute
* @Description:   This method is called by the scheduler to process the events every hour.
***************************************************************************************************/   
    public void execute(SchedulableContext sc) {
        JSONToObjectRecordEvent event = new JSONToObjectRecordEvent();
        event.JSONEvents();
    }
}

//String s = '0 0 */1 * * ?'; 
//System.schedule('JSON to Record event', s, new JSONToObjectRecordEventScheduler());
