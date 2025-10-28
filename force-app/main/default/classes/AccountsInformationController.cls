public class AccountsInformationController {
    public List<Account> accounts { get; set; }
    public String searchTerm { get; set; }
    public Integer accountCount { get; set; }
    public String searchMessage { get; set; }
    public String selectedAlphabet { get; set; }
    public Integer pageSize { get; set; }
    public Integer currentPage { get; set; }
    public List<String> alphabet {
        get { 
            alphabet = new List<String>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','All'};
            return alphabet;
        }
        set;
    }
    public List<Account> getPaginatedAccounts() {
        Integer startIndex = currentPage * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, accounts.size());
        if(startIndex >= accounts.size()) {
            return new List<Account>();
        }
        List<Account> paginatedList = new List<Account>();
        for(Integer i = startIndex; i < endIndex; i++) {
            paginatedList.add(accounts[i]);
        }
        return paginatedList;
    }
    public Integer getCurrentPageStart() {
        return currentPage * pageSize;
    }
    public Boolean getHasNext() {
        return (currentPage + 1) * pageSize < accounts.size();
    }
    public Boolean getHasPrevious() {
        return currentPage > 0;
    }
    public void nextPage() {
        if(getHasNext()) {
            currentPage++;
        }
    }
    public void previousPage() {
        if(getHasPrevious()) {
            currentPage--;
        }
    }
    private List<Account> getAccounts(String filter) {
        String query = 'SELECT Id, Name, Email_Address__c, Phone, Website FROM Account';
        if (filter != null && !String.isBlank(filter)) {
            query += ' WHERE ' + filter;
        }
        query += ' ORDER BY Name ASC';
        return Database.query(query);
    }
    public void resetSearch() {
        searchTerm = '';
        searchMessage = '';
        currentPage = 0;
        accounts = getAccounts(null);
        accountCount = accounts.size();
    }
    public AccountsInformationController() {
        pageSize = 15;
        currentPage = 0;
        resetSearch();
    }
    public void searchAccounts() {
        currentPage = 0;
        String filter = null;
        if (!String.isBlank(searchTerm) && searchTerm.length() >= 3) {
            filter = 'Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        accounts = getAccounts(filter);
        accountCount = accounts.size();
    }
    public PageReference alphabetSearch() {
        currentPage = 0;
        String filter = null;
        if (selectedAlphabet != 'All' && !String.isBlank(selectedAlphabet)) {
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
                                Id, Name, Email_Address__c, Phone, Website
                            FROM 
                                Account 
                            WHERE 
                                Id = :accountId 
                            LIMIT 
                                1];
            delete acc;
            return 'success';
        } catch(Exception e) {
            throw new AuraHandledException('Error deleting account: ' + e.getMessage());
        }
    }
}
