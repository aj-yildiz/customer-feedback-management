public with sharing class CustomerFeedbackController {
    
    //
    @AuraEnabled(cacheable=true)
    public static List<Customer_Feedback__c> getAllFeedback() {
        try {
            return CustomerFeedbackService.getAllFeedback();
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving feedback: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createFeedback(Map<String, Object> recordData) {
        try {
            return CustomerFeedbackService.createFeedback(recordData);
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            throw new AuraHandledException('Business rule violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error creating feedback: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateFeedbackStatus(String feedbackId, String newStatus) {
        try {
            CustomerFeedbackService.updateFeedbackStatus(feedbackId, newStatus);
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            throw new AuraHandledException('Business rule violation: ' + e.getMessage());
        } catch (CustomerFeedbackDomain.DomainException e) {
            throw new AuraHandledException('Business rule violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error updating feedback status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Customer_Feedback__c> getFeedbackByStatus(String status) {
        try {
            return CustomerFeedbackService.getFeedbackByStatus(status);
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            throw new AuraHandledException('Invalid input: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving feedback by status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Customer_Feedback__c> getFeedbackByType(String feedbackType) {
        try {
            return CustomerFeedbackService.getFeedbackByType(feedbackType);
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            throw new AuraHandledException('Invalid input: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving feedback by type: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void escalateFeedback(String feedbackId) {
        try {
            CustomerFeedbackService.escalateFeedback(feedbackId);
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            throw new AuraHandledException('Business rule violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error escalating feedback: ' + e.getMessage());
        }
    }
    
    // method to handle bulk records 1 record vs 10k
    // to avoid the governor limit 
    @AuraEnabled
    public static void processBulkFeedbackUpdates(List<Map<String, Object>> feedbackUpdates) {
        try {
            CustomerFeedbackService.processBulkFeedbackUpdates(feedbackUpdates);
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            throw new AuraHandledException('Business rule violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error processing bulk updates: ' + e.getMessage());
        }
    }
}
