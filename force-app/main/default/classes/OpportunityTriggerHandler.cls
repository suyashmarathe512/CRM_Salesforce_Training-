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
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity opp : newOpportunities) {
                oppIds.add(opp.Id);
            }
            Map<Id, Map<Integer, Set<Integer>>> existingPaymentMonths = new Map<Id, Map<Integer, Set<Integer>>>();
            for(Payment__c pay : [SELECT
                                        Opportunity__c, Name, Payment_Date__c
                                FROM
                                    Payment__c
                                WHERE
                                    Opportunity__c
                                IN
                                    :oppIds]){
                if(!existingPaymentMonths.containsKey(pay.Opportunity__c)){
                    existingPaymentMonths.put(pay.Opportunity__c, new Map<Integer, Set<Integer>>());
                }
            Map<Integer, Set<Integer>> yearMonths = existingPaymentMonths.get(pay.Opportunity__c);
            Integer year = pay.Payment_Date__c.year();
            if(!yearMonths.containsKey(year)){
                yearMonths.put(year, new Set<Integer>());
            }
            yearMonths.get(year).add(pay.Payment_Date__c.month());
            }
            List<OpportunityLineItem> oppLineItemsToUpdate = [SELECT 
                                                                    Id, Is_Closed__c 
                                                                FROM 
                                                                    OpportunityLineItem 
                                                                WHERE 
                                                                    OpportunityId 
                                                                IN 
                                                                    :oppIds];
            for(OpportunityLineItem oli : oppLineItemsToUpdate){
                oli.Is_Closed__c = true;
            }
            List<Payment__c> paymentsToInsert = new List<Payment__c>();
            for(Opportunity opp : newOpportunities){
                Map<Integer, Set<Integer>> yearMonths = existingPaymentMonths.get(opp.Id);
                Set<Integer> existingMonths = (yearMonths != null && yearMonths.containsKey(opp.CloseDate.year())) ? yearMonths.get(opp.CloseDate.year()) : new Set<Integer>();
                Integer dateOfClosing = opp.CloseDate.day();
                Integer endMonth = opp.CloseDate.month();
                Date janWithSameDate = Date.newInstance(opp.CloseDate.year(), 1, dateOfClosing);
                for(Integer i = 1; i <= endMonth; i++) {
                    if(!existingMonths.contains(i)){
                        String monthName = MONTHS.get(i);
                        Payment__c payment = new Payment__c(
                            Name = monthName,
                            Opportunity__c = opp.Id,
                            Account__c = opp.AccountId,
                            Amount__c = 100,
                            Payment_Date__c = janWithSameDate.addMonths(i-1)
                        );
                        paymentsToInsert.add(payment);
                    }
                }
            }
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            if(!oppLineItemsToUpdate.isEmpty()){
                update oppLineItemsToUpdate;
            }
            if(!paymentsToInsert.isEmpty()){
                results = Database.insert(paymentsToInsert, false);
            }
            if(!results.isEmpty()){
                Map<Id, Opportunity> oppsToUpdateMap = new Map<Id, Opportunity>();
                Integer paymentIndex = 0;
                for(Database.SaveResult result : results){
                    if(result.isSuccess() && paymentIndex < paymentsToInsert.size()){
                        Id oppId = paymentsToInsert[paymentIndex].Opportunity__c;
                        oppsToUpdateMap.put(oppId, new Opportunity(Id = oppId, Paid__c = true));
                    }
                    paymentIndex++;
                }
                if(!oppsToUpdateMap.isEmpty()){
                    update oppsToUpdateMap.values();
                }
            }
    }
}