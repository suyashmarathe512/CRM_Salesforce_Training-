public class DuplicateConAndOppoInAcc implements Database.Batchable<SObject>, Database.Stateful {
    private Map<Id, Integer> ownerDuplicateCount = new Map<Id, Integer>();
    private String objectType;

    public DuplicateConAndOppoInAcc(String objType) {
        this.objectType = objType;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT 
                                            Id 
                                        FROM 
                                            Account
                                        WHERE
                                            IsPersonAccount = false]);
    }
    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        Set<Id> acctIds = new Set<Id>();
        for (Account a : accounts) {
            acctIds.add(a.Id);
        }
        List<SObject> records;
        if (objectType == 'Contact') {
            records = [SELECT 
                            Id, OwnerId, AccountId, Name, Duplicate__c 
                    FROM 
                        Contact 
                    WHERE
                         AccountId 
                    IN 
                        :acctIds 
                    AND 
                        Name != null];
        } else if (objectType == 'Opportunity') {
            records = [SELECT 
                            Id, OwnerId, AccountId, Name, Duplicate__c 
                    FROM 
                        Opportunity 
                    WHERE 
                        AccountId 
                    IN 
                        :acctIds 
                    AND     
                        Name != null];
        }
        Map<String, List<SObject>> byName = new Map<String, List<SObject>>();
        for (SObject rec : records) {
            String nm = (String) rec.get('Name');
            if (!byName.containsKey(nm)) {
                byName.put(nm, new List<SObject>());
            }
            byName.get(nm).add(rec);
        }
        List<SObject> toUpdate = new List<SObject>();
        for (String nm : byName.keySet()) {
            List<SObject> groupRec = byName.get(nm);
            if (groupRec.size() > 1) {
                Integer recordIndex = 0;
                for (SObject rec : groupRec) {
                    if (recordIndex > 0) {
                        rec.put('Duplicate__c', true);
                        toUpdate.add(rec);
                        Id ownerId = (Id) rec.get('OwnerId');
                        if (ownerDuplicateCount.containsKey(ownerId)) {
                            ownerDuplicateCount.put(ownerId, ownerDuplicateCount.get(ownerId) + 1);
                        } else {
                            ownerDuplicateCount.put(ownerId, 1);
                        }
                    }
                    recordIndex++;
                }
            }
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
    public void finish(Database.BatchableContext bc) {
        if (!ownerDuplicateCount.isEmpty()) {
            Map<Id, User> owners = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id IN :ownerDuplicateCount.keySet()]);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for (Id ownerId : ownerDuplicateCount.keySet()) {
                User u = owners.get(ownerId);
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                m.setToAddresses(new String[] {u.Email});
                m.setSubject('Duplicate ' + objectType + 'found: ' + ownerDuplicateCount.get(ownerId));
                m.setPlainTextBody('Hello ' + u.Name + ',\n\n' +
                    'We found ' + ownerDuplicateCount.get(ownerId) +
                    ' duplicate ' + objectType + '(same Name within an Account). ' +
                    'They are marked Duplicate__c = true.');
                emails.add(m);
            }
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }
    }
}
/*
DuplicateConAndOppoInAcc contactBatch = new DuplicateConAndOppoInAcc('Contact');
Database.executeBatch(contactBatch, 200);  // Batch size of 200

DuplicateConAndOppoInAcc oppBatch = new DuplicateConAndOppoInAcc('Opportunity');
Database.executeBatch(oppBatch, 200);
*/