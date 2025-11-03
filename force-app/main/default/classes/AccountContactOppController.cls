/***************************************************************************************************
* @Author:        CRM Developer
* @className:     AccountContactOppController
* @Description:   This class provides methods to fetch Accounts, related Contacts and Opportunities,
*                 along with their field definitions and user permissions. It also allows deletion of records.
***************************************************************************************************/
public without sharing class AccountContactOppController {
    
    /***************************************************************************************************
    * @Author:        CRM Developer
    * @className:     AccountDataWrapper
    * @Description:   This class serves as a wrapper to hold Contacts, Opportunities, their field definitions,
    *                 and user permissions for use in Lightning components.
    ***************************************************************************************************/
    public class AccountDataWrapper {
        @AuraEnabled
        public List<Contact> contacts { get; set; }
        @AuraEnabled
        public List<Opportunity> opportunities { get; set; }
        @AuraEnabled
        public Map<String, Boolean> contactPermissions { get; set; }
        @AuraEnabled
        public Map<String, Boolean> oppPermissions { get; set; }
        @AuraEnabled
        public List<ColumnDef> contactColumns { get; set; }
        @AuraEnabled
        public List<ColumnDef> opportunityColumns { get; set; }
    }
    
    /***************************************************************************************************
    * @Author:        CRM Developer
    * @className:     ColumnDef
    * @Description:   This class defines the structure for column definitions used in Lightning data tables,
    *                 including label, field name, type, and editability.
    ***************************************************************************************************/
    public class ColumnDef {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public Boolean editable { get; set; }
        
        /***************************************************************************************************
        * @Author:        CRM Developer
        * @methodName:    ColumnDef
        * @param1:        String label
        * @param2:        String fieldName
        * @param3:        String type
        * @param4:        Boolean editable
        * @Description:   This constructor initializes a ColumnDef instance with the provided label, field name,
        *                 type, and editability.
        ***************************************************************************************************/
        public ColumnDef(String label, String fieldName, String type, Boolean editable) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.editable = editable;
        }
    }
    
    /***************************************************************************************************
    * @Author:        CRM Developer
    * @methodName:    getAccounts
    * @Description:   This method retrieves a list of Accounts with their Id and Name.
    ***************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        try {
            return [SELECT 
                        Id, Name 
                    FROM 
                        Account 
                    ORDER BY 
                        Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /****************************************************************************************************
    * @Author:        CRM Developer
    * @methodName:    getStagePicklistValues
    * @Description:   This method retrieves active picklist values for Opportunity StageName field.
    ****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<String> getStagePicklistValues() {
        List<String> picklistValues = new List<String>();
        try {
            Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry entry : ple) {
                if (entry.isActive()) {
                    picklistValues.add(entry.getValue());
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return picklistValues;
    }
    
    /****************************************************************************************************
    * @Author:        CRM Developer
    * @methodName:    getColumnsFromFieldSet
    * @param1:        String objectName
    * @param2:        String fieldSetName
    * @param3:        Boolean canEdit
    * @param4:        List<String> fieldPaths
    * @Description:   This method retrieves column definitions from a specified field set for a given object.
    ****************************************************************************************************/
    private static List<ColumnDef> getColumnsFromFieldSet(String objectName, String fieldSetName, Boolean canEdit, List<String> fieldPaths) {
        List<ColumnDef> columns = new List<ColumnDef>();
        try {
            Schema.FieldSet fs = Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap().get(fieldSetName);
            if (fs != null) {
                for (Schema.FieldSetMember f : fs.getFields()) {
                    fieldPaths.add(f.getFieldPath());
                    String fieldType = getLightningType(f.getType());
                    columns.add(new ColumnDef(f.getLabel(), f.getFieldPath(), fieldType, canEdit));
                }
            }
        } catch (Exception e) {
            System.debug('Field set not found: ' + fieldSetName);
        }
        return columns;
    }
    
    /****************************************************************************************************
    * @Author:        CRM Developer
    * @methodName:    getRelatedData
    * @param1:        String accountId
    * @Description:   This method retrieves related Contacts and Opportunities for a given Account.
    *                 If accountId is blank, returns all records sorted by CreatedDate DESC.
    ****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static AccountDataWrapper getRelatedData(String accountId) {
        AccountDataWrapper wrapper = new AccountDataWrapper();
        
        // Contacts: default fields and columns if field set empty
        Map<String, Object> contactData = getObjectData(
            'Contact',
            'Contact_Field_Set',
            new List<String>{ 'FirstName', 'LastName', 'Email', 'CreatedDate' },
            new List<ColumnDef>{
                new ColumnDef('First Name', 'FirstName', 'text', false),
                new ColumnDef('Last Name', 'LastName', 'text', false),
                new ColumnDef('Email', 'Email', 'email', false)
            },
            'CreatedDate DESC',
            accountId
        );
        wrapper.contacts = (List<Contact>) contactData.get('records');
        wrapper.contactPermissions = (Map<String, Boolean>) contactData.get('permissions');
        wrapper.contactColumns = (List<ColumnDef>) contactData.get('columns');
        
        // Opportunities
        Map<String, Object> oppData = getObjectData(
            'Opportunity',
            'Opportunity_Field_Set',
            new List<String>{ 'Name', 'StageName', 'CloseDate', 'CreatedDate' },
            new List<ColumnDef>{
                new ColumnDef('Opp Name', 'Name', 'text', false),
                new ColumnDef('Stage', 'StageName', 'text', false),
                new ColumnDef('Close Date', 'CloseDate', 'date-local', false)
            },
            'CreatedDate DESC',
            accountId
        );
        wrapper.opportunities = (List<Opportunity>) oppData.get('records');
        wrapper.oppPermissions = (Map<String, Boolean>) oppData.get('permissions');
        wrapper.opportunityColumns = (List<ColumnDef>) oppData.get('columns');
        
        return wrapper;
    }
    
    /****************************************************************************************************
    * @Author:        CRM Developer
    * @methodName:    getObjectData
    * @param1:        String objectName
    * @param2:        String fieldSetName
    * @param3:        List<String> defaultFields
    * @param4:        List<ColumnDef> defaultColumns
    * @param5:        String orderBy
    * @param6:        String accountId
    * @Description:   This method retrieves records, field definitions, and user permissions for a specified object.
    *                 If accountId is blank, returns all records without filtering.
    ****************************************************************************************************/
    private static Map<String, Object> getObjectData(
        String objectName,
        String fieldSetName,
        List<String> defaultFields,
        List<ColumnDef> defaultColumns,
        String orderBy,
        String accountId
    ) {
        Map<String, Object> result = new Map<String, Object>();
        Map<String, Boolean> permissions = new Map<String, Boolean>{
            'canEdit' => Schema.getGlobalDescribe().get(objectName).getDescribe().isUpdateable(),
            'canDelete' => Schema.getGlobalDescribe().get(objectName).getDescribe().isDeletable()
        };
        result.put('permissions', permissions);
        List<String> fields = new List<String>();
        List<ColumnDef> columns = getColumnsFromFieldSet(objectName, fieldSetName, permissions.get('canEdit'), fields);
        if (fields.isEmpty()) {
            fields.addAll(defaultFields);
            for (ColumnDef col : defaultColumns) {
                col.editable = permissions.get('canEdit');
                columns.add(col);
            }
        }
        if (!fields.contains('Id')) fields.add(0, 'Id');
        String base = 'SELECT ' + String.join(fields, ',') + ' FROM ' + objectName;
        String whereClause = (String.isNotBlank(accountId) ? ' WHERE AccountId = :accountId' : '');
        String soql = base + whereClause + ' ORDER BY ' + orderBy;
        
        result.put('records', Database.query(soql));
        result.put('columns', columns);
        return result;
    }
    
    /****************************************************************************************************
    * @Author:        CRM Developer  
    * @methodName:    deleteSObjectRecord
    * @param1:        String recordId
    * @Description:   This method deletes a record by its Id, handling exceptions for permission issues.
    ****************************************************************************************************/
    @AuraEnabled
    public static void deleteSObjectRecord(String recordId) {
        try {
            Database.delete(Id.valueOf(recordId));
        } catch (DmlException e) {
            throw new AuraHandledException('Delete failed. You do not have permission to delete this record.');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /****************************************************************************************************
    * @Author:        CRM Developer
    * @methodName:    getLightningType
    * @param1:        Schema.DisplayType dt
    * @Description:   This method converts Schema DisplayType to Lightning datatable compatible type.
    ****************************************************************************************************/
    private static String getLightningType(Schema.DisplayType dt) {
        switch on dt {
            when DATE { return 'date-local'; }
            when DATETIME { return 'date'; }
            when CURRENCY { return 'currency'; }
            when EMAIL { return 'email'; }
            when PHONE { return 'phone'; }
            when BOOLEAN { return 'boolean'; }
            when INTEGER, DOUBLE { return 'number'; }
            when else { return 'text'; }
        }
    }
}
