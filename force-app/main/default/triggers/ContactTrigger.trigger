trigger ContactTrigger on Contact (before insert,  before update, after insert, after update) {
    //Update for the review.
    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            ContactTriggerHandler.checkDuplicates(Trigger.new);
        }
    }
}