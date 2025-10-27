public class TranslationController {
    public String selectedLanguage { get; set; }
    public TranslationController() {
        this.selectedLanguage = ApexPages.currentPage().getParameters().get('lang');
        if (this.selectedLanguage == null) {
            this.selectedLanguage = 'en';
        }
    }
    public List<SelectOption> getLanguageOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('en', 'English'));
        options.add(new SelectOption('fr', 'French'));
        options.add(new SelectOption('es', 'Spanish'));
        return options;
    }

    public PageReference changeLanguage() {
        return null;
    }
}
