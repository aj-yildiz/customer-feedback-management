public with sharing class CustomerFeedbackController {
    
    @AuraEnabled(cacheable=true)
    public static List<Customer_Feedback__c> getAllFeedback() {
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
            Customer_Feedback__c newFeedback = new Customer_Feedback__c();
            
            if (recordData.containsKey('Customer_Name__c')) {
                newFeedback.Customer_Name__c = (String)recordData.get('Customer_Name__c');
            }
            if (recordData.containsKey('Customer_Email__c')) {
                newFeedback.Customer_Email__c = (String)recordData.get('Customer_Email__c');
            }
            if (recordData.containsKey('Feedback_Type__c')) {
                newFeedback.Feedback_Type__c = (String)recordData.get('Feedback_Type__c');
            }
            if (recordData.containsKey('Description__c')) {
                newFeedback.Description__c = (String)recordData.get('Description__c');
            }
            if (recordData.containsKey('Status__c')) {
                newFeedback.Status__c = (String)recordData.get('Status__c');
            }
            if (recordData.containsKey('Priority__c')) {
                newFeedback.Priority__c = (String)recordData.get('Priority__c');
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
            Customer_Feedback__c feedback = CustomerFeedbackSelector.fetchById(feedbackId);
            if (feedback == null) {
                throw new AuraHandledException('Feedback record not found');
            }
            
            // Use Domain and Unit of Work for business logic and DML
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
            domain.changeStatus(newStatus, uow);
            uow.commitWork();
            
        } catch (CustomerFeedbackDomain.DomainException e) {
            throw new AuraHandledException('Business rule violation: ' + e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Error updating feedback status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Customer_Feedback__c> getFeedbackByStatus(String status) {
        try {
            CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
            return selector.selectByStatus(status);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving feedback by status: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Customer_Feedback__c> getFeedbackByType(String feedbackType) {
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
            Customer_Feedback__c feedback = CustomerFeedbackSelector.fetchById(feedbackId);
            if (feedback == null) {
                throw new AuraHandledException('Feedback record not found');
            }
            
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
            domain.escalateFeedback(uow);
            uow.commitWork();
            
        } catch (Exception e) {
            throw new AuraHandledException('Error escalating feedback: ' + e.getMessage());
        }
    }
}
