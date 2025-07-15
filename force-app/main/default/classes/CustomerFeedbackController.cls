public with sharing class CustomerFeedbackController {
    
    @AuraEnabled(cacheable=true)
    public static List<ece__Customer_Feedback__c> getAllFeedback() {
        try {
            List<ece__Customer_Feedback__c> feedbacks = [
                SELECT Id, Name, CreatedDate, LastModifiedDate, 
                       ece__Customer_Name__c, ece__Customer_Email__c, 
                       ece__Feedback_Type__c, ece__Description__c, ece__Status__c
                FROM ece__Customer_Feedback__c 
                ORDER BY CreatedDate DESC
            ];
            
            return feedbacks;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving feedback: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createFeedback(Map<String, Object> recordData) {
        try {
            if (recordData == null) {
                throw new AuraHandledException('Record data cannot be null');
            }
            
            ece__Customer_Feedback__c newFeedback = new ece__Customer_Feedback__c();
            
            if (recordData.containsKey('ece__Customer_Name__c')) {
                newFeedback.ece__Customer_Name__c = (String)recordData.get('ece__Customer_Name__c');
            }
            if (recordData.containsKey('ece__Customer_Email__c')) {
                newFeedback.ece__Customer_Email__c = (String)recordData.get('ece__Customer_Email__c');
            }
            if (recordData.containsKey('ece__Feedback_Type__c')) {
                newFeedback.ece__Feedback_Type__c = (String)recordData.get('ece__Feedback_Type__c');
            }
            if (recordData.containsKey('ece__Description__c')) {
                newFeedback.ece__Description__c = (String)recordData.get('ece__Description__c');
            }
            if (recordData.containsKey('ece__Status__c')) {
                newFeedback.ece__Status__c = (String)recordData.get('ece__Status__c');
            }
            
            insert newFeedback;
            return newFeedback.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating feedback: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateFeedbackStatus(String feedbackId, String newStatus) {
        try {
            ece__Customer_Feedback__c feedback = [
                SELECT Id, ece__Status__c 
                FROM ece__Customer_Feedback__c 
                WHERE Id = :feedbackId 
                LIMIT 1
            ];
            
            feedback.ece__Status__c = newStatus;
            update feedback;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error updating feedback status: ' + e.getMessage());
        }
    }
}
