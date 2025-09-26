/***************************************************************************************************
* @Author:        CRM Developer
* @className:     DeleteDuplicateLeads
* @Description:   This class deletes the duplicate leads 
                    based on the custom label criteria across all leads.
***************************************************************************************************/
public with sharing class DeleteDuplicateLeads implements Database.Batchable<sObject>,Database.Stateful{
    private Set<String> uniqueValues=new Set<String>();
    private String criteria=System.Label.Leads_Delete_Criteria;
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     start
* @Parameters:     Database.BatchableContext bc
* @Description:   This method is called by the batch process to retrieve the leads to be processed.
***************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT 
                                            Id, Name, Email 
                                        FROM 
                                            Lead
                                        WHERE 
                                            Email != null
                                        OR 
                                        Name != null]);
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     execute
* @Param1:          Database.BatchableContext bc
* @param2 :         List<sObject> scope     
* @Description:   This method is called by the batch process to process the leads.
***************************************************************************************************/
    public void execute(Database.BatchableContext bc,List<Lead> leads){
        List<Lead> toDelete=new List<Lead>();
        for(Lead l : leads){
            String value=(criteria == 'Email') ? l.Email:l.Name;
            if(value != null){
                if(uniqueValues.contains(value)){
                    toDelete.add(l);
                }else{
                    uniqueValues.add(value);
                }
            }
        }
        if(!toDelete.isEmpty()){
            Database.delete(toDelete,false);
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     finish
* @Param1:          Database.BatchableContext bc    
* @Description:   This method finish the batch process.
***************************************************************************************************/
    public void finish(Database.BatchableContext bc){
        System.debug('Batch processing completed. Total unique values: '+uniqueValues.size());
    }
}
