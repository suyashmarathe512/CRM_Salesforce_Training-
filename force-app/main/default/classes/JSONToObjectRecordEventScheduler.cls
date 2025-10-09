/***************************************************************************************************
* @Author:        CRM Developer
* @className:     JSONToObjectRecordEventScheduler
* @Description:   This is the scheduler for the Class JSONToObjectRecordEvent.
                    Reschedules itself every minute.
***************************************************************************************************/
public with sharing class JSONToObjectRecordEventScheduler implements Schedulable {
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     execute
* @Description:   This method is called by the scheduler 
                    to process the events every minute via batch.
***************************************************************************************************/   
    public void execute(SchedulableContext sc){
        Database.executeBatch(new JSONToObjectRecordEvent(), 10);
        Datetime now = Datetime.now();
        Datetime nextRun = now.addMinutes(1);
        String seconds = '0';
        String minutes = String.valueOf(nextRun.minute());
        String hours = String.valueOf(nextRun.hour());
        String cronExp = seconds + ' ' + minutes + ' ' + hours  + ' * * ?';   
        System.abortJob(sc.getTriggerId());
        System.schedule('JSON to Record event', cronExp, new JSONToObjectRecordEventScheduler());
    }
}

//String s = '0 0 * * * ? *'; System.schedule('JSON to Record event', s, new JSONToObjectRecordEventScheduler());
