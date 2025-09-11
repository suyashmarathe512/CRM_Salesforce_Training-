public with sharing class AddPrefixToAccountNameQueueable implements Queueable {
    public void execute(QueueableContext context) {
        List<Account> accountsToUpdate = [SELECT Id, Name FROM Account];
        for (Account acc : accountsToUpdate) {
            acc.Name = 'CTI - ' + acc.Name;
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
// ID jobID = System.enqueueJob(new AddPrefixToAccountNameQueueable());
