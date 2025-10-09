trigger LeadTrigger on Lead (after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LeadTriggerHandler.afterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            LeadTriggerHandler.afterUpdate(Trigger.new);
        } else if (Trigger.isDelete) {
            LeadTriggerHandler.afterDelete(Trigger.old);
        }
    }
}
