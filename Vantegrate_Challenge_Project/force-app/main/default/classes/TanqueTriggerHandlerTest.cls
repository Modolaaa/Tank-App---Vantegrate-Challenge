@isTest
private class TanqueTriggerHandlerTest {
    
    @isTest
    static void testSingleInsert() {
        // Setup: Create Custom Metadata (in real scenario, this would be configured in Setup)
        // For testing, we'll mock the callout
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BitlyMockResponse());
        
        // Insert single record
        Tanque__c tanque = new Tanque__c();
        insert tanque;
        
        Test.stopTest();
        
        // Verify the short URL was populated
        Tanque__c result = [SELECT Short_URL__c FROM Tanque__c WHERE Id = :tanque.Id];
        System.assertNotEquals(null, result.Short_URL__c, 'Short URL should be populated');
    }
    
    @isTest
    static void testBulkInsert() {
        // Create multiple records
        List<Tanque__c> tanques = new List<Tanque__c>();
        for (Integer i = 0; i < 5; i++) {
            tanques.add(new Tanque__c());
        }
        
        Test.startTest();
        insert tanques;
        Test.stopTest();
        
        // Verify that Short_URL__c is NOT populated for bulk inserts
        List<Tanque__c> results = [SELECT Short_URL__c FROM Tanque__c WHERE Id IN :tanques];
        for (Tanque__c t : results) {
            System.assertEquals(null, t.Short_URL__c, 'Short URL should not be populated for bulk insert');
        }
    }
}
