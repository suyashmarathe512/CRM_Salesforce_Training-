trigger EFTTransactionStatusTrigger on EFT_Transaction_Status__c (after insert, after update) {
        //Updated for the Review.
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        EFTTransactionStatusTriggerHandler.createCasesForDeclinedAVS(Trigger.new);
    }
}