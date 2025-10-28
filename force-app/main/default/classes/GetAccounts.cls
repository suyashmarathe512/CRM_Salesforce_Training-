/***************************************************************************************************
* @Author:        CRM Developer
* @className:     GetAccounts
* @Description:   This class fetches a list of Account records from Salesforce.
***************************************************************************************************/
public with sharing class GetAccounts {
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     Row
* @Description:   This class represents a single row of Account data.
***************************************************************************************************/
    public class Row {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Phone;
        @AuraEnabled public String Industry;
        @AuraEnabled public String Rating;
        @AuraEnabled public Decimal AnnualRevenue;
        @AuraEnabled public String OwnerName;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @className:     Result
* @Description:   This class represents the result of a query.
***************************************************************************************************/
    public class Result {
        @AuraEnabled public List<Row> rows;
        @AuraEnabled public Integer totalCount;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @MethodName:     getAccounts
* @Param1:        limitSize for pagination
* @Param2:        offsetSize for pagination 
* @Param3:        sortBy for sorting based on field
* @Param4:        sortDirection for sorting in ASC/DESC order
* @Description:   This class fetches a list of Account records from Salesforce.
***************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Result getAccounts(Integer limitSize, Integer offsetSize, String sortBy, String sortDirection) {
        String orderField = String.isBlank(sortBy) ? 'Name' : sortBy;
        String dir = (String.valueOf(sortDirection).toLowerCase() == 'desc') ? 'DESC' : 'ASC';
        String orderExpr = (orderField == 'OwnerName') ? 'Owner.Name ' + dir : orderField + ' ' + dir;
        Integer total = [SELECT 
                            COUNT() 
                         FROM 
                            Account];
        List<Account> page = Database.query(
            'SELECT Id, Name, Phone, Industry, Rating, AnnualRevenue, Owner.Name ' +
            'FROM Account ' +
            'ORDER BY ' + orderExpr + ' NULLS LAST ' +
            'LIMIT :limitSize OFFSET :offsetSize'
        );
        List<Row> rows = new List<Row>();
        for (Account a : page) {
            Row r = new Row();
            r.Id = a.Id;
            r.Name = a.Name;
            r.Phone = a.Phone;
            r.Industry = a.Industry;
            r.Rating = a.Rating;
            r.AnnualRevenue = a.AnnualRevenue;
            r.OwnerName = (a.Owner != null) ? a.Owner.Name : null;
            rows.add(r);
        }
        Result res = new Result();
        res.rows = rows;
        res.totalCount = total;
        return res;
    }
}