trigger AccountTrigger on Account (before insert, before update) {

    // This trigger will run before a record is created or updated
    if (Trigger.isBefore) {
        AccountTriggerHandler.populateCapitalFromSetting(Trigger.new);
        //AccountTriggerHandler.populateCapitalFromMetadata(Trigger.new);
    }

}