trigger FeedbackTrigger on ece__Customer_Feedback__c (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    fflib_SObjectDomain.triggerHandler(CustomerFeedbackDomain.class);
} 