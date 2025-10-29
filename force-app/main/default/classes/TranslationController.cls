/**
 * @description Apex controller to handle callouts to the LibreTranslate API.
 * IMPORTANT: You MUST add 'https://libretranslate.de' to Remote Site Settings.
 */
public with sharing class TranslationController {

    // The public endpoint for the LibreTranslate API
    private static final String TRANSLATE_ENDPOINT = 'https://libretranslate.de/translate';

    /**
     * @description Calls the LibreTranslate API to translate a given text.
     * @param textToTranslate The text string to be translated.
     * @param sourceLang The 2-letter language code (e.g., 'en', 'auto').
     * @param targetLang The 2-letter language code (e.g., 'es').
     * @return String The translated text.
     */
    @AuraEnabled
    public static String translateText(String textToTranslate, String sourceLang, String targetLang) {
        
        try {
            // 1. Prepare the HTTP Request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(TRANSLATE_ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Accept', 'application/json');

            // 2. Build the JSON body using a wrapper class for clarity
            TranslateRequestBody body = new TranslateRequestBody();
            body.q = textToTranslate;
            body.source = sourceLang;
            body.target = targetLang;
            
            req.setBody(JSON.serialize(body));

            // 3. Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);

            // 4. Handle the Response
            if (res.getStatusCode() == 200) {
                // Deserialize the response to get the translated text
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                
                if (responseMap.containsKey('translatedText')) {
                    return (String)responseMap.get('translatedText');
                } else if (responseMap.containsKey('error')) {
                    // Handle API-level errors (e.g., invalid language)
                    throw new AuraHandledException('API Error: ' + (String)responseMap.get('error'));
                } else {
                    throw new AuraHandledException('Could not parse translation from response.');
                }

            } else {
                // Handle HTTP errors (e.g., 404, 500)
                throw new AuraHandledException('Translation service failed. Status: ' + res.getStatus() + ' Body: ' + res.getBody());
            }

        } catch (Exception e) {
            // Catch callout exceptions, JSON exceptions, etc.
            throw new AuraHandledException('Error calling translation service: ' + e.getMessage());
        }
    }

    /**
     * @description Inner class to model the JSON request body for the API.
     */
    private class TranslateRequestBody {
        public String q;
        public String source;
        public String target;
        public String format = 'text';
    }
}
