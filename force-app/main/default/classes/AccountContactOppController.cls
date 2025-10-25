/*
 * This Apex class fetches Account, Contact, and Opportunity data.
 * 'without sharing' makes sure we get ALL records, ignoring user permissions *for queries*.
 * Delete operations will still respect user permissions.
 */
public without sharing class AccountContactOppController {

    // This is a "wrapper" class. It's just a container to send
    // multiple pieces of data (lists, permissions) back to the LWC in one single call.
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

    // A helper class to define our datatable columns from Apex.
    public class ColumnDef {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public Boolean editable { get; set; }

        // --- FIX 1: ADDED CONSTRUCTOR ---
        // This constructor was missing. It allows us to write
        // new ColumnDef('Label', 'ApiName', 'type', true);
        public ColumnDef(String label, String fieldName, String type, Boolean editable) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.editable = editable;
        }
    }

    /**
     * @description Fetches all Accounts for the dropdown.
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        try {
            return [SELECT Id, Name FROM Account ORDER BY Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Fetches Contacts, Opps, Field Set columns, and user permissions.
     */
    @AuraEnabled(cacheable=true)
    public static AccountDataWrapper getRelatedData(String accountId) {
        AccountDataWrapper wrapper = new AccountDataWrapper();

        // 1. Check user's permissions for Edit/Delete on the objects
        wrapper.contactPermissions = new Map<String, Boolean>{
            'canEdit' => Schema.sObjectType.Contact.isUpdateable(),
            'canDelete' => Schema.sObjectType.Contact.isDeletable()
        };
        wrapper.oppPermissions = new Map<String, Boolean>{
            'canEdit' => Schema.sObjectType.Opportunity.isUpdateable(),
            'canDelete' => Schema.sObjectType.Opportunity.isDeletable()
        };

        // 2. Get columns and field names from Field Sets
        List<String> contactFields = new List<String>();
        List<String> oppFields = new List<String>();

        wrapper.contactColumns = getColumnsFromFieldSet('Contact', 'Contact_Field_Set', wrapper.contactPermissions.get('canEdit'), contactFields);
        wrapper.opportunityColumns = getColumnsFromFieldSet('Opportunity', 'Opportunity_Field_Set', wrapper.oppPermissions.get('canEdit'), oppFields);

        // 3. If Field Sets are empty or don't exist, use default fields
        if (contactFields.isEmpty()) {
            contactFields.addAll(new List<String>{'FirstName', 'LastName', 'Email'});
            wrapper.contactColumns.add(new ColumnDef('First Name', 'FirstName', 'text', wrapper.contactPermissions.get('canEdit'))); // line 77
            wrapper.contactColumns.add(new ColumnDef('Last Name', 'LastName', 'text', wrapper.contactPermissions.get('canEdit'))); // line 78
            wrapper.contactColumns.add(new ColumnDef('Email', 'Email', 'email', wrapper.contactPermissions.get('canEdit'))); // line 79
        }
        if (oppFields.isEmpty()) {
            oppFields.addAll(new List<String>{'Name', 'StageName', 'CloseDate'});
            wrapper.opportunityColumns.add(new ColumnDef('Opp Name', 'Name', 'text', wrapper.oppPermissions.get('canEdit'))); // line 83
            wrapper.opportunityColumns.add(new ColumnDef('Stage', 'StageName', 'text', wrapper.oppPermissions.get('canEdit'))); // line 84
            wrapper.opportunityColumns.add(new ColumnDef('Close Date', 'CloseDate', 'date-local', wrapper.oppPermissions.get('canEdit'))); // line 85
        }

        // 4. Dynamically build and run the queries
        if (!contactFields.contains('Id')) contactFields.add(0, 'Id');
        if (!oppFields.contains('Id')) oppFields.add(0, 'Id');

        String contactQuery = 'SELECT ' + String.join(contactFields, ',') + 
                              ' FROM Contact WHERE AccountId = :accountId ORDER BY LastName';
        String oppQuery = 'SELECT ' + String.join(oppFields, ',') +
                          ' FROM Opportunity WHERE AccountId = :accountId ORDER BY CloseDate DESC';

        wrapper.contacts = Database.query(contactQuery);
        wrapper.opportunities = Database.query(oppQuery);

        return wrapper;
    }

    /**
     * @description Deletes a record. This method *respects* sharing rules.
     */
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

    // --- Helper Methods ---

    /**
     * @description Gets column definitions from a Field Set
     */
    private static List<ColumnDef> getColumnsFromFieldSet(String objectName, String fieldSetName, Boolean canEdit, List<String> fieldPaths) {
        List<ColumnDef> columns = new List<ColumnDef>();
        try {
            // --- FIX 2: CORRECTED METHOD TO GET SOBJECT TYPE ---
            // This is the correct way to get an object's "description" from a string name
            Schema.FieldSet fs = Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap().get(fieldSetName); // line 129
            
            if (fs != null) {
                for (Schema.FieldSetMember f : fs.getFields()) {
                    fieldPaths.add(f.getFieldPath());
                    String fieldType = getLightningType(f.getType());
                    columns.add(new ColumnDef(f.getLabel(), f.getFieldPath(), fieldType, canEdit)); // line 134
                }
            }
        } catch (Exception e) {
            System.debug('Field set not found: ' + fieldSetName);
        }
        return columns;
    }
    
    // Helper to map Salesforce field types to Lightning datatable types
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
