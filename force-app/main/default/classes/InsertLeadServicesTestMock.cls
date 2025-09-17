public with sharing class InsertLeadServicesTestMock {
    public static String getRequestBody(String mockBehaviour) {
        if (mockBehaviour == 'success') {
            return '[{"FirstName":"LeadServices","LastName":"Test","Email":"john.doe@example.com","Phone":"1234567890"}]';
        } else if (mockBehaviour == 'multiple') {
            return '[{"FirstName":"LeadServices","LastName":"Test2","Email":"john.doe@example.com","Phone":"1234567890"},' +
                   '{"FirstName":"LeadServices","LastName":"Test3","Email":"jane.smith@example.com","Phone":"0987654321"}]';
        } else if (mockBehaviour == 'empty') {
            return '';
        } else if (mockBehaviour == 'invalidJson') {
            return 'invalid json';
        } else if (mockBehaviour == 'missingFirstName') {
            return '[{"LastName":"Doe","Email":"john.doe@example.com","Phone":"1234567890"}]';
        } else if (mockBehaviour == 'invalidEmail') {
            return '[{"FirstName":"John","LastName":"Doe","Email":"john.doeexample.com","Phone":"1234567890"}]';
        } else if (mockBehaviour == 'calloutException') {
            throw new CalloutException('Callout Exception');
        }
        return '';
    }
}
