/***************************************************************************************************
* @Author:        CRM Developer
* @className:     StudentRegistrationController
* @Description:   This class handles student registration, including language selection and saving student records.
***************************************************************************************************/
public class StudentRegistrationController {
    public Student__c student { get; set; }
    public String selectedLanguage { get; set; }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     StudentRegistrationController
* @Description:   This is the constructor for the StudentRegistrationController class, initializing 
                        the student object and default language.
***************************************************************************************************/
    public StudentRegistrationController() {
        this.student = new Student__c(); 
        this.selectedLanguage = 'en'; 
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     getLanguageOptions
* @Description:   This method returns a list of language options for the student to select from.
***************************************************************************************************/
    public List<SelectOption> getLanguageOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('en', 'English'));
        options.add(new SelectOption('fr', 'French'));
        options.add(new SelectOption('es', 'Spanish'));
        return options;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     saveStudent
* @Description:   This method saves the student record to the database and provides feedback messages.
***************************************************************************************************/
    public PageReference saveStudent() {
        try {
            if (String.isBlank(student.Last_Name__c)) {
                ApexPages.Message errorMsg = new ApexPages.Message(
                    ApexPages.Severity.ERROR, 'Last Name is required.'
                );
                ApexPages.addMessage(errorMsg);
                return null;
            }
            if (String.isNotBlank(student.First_Name__c) && String.isNotBlank(student.Last_Name__c)) {
                student.Name = student.First_Name__c + ' ' + student.Last_Name__c;
            } else if (String.isNotBlank(student.First_Name__c)) {
                student.Name = student.First_Name__c;
            } else if (String.isNotBlank(student.Last_Name__c)) {
                student.Name = student.Last_Name__c;
            }
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