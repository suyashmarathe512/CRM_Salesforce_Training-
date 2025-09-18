public with sharing class DeleteAccountScriptController {
    @RemoteAction
    public static String deleteAccount(String accountId) {
        try {
            Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
            delete acc;
            return 'success';
        } catch (Exception e) {
            return 'error: ' + e.getMessage();
        }
    }
}