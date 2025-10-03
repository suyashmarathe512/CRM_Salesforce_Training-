@isTest
public class CaseTriggerHandlerTest {
    @TestSetup
    static void setup() {
        Contact contact = new Contact(LastName = 'Test Contact');
        insert contact;
    }
    @isTest
    static void testCloseCaseCreatesFollowUpTask() {
        Contact contact = [SELECT 
                                Id 
                        FROM 
                            Contact 
                        WHERE 
                            LastName = 'Test Contact' 
                        LIMIT 1];
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Priority = 'Normal',
            ContactId = contact.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert testCase;
        Test.startTest();
        testCase.Status = 'Closed';
        update testCase;
        Test.stopTest();
        List<Task> followUpTasks = [SELECT 
                                        Id, Subject, Status, WhatId 
                                    FROM 
                                        Task 
                                    WHERE 
                                        WhatId = :testCase.Id 
                                    AND 
                                        Subject = 'Follow-up with customer'];
        System.assertEquals(1, followUpTasks.size(), 'Follow-up task should be created');
        System.assertEquals('Not Started', followUpTasks[0].Status, 'Follow-up task should be Not Started');
    }
    @isTest
    static void testCloseCaseWithOpenTasksMarksTasksCompleted() {
        Contact contact = [SELECT 
                                Id 
                            FROM 
                                Contact 
                            WHERE 
                                LastName = 'Test Contact' 
                            LIMIT 1];

        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Priority = 'Normal',
            ContactId = contact.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert testCase;
        List<Task> tasks = new List<Task>();
        for(Integer i = 0; i < 3; i++) {
            tasks.add(new Task(
                Subject = 'Open Task ' + i,
                Status = 'Not Started',
                WhatId = testCase.Id,
                OwnerId = UserInfo.getUserId()
            ));
        }
        insert tasks;
        Test.startTest();
        testCase.Status = 'Closed';
        update testCase;
        Test.stopTest();
        List<Task> updatedTasks = [SELECT 
                                        Id, Status 
                                    FROM 
                                        Task 
                                    WHERE 
                                        WhatId = :testCase.Id];
        for(Task t : updatedTasks) {
            System.assertEquals('Completed', t.Status, 'Task status should be Completed');
        }
    }
    @isTest
    static void testCloseHighPriorityCaseUpdatesContact() {
        Contact contact = [SELECT 
                                Id 
                            FROM 
                                Contact 
                            WHERE 
                                LastName = 'Test Contact' 
                            LIMIT 
                                1];

        Case testCase = new Case(
            Subject = 'High Priority Case',
            Status = 'New',
            Priority = 'High',
            ContactId = contact.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert testCase;
        Test.startTest();
        testCase.Status = 'Closed';
        update testCase;
        Test.stopTest();
        Contact updatedContact = [SELECT 
                                    Id, EmailBouncedReason 
                                FROM 
                                    Contact 
                                WHERE 
                                    Id = :contact.Id];
        System.assertEquals('High Priority Customer Case Closed', updatedContact.EmailBouncedReason, 'Contact should be updated with EmailBouncedReason');
    }
    @isTest
    static void testCloseMultipleCasesCreatesReviewTask() {
        Contact contact = [SELECT
                                Id 
                            FROM 
                                Contact 
                            WHERE 
                                LastName = 'Test Contact' 
                            LIMIT 1];
        List<Case> cases = new List<Case>();
        for(Integer i = 0; i < 5; i++) {
            cases.add(new Case(
                Subject = 'Closed Case ' + i,
                Status = 'Closed',
                Priority = 'High',
                ContactId = contact.Id,
                OwnerId = UserInfo.getUserId()
            ));
        }
        insert cases;
        Case newCase = new Case(
            Subject = 'New Case to Close',
            Status = 'New',
            Priority = 'High',
            ContactId = contact.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert newCase;
        Test.startTest();
        newCase.Status = 'Closed';
        update newCase;
        Test.stopTest();
        List<Task> reviewTasks = [SELECT 
                                        Id, Subject, WhoId 
                                    FROM 
                                        Task 
                                    WHERE 
                                        WhoId = :contact.Id 
                                    AND 
                                        Subject = 'Review frequent issues with this Contact'];
        System.assertEquals(1, reviewTasks.size(), 'Review task should be created for contact with >=5 closed cases');
    }

    @isTest
    static void testCloseCasesDifferentPrioritiesRuleAppliesOnlyToHighPriority() {
        Contact contact = [SELECT 
                                Id 
                            FROM 
                                Contact 
                            WHERE 
                                LastName = 'Test Contact' 
                            LIMIT 1];
        Case highPriorityCase = new Case(
            Subject = 'High Priority Case',
            Status = 'New',
            Priority = 'High',
            ContactId = contact.Id,
            OwnerId = UserInfo.getUserId()
        );
        Case normalPriorityCase = new Case(
            Subject = 'Normal Priority Case',
            Status = 'New',
            Priority = 'Normal',
            ContactId = contact.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert new List<Case>{highPriorityCase, normalPriorityCase};
        Test.startTest();
        highPriorityCase.Status = 'Closed';
        normalPriorityCase.Status = 'Closed';
        update new List<Case>{highPriorityCase, normalPriorityCase};
        Test.stopTest();
        Contact updatedContact = [SELECT 
                                    Id, EmailBouncedReason 
                                FROM 
                                    Contact 
                                WHERE 
                                    Id = :contact.Id];
        System.assertEquals('High Priority Customer Case Closed', updatedContact.EmailBouncedReason, 'Contact should be updated only for high priority case');
    }
}
