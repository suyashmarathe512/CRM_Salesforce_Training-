public class StudentRegistrationController {
    public Student__c student { get; set; }
    public String selectedLanguage { get; set; }
    public StudentRegistrationController() {
        this.student = new Student__c(); 
        this.selectedLanguage = 'en'; 
    }
    public List<SelectOption> getLanguageOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('en', 'English'));
        options.add(new SelectOption('fr', 'French'));
        options.add(new SelectOption('es', 'Spanish'));
        
        return options;
    }
    public PageReference saveStudent() {
        try {
            insert student; 
            ApexPages.Message successMsg = new ApexPages.Message(
                ApexPages.Severity.CONFIRM, Label.SuccessMessage
            );
            ApexPages.addMessage(successMsg);
            this.student = new Student__c();

        } catch (Exception e) {
            ApexPages.Message errorMsg = new ApexPages.Message(
                ApexPages.Severity.ERROR, 'Error: ' + e.getMessage()
            );
            ApexPages.addMessage(errorMsg);
        }
        return null;
    }
}