@isTest
public class OpportunityTriggerHandlerTest {
    @isTest
    static void testUpdateOpportunityProductsWithDiscount() {
        Id standardPbId = Test.getStandardPricebookId();
        Pricebook2 stdPb = new Pricebook2(Id = standardPbId, IsActive = true);
        update stdPb;
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;
        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = stdPb.Id,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert stdPbe;
        Opportunity opp = new Opportunity(
            Name = 'Discount Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Pricebook2Id = stdPb.Id,
            Line_Item_Discount__c = 10
        );
        insert opp;
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = stdPbe.Id,
            Quantity = 10,
            UnitPrice = 100
        );
        insert oli;

        Test.startTest();
        opp = [SELECT Id, Line_Item_Discount__c, Sales_Price__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(100, opp.Sales_Price__c, 'Sales_Price__c should be 1000');
        opp.Line_Item_Discount__c = 50;
        update opp;
        Test.stopTest();
        OpportunityLineItem updatedOli = [
            SELECT UnitPrice FROM OpportunityLineItem WHERE Id = :oli.Id
        ];
        System.assertEquals(50, updatedOli.UnitPrice, 'Discount not applied correctly');
        opp = [SELECT Sales_Price__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(50, opp.Sales_Price__c, 'Sales_Price__c should be 500 after discount');
    }
    @isTest
    static void testIncorrectOliValues(){
        Id standardPbId = Test.getStandardPricebookId();
        Pricebook2 stdPb = new Pricebook2(Id = standardPbId, IsActive = true);
        update stdPb;
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;
        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = stdPb.Id,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert stdPbe;
        Opportunity opp = new Opportunity(
            Name = 'Test Opp Update',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Pricebook2Id = stdPb.Id,
            Line_Item_Discount__c = 50
        );
        insert opp;
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = stdPbe.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = stdPbe.Id,
            Quantity = 1,
            UnitPrice = 200
        );
        insert oli2;
        Test.startTest();
        opp.Name = 'Updated Name';
        opp.Line_Item_Discount__c = 10;
        try {
            update opp;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Cannot add the discount'));
        }
        Test.stopTest();
    }
}