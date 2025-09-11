public with sharing class OpportunityTriggerHandler {
     public static void calculateSalesPrice(List<Opportunity> newOpportunities) {
        Set<Id> oppIdsToUpdate = new Set<Id>();
        List<Logs__c> errorlogs = new List<Logs__c>();
        Decimal totalSalesPrice = 0;
        for(Opportunity opp : newOpportunities) {
            oppIdsToUpdate.add(opp.Id);
        }            
        List<OpportunityLineItem> oliList = [
                    SELECT 
                        Id, UnitPrice, OpportunityId, Quantity
                    FROM 
                        OpportunityLineItem
                    WHERE 
                        OpportunityId 
                    IN :oppIdsToUpdate];            
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
    public static void updateOpportunityProductsWithDiscount(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        Set<Id> oppIdsToUpdate = new Set<Id>();
        List<Logs__c> errorlogs = new List<Logs__c>();
        for(Opportunity opp : newOpps) {
            if(opp.Line_Item_Discount__c != oldMap.get(opp.Id).Line_Item_Discount__c) {
                oppIdsToUpdate.add(opp.Id);
            }
        }
        if(!oppIdsToUpdate.isEmpty()) {
            List<OpportunityLineItem> oliList = [
                            SELECT 
                                Id, UnitPrice, OpportunityId, Quantity,ListPrice,Discount
                            FROM 
                                OpportunityLineItem
                            WHERE 
                                OpportunityId 
                            IN :oppIdsToUpdate];
            Map<Id, Decimal> oppDiscountMap = new Map<Id, Decimal>();
            for (Opportunity opp : newOpps) {
                if (oppIdsToUpdate.contains(opp.Id)) {
                    oppDiscountMap.put(opp.Id, opp.Line_Item_Discount__c);
                }
            }
            for (OpportunityLineItem oli : oliList) {
                Decimal discount = oppDiscountMap.get(oli.OpportunityId);
                oli.Discount = discount;
                if (discount != null){
                    oli.UnitPrice = oli.ListPrice * (1 - discount / 100);
                } 
            }
            Database.SaveResult[] results = Database.update(oliList,false);
            for (Database.SaveResult result : results) {
                Integer i = results.indexOf(result);
                if (!result.isSuccess()) {
                    Logs__c log = new Logs__c();
                    Database.Error e = result.getErrors()[0];
                    if(i!= null){
                        log.Opportunity_Product__c = results.get(i).getId();
                    }
                    log.Source_Object__c = 'Opportunity Product';
                    log.Import_Date__c = Date.today();
                    log.Severity__c = 'Mid';
                    log.Error__c= e.getMessage();
                    log.Message_Long__c = e.getFields() + ' ' + e.getStatusCode()+ ' ' + e.getMessage();
                    errorlogs.add(log);
                }
            }
            if(!errorlogs.isEmpty()){
                insert errorlogs;
            }
        }
    }
}
