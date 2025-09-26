/***************************************************************************************************
* @Author:        CRM Developer
* @className:     DeleteDuplicateLeadsScheduler
* @Description:   This class schedules the DeleteDuplicateLeads class to run every 3 hours.
***************************************************************************************************/
public with sharing class DeleteDuplicateLeadsScheduler implements Schedulable {
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     execute
* @param1:          SchedulableContext sc
* @Description:   This method is called by the 
                    scheduler to execute the DeleteDuplicateLeads class with batch size 10.
***************************************************************************************************/
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new DeleteDuplicateLeads(), 10);
    }
    //String s = '0 0 */3 * * ?'; 
    //System.schedule('Delete Duplicate Leads Scheduler', s, new DeleteDuplicateLeadsScheduler());
}