/**
 * @description Trigger handler class for managing Bitly URL shortening integration
 *              for Tanque__c records. This class provides asynchronous callouts
 *              to the Bitly API using a Named Credential for authentication.
 *
 * @author      Modola Lautaro 
 * @date        2025-10-02
 */
public class TanqueTriggerHandler {
    

        /**
     * @description Asynchronously integrates with Bitly to generate a shortened URL
     *              for the given Tanque__c record. The shortened URL is saved
     *              in the Short_URL__c field of the record.
     *
     * @param tanqueId   The Id of the Tanque__c record to process.
     */
    @future(callout=true)
    public static void handleBitlyIntegration(Id tanqueId) {
        try {
            // Get the record
            Tanque__c tanque = [SELECT Id, Name, Short_URL__c FROM Tanque__c WHERE Id = :tanqueId LIMIT 1];
            
            // Build the full Salesforce URL for this record
            String baseUrl = URL.getOrgDomainUrl().toExternalForm();
            String fullUrl = baseUrl + '/' + tanque.Id;
            
            // Call Bitly API to shorten URL
            String shortUrl = getBitlyShortUrl(fullUrl);
            
            // Update the record with the shortened URL
            if (String.isNotBlank(shortUrl)) {
                tanque.Short_URL__c = shortUrl;
                update tanque;
            }
            
        } catch (Exception e) {
            System.debug('Error in Bitly integration: ' + e.getMessage());
        }
    }
    /**
     * @description Calls the Bitly API using the configured Named Credential
     *              to generate a shortened URL from a long Salesforce record URL.
     *
     * @param longUrl   The original Salesforce record URL to shorten.
     * @return          The shortened Bitly link if successful, or null if the API call fails.
     */
    private static String getBitlyShortUrl(String longUrl) {

        // URL configured in Named Credential: https://api-ssl.bitly.com
        
        // Prepare the HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Bitly_API_Named_Credential/v4/shorten');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
        
        // Build request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('long_url', longUrl);
        
        requestBody.put('domain','bit.ly');
        
        req.setBody(JSON.serialize(requestBody));
        
        // Make the callout
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Process response
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('link');
        } else {
            System.debug('Bitly API Error: ' + res.getStatusCode() + ' - ' + res.getBody());
            return null;
        }
    }
}
