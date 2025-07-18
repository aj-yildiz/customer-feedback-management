public with sharing class CustomerFeedbackController {
    
    @AuraEnabled(cacheable=true)
    public static List<ece__Customer_Feedback__c> getAllFeedback() {
        try {
            return CustomerFeedbackSelector.fetchAll();
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
            
            // Create feedback record from input data
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
            
            // Use Unit of Work pattern for DML
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            uow.registerNew(newFeedback);
            uow.commitWork();
            
            return newFeedback.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating feedback: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateFeedbackStatus(String feedbackId, String newStatus) {
        try {
            // Use Selector to get the record
            ece__Customer_Feedback__c feedback = CustomerFeedbackSelector.fetchById(feedbackId);
            if (feedback == null) {
                throw new AuraHandledException('Feedback record not found');
            }
            
            // Use Domain and Unit of Work for business logic and DML
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<ece__Customer_Feedback__c>{feedback});
            domain.changeStatus(newStatus, uow);
            uow.commitWork();
            
        } catch (CustomerFeedbackDomain.DomainException e) {
            throw new AuraHandledException('Business rule violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error updating feedback status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ece__Customer_Feedback__c> getFeedbackByStatus(String status) {
        try {
            CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
            return selector.selectByStatus(status);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving feedback by status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ece__Customer_Feedback__c> getFeedbackByType(String feedbackType) {
        try {
            CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
            return selector.selectByType(feedbackType);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving feedback by type: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void escalateFeedback(String feedbackId) {
        try {
            ece__Customer_Feedback__c feedback = CustomerFeedbackSelector.fetchById(feedbackId);
            if (feedback == null) {
                throw new AuraHandledException('Feedback record not found');
            }
            
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<ece__Customer_Feedback__c>{feedback});
            domain.escalateFeedback(uow);
            uow.commitWork();
            
        } catch (Exception e) {
            throw new AuraHandledException('Error escalating feedback: ' + e.getMessage());
        }
    }
}
