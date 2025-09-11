public with sharing class DeleteDuplicateLeads {
    Set<String> emailSet = new Set<String>();
    Set<String> nameSet = new Set<String>();
    public void getDuplicateLeads(){
        List<Lead> leads = [SELECT Id, Name, Email FROM Lead];
        List<Lead> duplicateLeads = new List<Lead>();
        for(Lead l : leads){
            if(emailSet.contains(l.Email) || nameSet.contains(l.Name)){
                duplicateLeads.add(l);
            }else{
                nameSet.add(l.Name);
                emailSet.add(l.Email);
            }
        }
        Database.DeleteResult[] results = Database.delete(duplicateLeads, false);
    }
}