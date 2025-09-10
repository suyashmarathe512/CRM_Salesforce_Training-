public with sharing class OpportunityTriggerHandler {
     public static void calculateSalesPrice(List<Opportunity> newOpportunities) {
        Set<Id> oppIdsToUpdate = new Set<Id>();
        List<Logs__c> errorlogs = new List<Logs__c>();
        Decimal totalSalesPrice = 0;
        for(Opportunity opp : newOpportunities) {
            oppIdsToUpdate.add(opp.Id);
        }
        try{
            List<OpportunityLineItem> oliList = [
                    SELECT Id, UnitPrice, OpportunityId, Quantity
                    FROM OpportunityLineItem
                    WHERE OpportunityId IN :oppIdsToUpdate];            
            for(Opportunity opp : newOpportunities) {
                if(!oliList.isEmpty()){
                    for(OpportunityLineItem oli : oliList){ 
                        totalSalesPrice += oli.UnitPrice;
                        opp.Sales_Price__c = totalSalesPrice;
                        }
                    }
                else{
                    opp.Sales_Price__c = 0;
                } 
                }
            }
        catch(Exception e){
            Logs__c log = new Logs__c();
            log.Source_Object__c = 'Opportunity';
            log.Error_Causing_Class_Method__c = 'calculateSalesPrice';
            log.Import_Date__c = Date.today();
            log.Severity__c = 'Mid';
            log.Type__c = 'System exceptions';
            log.Message_Long__c = e.getMessage() + ' ' + e.getCause() + ' ' 
                                + e.getLineNumber() + ' ' + e.getTypeName(); 
            log.Stack_Trace__c = e.getStackTraceString();
            log.Error__c= e.getMessage();
            errorlogs.add(log);
            insert errorlogs;
        }
    }
}
 