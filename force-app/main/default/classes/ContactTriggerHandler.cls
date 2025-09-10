public class ContactTriggerHandler {
    //Update for the review.
    public static void checkDuplicates(List<Contact> newContacts) {
        List<String> emails = new List<String>();
        List<String> phones = new List<String>();
        for(Contact c : newContacts){
            if(c.Email != null){
                emails.add(c.Email);
            }
            if(c.Phone != null){
                phones.add(c.Phone);
            }
        }
        List<Contact> existing = [
            SELECT Id, Email, Phone
            FROM Contact
            WHERE Email IN :emails OR Phone IN :phones
        ];
        for(Contact newCon : newContacts){
            for(Contact oldCon : existing){
                if(newCon.Id != oldCon.Id){
                    if(newCon.Email != null && newCon.Email == oldCon.Email){
                        newCon.addError('A Contact with the same email address or phone number already exists in the system.');
                    }
                    if(newCon.Phone != null && newCon.Phone == oldCon.Phone){
                        newCon.addError('A Contact with the same email address or phone number already exists in the system.');
                    }
                }
            }
        }
    }
    public static void associateAccountWithContact(List<Contact> newContacts) {
        List<Account> accounts = [SELECT Id, Name, Website FROM Account WHERE Website != null];
        Map<String, Id> websiteToAccountIdMap = new Map<String, Id>(); 
        for (Account acc : accounts) {
            if(acc.Website.contains('.' )){
                String website = acc.Website.substringAfter('.');
                websiteToAccountIdMap.put(website, acc.Id);
                system.debug('Website: ' + website + ' Account Id: ' + acc.Id + '');
            }
            if(acc.Website.contains('/')){
                String httpsWeb = acc.Website.substringAfter('/');
                websiteToAccountIdMap.put(httpsWeb, acc.Id);
                system.debug('Website: ' + httpsWeb + ' Account Id: ' + acc.Id + '');
            }
        }
        for (Contact c : newContacts) {
            if (c.Email != null && c.Email.contains('@')) {
                String emailDomain = c.Email.substringAfterLast('@');
                system.debug('Email Domain: ' + emailDomain);
                if (websiteToAccountIdMap.containsKey(emailDomain)) {
                    c.AccountId = websiteToAccountIdMap.get(emailDomain);
                    system.debug('Contact Id: ' + c.Id + ' Account Id: ' + c.AccountId);
                }
            }
            else{
                c.addError('Email address is required to associate with an Account.');
            }
        }
    }
}