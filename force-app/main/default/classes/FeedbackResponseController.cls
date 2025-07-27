public with sharing class FeedbackResponseController {
    
    @AuraEnabled
    public static String saveResponse(String feedbackId, String message) {
        try {
            if (String.isBlank(feedbackId) || String.isBlank(message)) {
                throw new AuraHandledException('Feedback ID and message are required.');
            }
            
            FeedbackResponse__c response = new FeedbackResponse__c(
                Customer_Feedback__c = feedbackId,
                Response__c = message
            );
            
            insert response;
            
            return response.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error saving response: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FeedbackResponseWrapper> getResponses(String feedbackId) {
        try {
            if (String.isBlank(feedbackId)) {
                return new List<FeedbackResponseWrapper>();
            }
            
            List<FeedbackResponse__c> responses = [
                SELECT Id, Response__c, CreatedDate, CreatedBy.Name
                FROM FeedbackResponse__c 
                WHERE Customer_Feedback__c = :feedbackId 
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
            
            List<FeedbackResponseWrapper> wrappers = new List<FeedbackResponseWrapper>();
            for (FeedbackResponse__c response : responses) {
                wrappers.add(new FeedbackResponseWrapper(
                    response.Id,
                    response.Response__c,
                    response.CreatedDate,
                    response.CreatedBy.Name
                ));
            }
            
            return wrappers;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving responses: ' + e.getMessage());
        }
    }
    
    public class FeedbackResponseWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public String createdBy { get; set; }
        @AuraEnabled public String formattedDate { get; set; }
        
        public FeedbackResponseWrapper(String id, String message, DateTime createdDate, String createdBy) {
            this.id = id;
            this.message = message;
            this.createdDate = createdDate;
            this.createdBy = createdBy;
            this.formattedDate = createdDate.format('MMM dd, yyyy HH:mm');
        }
    }
} 