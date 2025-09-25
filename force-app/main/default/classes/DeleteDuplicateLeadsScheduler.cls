/***************************************************************************************************
* @Author:        CRM Developer
* @className:     DeleteDuplicateLeadsScheduler
* @Description:   This class schedules the DeleteDuplicateLeads class to run every 3 hours.
***************************************************************************************************/
public with sharing class DeleteDuplicateLeadsScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        DeleteDuplicateLeads ddl = new DeleteDuplicateLeads();
        ddl.getDuplicateLeads();
    }
    //String s = '0 0 */3 * * ?'; 
    /*System.schedule('Delete Duplicate Leads Scheduler', s, new DeleteDuplicateLeadsScheduler());
    */
}