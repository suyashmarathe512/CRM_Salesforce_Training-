public with sharing class LeadDeletionMock {
    public static String getRequestBody(String mockBehaviour) {
        if (mockBehaviour == 'success') {
            return '{"FirstName":"Test","LastName":"Lead","Email":"test.lead@example.com","Phone":"1234567890"}';
        } else if (mockBehaviour == 'multiple') {
            return '{"FirstName":"Test","LastName":"Lead","Email":"test.lead@example.com","Phone":"1234567890"}';
        } else if (mockBehaviour == 'noLead') {
            return '{"FirstName":"Unknown","LastName":"Test","Email":"Unlnown@Test.com","Phone":"1234567890"}';
        } else if (mockBehaviour == 'empty') {
            return '';
        } else if (mockBehaviour == 'invalidJson') {
            return 'invalid json';
        } else if (mockBehaviour == 'missingFirstName') {
            return '{"LastName":"Test","Email":"abc.test@example.com","Phone":"1234567890"}';
        } else if (mockBehaviour == 'calloutException') {
            throw new CalloutException('Callout Exception');
        } else if (mockBehaviour == 'dmlException') {
            throw new DmlException('DML Exception');
        }
        return '';
    }
}
