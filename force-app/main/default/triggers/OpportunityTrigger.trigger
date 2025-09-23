trigger OpportunityTrigger on Opportunity (after Update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Opportunity> qualifyingOpportunities = new List<Opportunity>();
        for(Opportunity opp : Trigger.new){
            if(opp.StageName == 'Closed Won' && opp.Paid__c == false){
                qualifyingOpportunities.add(opp);
            }
        }
        if(!qualifyingOpportunities.isEmpty()){
            OpportunityTriggerHandler.createPaymentRecords(qualifyingOpportunities, Trigger.oldMap);
        }
    }
}
