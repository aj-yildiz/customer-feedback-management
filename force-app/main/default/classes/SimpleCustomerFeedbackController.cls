public with sharing class SimpleCustomerFeedbackController {
    @AuraEnabled(cacheable=true)
    public static List<Customer_Feedback__c> getAllFeedback() {
        return [SELECT 
            Id, 
            Name,
            Customer_Name__c,
            Customer_Email__c,
            Description__c,
            Feedback_Type__c,
            Status__c,
            Priority__c,
            Days_Since_Created__c,
            Escalation_Required__c,
            CreatedDate
        FROM Customer_Feedback__c 
        ORDER BY CreatedDate DESC
        LIMIT 100];
    }

    @AuraEnabled
    public static String createFeedback(Map<String, Object> recordData) {
        try {
            Customer_Feedback__c feedback = new Customer_Feedback__c(
                Customer_Name__c = (String)recordData.get('customerName'),
                Customer_Email__c = (String)recordData.get('customerEmail'),
                Description__c = (String)recordData.get('description'),
                Feedback_Type__c = (String)recordData.get('feedbackType'),
                Status__c = 'New',
                Priority__c = (String)recordData.get('priority')
            );
            
            insert feedback;
            return feedback.Id;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateFeedbackStatus(String recordId, String newStatus) {
        try {
            Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c WHERE Id = :recordId LIMIT 1];
            feedback.Status__c = newStatus;
            update feedback;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
} 