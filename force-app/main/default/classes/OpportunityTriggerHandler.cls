public with sharing class OpportunityTriggerHandler {
    private static final Map<Integer, String> MONTHS = new Map<Integer, String>{
        1 => 'JANUARY',
        2 => 'FEBRUARY',
        3 => 'MARCH',
        4 => 'APRIL',
        5 => 'MAY',
        6 => 'JUNE',
        7 => 'JULY',
        8 => 'AUGUST',
        9 => 'SEPTEMBER',
        10 => 'OCTOBER',
        11 => 'NOVEMBER',
        12 => 'DECEMBER'
    };
    public static void createPaymentRecords(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldMap){
        if(!newOpportunities.isEmpty()){
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opp : newOpportunities) {
                oppIds.add(opp.Id);
            }
            Map<Id, Set<String>> existingPayments = new Map<Id, Set<String>>();
            Map<Id, Set<Integer>> existingPaymentsDate = new Map<Id, Set<Integer>>();
            for(Payment__c pay:[SELECT 
                                    Opportunity__c, Name, Payment_Date__c
                                FROM 
                                    Payment__c 
                                WHERE   
                                    Opportunity__c 
                                IN :oppIds]){
                if(!existingPayments.containsKey(pay.Opportunity__c)){
                    existingPayments.put(pay.Opportunity__c, new Set<String>());
                }
                existingPayments.get(pay.Opportunity__c).add(pay.Name);
                if(!existingPaymentsDate.containsKey(pay.Opportunity__c)){
                    existingPaymentsDate.put(pay.Opportunity__c, new Set<Integer>());
                }
                existingPaymentsDate.get(pay.Opportunity__c).add(pay.Payment_Date__c.month());
            }
            List<OpportunityLineItem> oppLineItemsToUpdate=[SELECT 
                                                                Id, Is_Closed__c 
                                                            FROM 
                                                                OpportunityLineItem 
                                                            WHERE 
                                                                OpportunityId 
                                                            IN :oppIds];
            for(OpportunityLineItem oli : oppLineItemsToUpdate){
                oli.Is_Closed__c = true;
            }
            List<Payment__c> paymentsToInsert = new List<Payment__c>();
            for(Opportunity opp : newOpportunities){
                Set<String> existing = existingPayments.get(opp.Id);
                Set<Integer> existingDate = existingPaymentsDate.get(opp.Id);
                Integer dateOfClosing = opp.CloseDate.day();
                if(existing == null) existing = new Set<String>();
                if(existingDate == null) existingDate = new Set<Integer>();
                Integer endMonth = opp.CloseDate.month();
                Date janWithSameDate = Date.newInstance(opp.CloseDate.year(), 1, dateOfClosing);
                for(Integer i = 1; i <= endMonth; i++) {
                    String monthName = MONTHS.get(i);
                    if(!existingDate.contains(i)){
                        Payment__c payment = new Payment__c(
                            Name = monthName,
                            Opportunity__c = opp.Id,
                            Account__c = opp.AccountId,
                            Amount__c = 100
                        );
                        if(i == 1){
                                payment.Payment_Date__c = janWithSameDate;
                        }else{
                            payment.Payment_Date__c = janWithSameDate.addMonths(i-1);
                        }
                        paymentsToInsert.add(payment);
                    }
                }
            }
            if(!oppLineItemsToUpdate.isEmpty()){
                update oppLineItemsToUpdate;
            }
            if(!paymentsToInsert.isEmpty()){
                Database.SaveResult[] results = Database.insert(paymentsToInsert, false);
                List<Opportunity> oppList = [SELECT 
                                                Id, Name 
                                            FROM 
                                                Opportunity 
                                            WHERE 
                                                Id 
                                            IN :oppIds];
                for(Database.SaveResult result : results){
                    if(result.isSuccess()){
                        for(Opportunity opp : oppList){
                            opp.Paid__c = true;
                        }
                        update oppList;
                    }else{
                        for(Database.Error err : result.getErrors()){
                            System.debug(err.getMessage());
                        }
                    }
                }
            }
        }
    }
}