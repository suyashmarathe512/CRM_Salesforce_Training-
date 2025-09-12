trigger OpportunityTrigger on Opportunity (before insert , before update, after update) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            OpportunityTriggerHandler.calculateSalesPrice(Trigger.new);
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate) {
            OpportunityTriggerHandler.updateOpportunityProductsWithDiscount(Trigger.new, Trigger.oldMap);
    }
}
