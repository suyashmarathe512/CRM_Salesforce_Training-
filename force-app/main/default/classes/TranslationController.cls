/***************************************************************************************************
* @Author:        CRM Developer
* @className:     TranslationController
* @Description:   This class manages language selection for the application.
***************************************************************************************************/
public class TranslationController{
    public String selectedLanguage { get; set; }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     TranslationController
* @Description:   This constructor initializes the selected language based on URL parameters.
***************************************************************************************************/
    public TranslationController() {
        this.selectedLanguage = ApexPages.currentPage().getParameters().get('lang');
        if (this.selectedLanguage == null) {
            this.selectedLanguage = 'en';
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     getLanguageOptions
* @Description:   This method returns a list of available language options.
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
* @methodName:     changeLanguage
* @Description:   This method changes the language of the application.
***************************************************************************************************/
    public PageReference changeLanguage() {
        return null;
    }
}
