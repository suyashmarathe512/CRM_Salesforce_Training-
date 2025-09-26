/***************************************************************************************************
* @Author:        CRM Developer
* @className:     AccountPrefixEnqueuer
* @Description:   This class enqueues all the queueable jobs for updating account names.
***************************************************************************************************/
public with sharing class AccountPrefixEnqueuer {
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     enqueueAllJobs
* @Description:   This method enqueues all the queueable jobs for updating account names.
***************************************************************************************************/
    public static void enqueueAllJobs() {
        System.enqueueJob(new AccountPrefixUpdater(0));
        System.debug('First 50 accounts job enqueued');
        System.enqueueJob(new AccountPrefixUpdater(50));
        System.debug('51-100 accounts job enqueued');
        System.enqueueJob(new AccountPrefixUpdater(100));
        System.debug('101-150 accounts job enqueued');
    }
}
