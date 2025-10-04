trigger TanqueTrigger on Tanque__c (after insert) {
    // Only process if exactly one record is being inserted
    if (Trigger.isAfter && Trigger.isInsert && Trigger.new.size() == 1) {
        TanqueTriggerHandler.handleBitlyIntegration(Trigger.new[0].Id);
    }
}