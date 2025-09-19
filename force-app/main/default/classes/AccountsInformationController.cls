public class AccountsInformationController {
    public List<Account> accounts { get; set; }
    public String searchTerm { get; set; }
    public Integer accountCount { get; set; }
    public String searchMessage { get; set; }
    public String selectedAlphabet { get; set; }
    public list<String> alphabet{
    get{                                                                                                                    //To display a list of alphabets on vf page 
        alphabet = new list<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Others','All'};
            return alphabet;         
            }
    set;
    }
    public AccountsInformationController(){
        searchTerm='';
        searchMessage='';
        accounts=[SELECT 
                        Id, Name, Email_Address__c, Phone, Website 
                FROM 
                    Account];
        accountCount=accounts.size();
    }
    public void searchAccounts() {
        if(String.isBlank(searchTerm)||searchTerm.length()<3) {
            accounts = [SELECT Id, Name, Email_Address__c, Phone, Website FROM Account];
        }else{
            accounts = [SELECT Id, Name, Email_Address__c, Phone, Website FROM Account WHERE Name LIKE :('%' + searchTerm + '%')];
        }
        accountCount = accounts.size();
    }
    public void clearSearch() {
        searchTerm = '';
        searchMessage = '';
        accounts = [SELECT Id, Name, Email_Address__c, Phone, Website FROM Account];
        accountCount = accounts.size();
    }
    public PageReference alphabetSearch() {
        if (selectedAlphabet=='All'){
        accounts = [SELECT Id, Name, Email_Address__c, Phone, Website FROM Account];
        }
        else{
            accounts = [SELECT Id, Name, Email_Address__c, Phone, Website FROM Account WHERE Name LIKE :selectedAlphabet+'%'];
        }
        return null;
    }
    
    @RemoteAction
    public static String deleteAccountRemote(String accountId) {
        try {
            Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
            delete acc;
            return 'success';
        } catch (Exception e) {
            return 'error: ' + e.getMessage();
        }
    }
}
