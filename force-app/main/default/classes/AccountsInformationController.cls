public class AccountsInformationController {
    public List<Account> accounts { get; set; }
    public String searchTerm { get; set; }
    public Integer accountCount { get; set; }
    public String searchMessage { get; set; }
    public String selectedAlphabet { get; set; }
    public list<String> alphabet{
    get{                                                                                              
        alphabet = new list<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'};
            return alphabet;         
            }
    set;
    }
    private List<Account> getAccounts(String filter) {
        String query = 'SELECT Id, Name, Email_Address__c, Phone, Website FROM Account';
        if (filter != null && !String.isBlank(filter)) {
            query += ' WHERE ' + filter;
        }
        return Database.query(query);
    }
    private void resetSearch() {
        searchTerm = '';
        searchMessage = '';
        accounts = getAccounts(null);
        accountCount = accounts.size();
    }
    public List<Account> queryAccounts(){
        accounts = getAccounts(null);
        return accounts;
    }
    public AccountsInformationController(){
        resetSearch();
    }
    public void searchAccounts() {
        String filter = null;
        if (!String.isBlank(searchTerm) && searchTerm.length() >= 3) {
            filter = 'Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        accounts = getAccounts(filter);
        accountCount = accounts.size();
    }
    public void clearSearch() {
        resetSearch();
    }
    public PageReference alphabetSearch() {
        String filter = null;
        if (selectedAlphabet != 'All') {
            filter = 'Name LIKE \'' + String.escapeSingleQuotes(selectedAlphabet) + '%\'';
        }
        accounts = getAccounts(filter);
        accountCount = accounts.size();
        return null;
    }
    @RemoteAction
    public static String deleteAccountRemote(String accountId) {
        try {
            Account acc = [SELECT 
                                Id 
                            FROM 
                                Account 
                            WHERE 
                                Id = :accountId];
            delete acc;
            return 'success';
        } catch (Exception e) {
            return 'error: ' + e.getMessage();
        }
    }
}
