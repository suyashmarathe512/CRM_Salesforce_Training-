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
        System.enqueueJob(new UpdateFirst50Accounts());
        System.debug('First 50 accounts updated');
        System.enqueueJob(new Update51To100Accounts());
        System.debug('51-100 accounts updated');
        System.enqueueJob(new Update101To150Accounts());
        System.debug('101-150 accounts updated');
    }
}
