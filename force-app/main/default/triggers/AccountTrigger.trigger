trigger AccountTrigger on Account (before insert, before update) {
    if (Trigger.isBefore) {
        TriggerSetting__c settings = TriggerSetting__c.getInstance();
        if (settings == null || !settings.Account_Trigger_Active__c) {
            return;
        }
        AccountTriggerHandler.populateCapitalFromSetting(Trigger.new);
        //AccountTriggerHandler.populateCapitalFromMetadata(Trigger.new);
    }

}
