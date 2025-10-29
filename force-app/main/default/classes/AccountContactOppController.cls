public without sharing class AccountContactOppController {
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
    public class ColumnDef {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public Boolean editable { get; set; }
        public ColumnDef(String label, String fieldName, String type, Boolean editable) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.editable = editable;
        }
    }
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
    @AuraEnabled(cacheable=true)
    public static AccountDataWrapper getRelatedData(String accountId) {
        AccountDataWrapper wrapper = new AccountDataWrapper();
        Map<String, Object> contactData = getObjectData('Contact', 'Contact_Field_Set', new List<String>{'FirstName', 'LastName', 'Email'}, new List<ColumnDef>{
            new ColumnDef('First Name', 'FirstName', 'text', false),
            new ColumnDef('Last Name', 'LastName', 'text', false),
            new ColumnDef('Email', 'Email', 'email', false)
        }, 'LastName', accountId);
        wrapper.contacts = (List<Contact>) contactData.get('records');
        wrapper.contactPermissions = (Map<String, Boolean>) contactData.get('permissions');
        wrapper.contactColumns = (List<ColumnDef>) contactData.get('columns');
        Map<String, Object> oppData = getObjectData('Opportunity', 'Opportunity_Field_Set', new List<String>{'Name', 'StageName', 'CloseDate'}, new List<ColumnDef>{
            new ColumnDef('Opp Name', 'Name', 'text', false),
            new ColumnDef('Stage', 'StageName', 'text', false),
            new ColumnDef('Close Date', 'CloseDate', 'date-local', false)
        }, 'CloseDate DESC', accountId);
        wrapper.opportunities = (List<Opportunity>) oppData.get('records');
        wrapper.oppPermissions = (Map<String, Boolean>) oppData.get('permissions');
        wrapper.opportunityColumns = (List<ColumnDef>) oppData.get('columns');

        return wrapper;
    }
    private static Map<String, Object> getObjectData(String objectName, String fieldSetName, List<String> defaultFields, List<ColumnDef> defaultColumns, String orderBy, String accountId) {
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
        String query = 'SELECT ' + String.join(fields, ',') + ' FROM ' + objectName + ' WHERE AccountId = :accountId ORDER BY ' + orderBy;
        result.put('records', Database.query(query));
        result.put('columns', columns);
        return result;
    }
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
