public with sharing class CaseTriggerHandler {
    private static Boolean isNewlyClosed(Case newCase, Case oldCase) {
        return newCase.Status == 'Closed' && oldCase.Status != 'Closed';
    }
    public static void updateTasks(List<Case> newCases, Map<Id, Case> oldMap){
        List<Task> tasksToUpdate = new List<Task>();
        Map<Id, Contact> highPriorityContactsToUpdate = new Map<Id, Contact>();
        Set<Id> contactsClosedToday = new Set<Id>();
        List<Task> tasksToInsert = new List<Task>();
        Set<Id> closedCaseIds = new Set<Id>();
        List<Case> newlyClosedCases = new List<Case>();
        for(Case newCase : newCases){
            Case oldCase = oldMap.get(newCase.Id);
            if(isNewlyClosed(newCase, oldCase)){
                newlyClosedCases.add(newCase);
                closedCaseIds.add(newCase.Id);
                if(newCase.Priority == 'High' && newCase.ContactId != null){
                    highPriorityContactsToUpdate.put(newCase.ContactId, new Contact(
                        Id = newCase.ContactId,
                        EmailBouncedReason = 'High Priority Customer Case Closed'
                    ));
                    contactsClosedToday.add(newCase.ContactId);
                }
                Task followUpTask = new Task(
                    Subject = 'Follow-up with customer',
                    Status = 'Not Started',
                    ActivityDate = Date.today().addDays(7),
                    WhatId = newCase.Id,
                    OwnerId = newCase.OwnerId
                );
                tasksToInsert.add(followUpTask);
            }
        }
        tasksToUpdate = [SELECT 
                            Id 
                        FROM 
                            Task 
                        WHERE 
                            WhatId 
                        IN 
                            :closedCaseIds];
        for(Task t : tasksToUpdate){
            t.Status = 'Completed';
        }
        List<AggregateResult> aggResults = [SELECT 
                                                ContactId, COUNT(Id) cnt 
                                            FROM 
                                                Case 
                                            WHERE 
                                                ContactId 
                                            IN 
                                                :contactsClosedToday 
                                            AND 
                                                Status = 'Closed' 
                                            AND 
                                                DAY_ONLY(ClosedDate) = :Date.today() 
                                            GROUP BY   
                                                ContactId];
        Set<Id> contactsNeedingReview = new Set<Id>();
        for(AggregateResult ar : aggResults){
            Id cid = (Id)ar.get('ContactId');
            Integer cnt = (Integer)ar.get('cnt');
            if(cnt > 5){
                contactsNeedingReview.add(cid);
            }
        }
        if(!tasksToInsert.isEmpty()){
            insert tasksToInsert;
        }
        if(!tasksToUpdate.isEmpty()){
            update tasksToUpdate;
        }
        if(!highPriorityContactsToUpdate.isEmpty()){
            update highPriorityContactsToUpdate.values();
        }
        for(Case c : newlyClosedCases){
            if(c.ContactId != null && contactsNeedingReview.contains(c.ContactId)){
                Task reviewTask = new Task(
                    Subject = 'Review frequent issues with this Contact',
                    Status = 'Not Started',
                    ActivityDate = Date.today().addDays(1),
                    WhoId = c.ContactId,
                    OwnerId = c.OwnerId
                );
                tasksToInsert.add(reviewTask);
            }
        }
        if(!tasksToInsert.isEmpty()){
            insert tasksToInsert;
        }
    }
}