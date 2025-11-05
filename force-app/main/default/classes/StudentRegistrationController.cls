/***************************************************************************************************
* @Author:        CRM Developer
* @className:     StudentRegistrationController
* @Description:   This class handles student registration, including language selection and saving student records.
*                 Exposes lastSavedId and toastMessage for the VF page to consume for post-save behavior.
***************************************************************************************************/
public class StudentRegistrationController {
    public Student__c student { get; set; }
    public String selectedLanguage { get; set; }
    public Id lastSavedId { get; set; }
    public String toastMessage { get; set; }
    public String errorMessage { get; set; }

/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     StudentRegistrationController
* @Description:   This is the constructor for the StudentRegistrationController class, initializing 
*                 the student object and default language. Also checks URL parameters for language override.
***************************************************************************************************/
    public StudentRegistrationController() {
        this.student = new Student__c();
        String langParam = ApexPages.currentPage().getParameters().get('lang');
        this.selectedLanguage = String.isNotBlank(langParam) ? langParam : 'en';
        this.lastSavedId = null;
        this.toastMessage = '';
        this.errorMessage = '';
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
*                 Validates required fields and constructs the full name field from first and last names.
***************************************************************************************************/
    public PageReference saveStudent() {
        this.lastSavedId = null;
        this.toastMessage = '';
        this.errorMessage = '';
        if (String.isBlank(student.Last_Name__c)) {
            this.errorMessage = Label.LastNameRequired;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.errorMessage));
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
        this.lastSavedId = student.Id;
        this.toastMessage = Label.SuccessMessage;
        this.student = new Student__c();
        return null;
    }
}