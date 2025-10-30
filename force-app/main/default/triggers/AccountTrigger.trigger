/***************************************************************************************************
 * @Author:        CRM Developer
 * @className:     AccountTrigger
 * @Description:   Trigger to handle Account before insert and before update events.
 * ***************************************************************************************************/
trigger AccountTrigger on Account (before insert, before update) {
    if (Trigger.isBefore) {
        //AccountTriggerHandler.populateCapitalFromSetting(Trigger.new);
        AccountTriggerHandler.populateCapitalFromMDT(Trigger.new);
    }

}