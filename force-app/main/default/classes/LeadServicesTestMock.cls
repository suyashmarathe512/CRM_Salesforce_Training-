/***************************************************************************************************
* @Author:        CRM Developer
* @ClassName:     LeadServicesTestMock
* @Description:   This class mocks the request body for the createLead method.
***************************************************************************************************/
public with sharing class LeadServicesTestMock{
    public static String getRequestBody(String mockBehaviour){
        if (mockBehaviour=='success'){
            return '[{"FirstName":"LeadServices","LastName":"Test","Email":"LeadServices.Test@example.com","Phone":"1234567890"}]';
        }else if (mockBehaviour=='multiple'){
            return '[{"FirstName":"LeadServices","LastName":"Test2","Email":"LeadServices.Test2@example.com","Phone":"1234567890"},' +
                   '{"FirstName":"LeadServices","LastName":"Test3","Email":"LeadServices.Test3@example.com","Phone":"0987654321"}]';
        }else if(mockBehaviour=='empty'){
            return '';
        }else if(mockBehaviour=='invalidJson'){
            return 'invalid json';
        }else if(mockBehaviour=='missingFirstName'){
            return '[{"LastName":"Test","Email":"abc.Test@example.com","Phone":"1234567890"}]';
        }else if(mockBehaviour=='invalidEmail'){
            return '[{"FirstName":"LeadServices","LastName":"Test","Email":"abc.Testexample.com","Phone":"1234567890"}]';
        }else if(mockBehaviour=='calloutException'){
            return '[{"FirstName":"callout","LastName":"Test","Email":"abc.Testexample.com","Phone":"1234567890"}]';
        }else if(mockBehaviour=='partialCreate'){
            return '[{"FirstName":"Valid","LastName":"Lead","Email":"valid@example.com","Phone":"1234567890"},' +
                   '{"LastName":"Invalid","Email":"invalid@example.com","Phone":"0987654321"}]';
        }
        return '';
    }
    public static String getDeleteRequestBody(String mockBehaviour){
        if (mockBehaviour=='success'){
            return '[{"FirstName":"LeadServices","LastName":"Test","Email":"LeadServices.Test@example.com","Phone":"1234567890"}]';
        }else if(mockBehaviour=='missingFirstName'){
            return '[{"LastName":"Test","Email":"abc.Test@example.com","Phone":"1234567890"}]';
        }else if(mockBehaviour=='noLead'){
            return '[{"FirstName":"No","LastName":"Lead","Email":"no@lead.com","Phone":"000"}]';
        }else if(mockBehaviour=='empty'){
            return '';
        }else if(mockBehaviour=='invalidJson'){
            return 'invalid json';
        }else if(mockBehaviour=='partialDelete'){
            return '[{"FirstName":"Existing","LastName":"Lead","Email":"existing@example.com","Phone":"1234567890"},' +
                   '{"FirstName":"NonExisting","LastName":"Lead","Email":"nonexisting@example.com","Phone":"0987654321"}]';
        }
        return '';
    }
    public static String getUpdateRequestBody(String mockBehaviour){
        if (mockBehaviour=='success'){
            return '[{"FirstName":"LeadServices","LastName":"Test","NewEmail":"new@example.com","NewPhone":"1111111111"}]';
        }else if(mockBehaviour=='missingFirstName'){
            return '[{"LastName":"Test","NewEmail":"new@example.com","NewPhone":"1111111111"}]';
        }else if(mockBehaviour=='noLead'){
            return '[{"FirstName":"No","LastName":"Lead","NewEmail":"new@example.com","NewPhone":"1111111111"}]';
        }else if(mockBehaviour=='empty'){
            return '';
        }else if(mockBehaviour=='invalidJson'){
            return 'invalid json';
        }
        else if(mockBehaviour=='DMLException'){
            return '[{"FirstName":"LeadServices","LastName":"Test","NewEmail":"newexample.com","NewPhone":"1111111111"}]';
        }else if(mockBehaviour=='partialUpdate'){
            return '[{"FirstName":"Existing","LastName":"Lead","NewEmail":"updated@example.com","NewPhone":"1111111111"},' +
                   '{"FirstName":"NonExisting","LastName":"Lead","NewEmail":"nonupdatedexample.com","NewPhone":"2222222222"}]';
        }
        return '';
    }
}
