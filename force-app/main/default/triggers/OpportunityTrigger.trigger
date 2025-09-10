trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    //Update for the review.
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
        	OpportunityTriggerHandler.checkDescriptionForClosedWon(Trigger.new);
    	}
    }
}