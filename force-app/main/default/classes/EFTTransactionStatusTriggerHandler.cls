public class EFTTransactionStatusTriggerHandler {
    public static void createCasesForDeclinedAVS(List<EFT_Transaction_Status__c> newTransactions){
        System.debug('newTransactions'+newTransactions);
        List<Case> caseList = new List<Case>();
        Id targetRecordTypeId = [SELECT Id, Name 
                                FROM RecordType 
                                WHERE SObjectType = 'case' AND Name = 'assignment'].Id;
        Id queueId = [SELECT Id, Name,Type 
                        FROM Group 
                        WHERE Type = 'Queue' AND Name = 'AVS queue'].Id;
        List<EFT_Transaction_Status__c> txnRecord = [SELECT Id, Method_Name__c, Transaction_Status__c, 
                                SalesHeader__r.Status__c,
                                SalesHeader__r.Name,
                                SalesHeader__r.Bill_To_Customer_Account__r.Id,
                                SalesHeader__r.Bill_To_Customer_Account__r.Name, SalesHeader__r.Bill_To_Customer_Account__r.PersonContactId
                                        FROM EFT_Transaction_Status__c];
        map<Id, EFT_Transaction_Status__c> txnMap = new map<Id, EFT_Transaction_Status__c>();
        for(EFT_Transaction_Status__c txn : txnRecord){
            txnMap.put(txn.Id, txn);
        }
        Case c = new Case();
        for(EFT_Transaction_Status__c txn : newTransactions){
            if(txn.Method_Name__c == 'Credit Card Address VERIFY' &&
               txn.Transaction_Status__c == 'Declined' && txnMap.get(txn.Id).SalesHeader__r.Status__c == 'Open'){
                c.AccountId = txnMap.get(txn.Id).SalesHeader__r.Bill_To_Customer_Account__r.Id;
                c.ContactId = txnMap.get(txn.Id).SalesHeader__r.Bill_To_Customer_Account__r.PersonContactId;
                c.RecordTypeId = targetRecordTypeId;
                c.origin = 'Internal';
                c.Reason = 'Address Did Not Verify';
                c.Status = 'New';
                c.Priority = 'High';
                c.Type = 'Address Did Not Verify';
                c.Subject = txnMap.get(txn.Id).SalesHeader__r.Bill_To_Customer_Account__r.Name + ' ' + c.Type;
                c.OwnerId = queueId;
                c.Open_Sales_Order__c  = txnMap.get(txn.Id).SalesHeader__r.Id;
                c.Transaction_Status__c = txn.Transaction_Status__c;
                c.Sales_Order_Number__c = txnMap.get(txn.Id).SalesHeader__r.Name;
                c.Order_Date__c = txn.Transaction_Date__c;
                caseList.add(c);
            }
        }
        system.debug('CASE lIST: '+ caseList);
        if(!caseList.isEmpty()){
            Database.SaveResult[] results=  Database.insert(caseList, false);
            system.debug(results);
        }
    }
}