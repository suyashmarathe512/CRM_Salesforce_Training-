/***************************************************************************************************
* @Author:        CRM Developer
* @className:     AccountContactFileController
* @Description:   This class handles the creation of Account and Contact records,
*                 along with uploading a file to the Contact record.
***************************************************************************************************/
public with sharing class AccountContactFileController {
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     saveRecords
* @param:         accName - Name of the Account
*                 accWebsite - Website of the Account
*                 conFName - First Name of the Contact
*                 conLName - Last Name of the Contact
*                 conEmail - Email of the Contact
*                 conPhone - Phone of the Contact
*                 country - Country of the Contact
*                 city - City of the Contact
*                 base64Data - Base64 encoded data of the file
*                 fileName - Name of the file
* @Description:   This class handles the creation of Account and Contact records,
*                 along with uploading a file to the Contact record.
***************************************************************************************************/
    @AuraEnabled
    public static Id saveRecords(String accName, String accWebsite, String conFName, String conLName,
                                 String conEmail, String conPhone, String country, String city,
                                 String base64Data, String fileName){
        try {
            Account acc = new Account();
            acc.Name = accName;
            acc.Website = accWebsite;
            insert acc;
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.FirstName = conFName;
            con.LastName = conLName;
            con.Email = conEmail;
            con.Phone = conPhone;
            con.MailingCountry = country;
            con.MailingCity = city;
            insert con;
            if (base64Data != null && fileName != null) {
                ContentVersion cv = new ContentVersion();
                cv.Title = fileName;
                cv.PathOnClient = fileName;
                cv.VersionData = EncodingUtil.base64Decode(base64Data);
                cv.FirstPublishLocationId = con.Id;
                insert cv;
            }
            return con.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     getCountries
* @Description:   This method returns a list of countries for the dropdown.
***************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getCountries() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        options.add(new Map<String, String>{'label' => 'USA', 'value' => 'USA'});
        options.add(new Map<String, String>{'label' => 'Canada', 'value' => 'Canada'});
        options.add(new Map<String, String>{'label' => 'India', 'value' => 'India'});
        return options;
    }
/***************************************************************************************************
* @Author:        CRM Developer
* @methodName:     getCities
* @param:         country - Country of the Contact
* @Description:   This method returns a list of cities based on the selected country.
***************************************************************************************************/
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
