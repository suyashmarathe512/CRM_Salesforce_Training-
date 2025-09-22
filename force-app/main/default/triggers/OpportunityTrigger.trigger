trigger OpportunityTrigger on Opportunity (after Update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        for(Opportunity opp : Trigger.new){
            if(opp.StageName == 'Closed Won' && opp.Paid__c == false){
                OpportunityTriggerHandler.createPaymentRecords(Trigger.new, Trigger.oldMap);
            }
        }
    }
}
