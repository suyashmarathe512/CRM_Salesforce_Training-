/*************************************************************************************************
* @TriggerName:       CaseTrigger
*@Event:             After Update
*Description:         Calling the Trigger Handler in After Update event.
***************************************************************************************************/
trigger CaseTrigger on Case (After update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        CaseTriggerHandler.updateTasks(Trigger.new, Trigger.oldMap);
    }
}