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
    
    @AuraEnabled(cacheable=true)
    public static TicketHistoryWrapper getTicketHistory(String feedbackId) {
        try {
            if (String.isBlank(feedbackId)) {
                return null;
            }
            
            // Get feedback record
            Customer_Feedback__c feedback = [
                SELECT Id, Name, Feedback_Type__c, Priority__c, Status__c, 
                       Description__c, Customer_Email__c, CreatedDate, CreatedBy.Name
                FROM Customer_Feedback__c 
                WHERE Id = :feedbackId 
                LIMIT 1
            ];
            
            // Get responses
            List<FeedbackResponse__c> responses = [
                SELECT Id, Response__c, CreatedDate, CreatedBy.Name
                FROM FeedbackResponse__c 
                WHERE Customer_Feedback__c = :feedbackId 
                ORDER BY CreatedDate ASC
            ];
            
            // Create history timeline
            List<HistoryEntryWrapper> historyEntries = new List<HistoryEntryWrapper>();
            
            // Add ticket creation entry
            historyEntries.add(new HistoryEntryWrapper(
                'ticket_created',
                'Ticket created (' + feedback.Feedback_Type__c + ')',
                feedback.Description__c,
                feedback.CreatedDate,
                feedback.CreatedBy.Name,
                '🎫'
            ));
            
            // Add response entries
            for (FeedbackResponse__c response : responses) {
                historyEntries.add(new HistoryEntryWrapper(
                    'agent_response',
                    'Agent (' + response.CreatedBy.Name + ')',
                    response.Response__c,
                    response.CreatedDate,
                    response.CreatedBy.Name,
                    '✉️'
                ));
            }
            
            return new TicketHistoryWrapper(feedback, historyEntries);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving ticket history: ' + e.getMessage());
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
    
    public class TicketHistoryWrapper {
        @AuraEnabled public Customer_Feedback__c feedback { get; set; }
        @AuraEnabled public List<HistoryEntryWrapper> historyEntries { get; set; }
        
        public TicketHistoryWrapper(Customer_Feedback__c feedback, List<HistoryEntryWrapper> historyEntries) {
            this.feedback = feedback;
            this.historyEntries = historyEntries;
        }
    }
    
    public class HistoryEntryWrapper implements Comparable {
        @AuraEnabled public String entryType { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public DateTime createdDate { get; set; }
        @AuraEnabled public String createdBy { get; set; }
        @AuraEnabled public String icon { get; set; }
        @AuraEnabled public String formattedDate { get; set; }
        @AuraEnabled public String formattedTime { get; set; }
        
        public HistoryEntryWrapper(String entryType, String title, String description, 
                                 DateTime createdDate, String createdBy, String icon) {
            this.entryType = entryType;
            this.title = title;
            this.description = description;
            this.createdDate = createdDate;
            this.createdBy = createdBy;
            this.icon = icon;
            this.formattedDate = createdDate.format('MMM dd');
            this.formattedTime = createdDate.format('hh:mm a');
        }
        
        public Integer compareTo(Object obj) {
            HistoryEntryWrapper other = (HistoryEntryWrapper) obj;
            if (this.createdDate < other.createdDate) return -1;
            if (this.createdDate > other.createdDate) return 1;
            return 0;
        }
    }
} 