/***************************************************************************************************
* @Author:        CRM Developer
* @ClassName:     InsertLeadServicesTestMock
* @Description:   This class mocks the request body for the createLead method.
***************************************************************************************************/
public with sharing class InsertLeadServicesTestMock{
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
            throw new CalloutException('Callout Exception');
        }
        return '';
    }
}
