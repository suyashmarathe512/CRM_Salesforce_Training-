public with sharing class AccountContactFileController {

    // Main method to save all records
    @AuraEnabled
    public static Id saveRecords(String accName, String accWebsite, String conFName, String conLName, 
                                 String conEmail, String conPhone, String country, String city, 
                                 String base64Data, String fileName) {
        
        try {
            // 1. Create Account
            Account acc = new Account();
            acc.Name = accName;
            acc.Website = accWebsite;
            insert acc;

            // 2. Create Contact related to the Account
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.FirstName = conFName;
            con.LastName = conLName;
            con.Email = conEmail;
            con.Phone = conPhone;
            con.MailingCountry = country;
            con.MailingCity = city;
            insert con;

            // 3. Upload File (ContentVersion) and link to the new Contact
            if (base64Data != null && fileName != null) {
                ContentVersion cv = new ContentVersion();
                cv.Title = fileName;
                cv.PathOnClient = fileName;
                cv.VersionData = EncodingUtil.base64Decode(base64Data);
                cv.FirstPublishLocationId = con.Id; // Link file to the Contact
                insert cv;
            }

            // Return the new Contact ID for navigation
            return con.Id;

        } catch (Exception e) {
            // Pass the error back to the LWC
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Method to get the list of countries
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCountries() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        options.add(new Map<String, String>{'label' => 'USA', 'value' => 'USA'});
        options.add(new Map<String, String>{'label' => 'Canada', 'value' => 'Canada'});
        options.add(new Map<String, String>{'label' => 'India', 'value' => 'India'});
        return options;
    }

    // Method to get cities based on the selected country
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCities(String country) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        
        if (country == 'USA') {
            options.add(new Map<String, String>{'label' => 'New York', 'value' => 'New York'});
            options.add(new Map<String, String>{'label' => 'Chicago', 'value' => 'Chicago'});
            options.add(new Map<String, String>{'label' => 'San Francisco', 'value' => 'San Francisco'});
        } else if (country == 'Canada') {
            options.add(new Map<String, String>{'label' => 'Toronto', 'value' => 'Toronto'});
            options.add(new Map<String, String>{'label' => 'Vancouver', 'value' => 'Vancouver'});
            options.add(new Map<String, String>{'label' => 'Montreal', 'value' => 'Montreal'});
        } else if (country == 'India') {
            options.add(new Map<String, String>{'label' => 'Mumbai', 'value' => 'Mumbai'});
            options.add(new Map<String, String>{'label' => 'New Delhi', 'value' => 'New Delhi'});
            options.add(new Map<String, String>{'label' => 'Bangalore', 'value' => 'Bangalore'});
        }
        
        return options;
    }
}