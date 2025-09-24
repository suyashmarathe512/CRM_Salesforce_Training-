/***************************************************************************************************
* @Author:        CRM Developer
* @className:     AccountPrefixEnqueuer
* @Description:   This class enqueues all the queueable jobs for updating account names.
***************************************************************************************************/
public with sharing class AccountPrefixEnqueuer {
    public static void enqueueAllJobs() {
        System.enqueueJob(new UpdateFirst50Accounts());
        System.enqueueJob(new Update51To100Accounts());
        System.enqueueJob(new Update101To150Accounts());
    }
}
