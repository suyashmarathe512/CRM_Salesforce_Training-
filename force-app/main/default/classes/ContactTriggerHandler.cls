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
}