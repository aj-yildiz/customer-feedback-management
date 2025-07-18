public class CustomerFeedbackDomain extends fflib_SObjectDomain {
    
    public CustomerFeedbackDomain(List<ece__Customer_Feedback__c> records) { 
        super((List<SObject>) records); 
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CustomerFeedbackDomain((List<ece__Customer_Feedback__c>) sObjectList);
        }
    }
    
    public override void onApplyDefaults() {
        for(ece__Customer_Feedback__c feedback : (List<ece__Customer_Feedback__c>) Records) {
            if(feedback.ece__Status__c == null) {
                feedback.ece__Status__c = 'New';
            }
        }
    }
    
    public override void onValidate() {
        for(ece__Customer_Feedback__c feedback : (List<ece__Customer_Feedback__c>) Records) {
            // Validate description is not blank
            if(String.isBlank(feedback.ece__Description__c)) {
                feedback.ece__Description__c.addError('Description is required');
            }
            
            // Validate email when status is closed
            if(feedback.ece__Status__c == 'Closed' && String.isBlank(feedback.ece__Customer_Email__c)) {
                feedback.ece__Customer_Email__c.addError('Email is required when closing feedback');
            }
            
            // Validate customer name is provided
            if(String.isBlank(feedback.ece__Customer_Name__c)) {
                feedback.ece__Customer_Name__c.addError('Customer name is required');
            }
            
            // Validate feedback type is valid
            Set<String> validTypes = new Set<String>{'Bug', 'Feature Request', 'General Inquiry'};
            if(feedback.ece__Feedback_Type__c != null && !validTypes.contains(feedback.ece__Feedback_Type__c)) {
                feedback.ece__Feedback_Type__c.addError('Invalid feedback type');
            }
        }
    }
    
    public void changeStatus(String newStatus, fflib_ISObjectUnitOfWork uow) {
        validateStatusTransition(newStatus);
        
        for(ece__Customer_Feedback__c feedback : (List<ece__Customer_Feedback__c>) Records) {
            feedback.ece__Status__c = newStatus;
            uow.registerDirty(feedback);
        }
    }
    
    private void validateStatusTransition(String newStatus) {
        Set<String> validStatuses = new Set<String>{'New', 'In Progress', 'Resolved', 'Closed'};
        if(!validStatuses.contains(newStatus)) {
            throw new DomainException('Invalid status: ' + newStatus);
        }
        
        // Business rule: Can't go from Closed back to other statuses
        for(ece__Customer_Feedback__c feedback : (List<ece__Customer_Feedback__c>) Records) {
            if(feedback.ece__Status__c == 'Closed' && newStatus != 'Closed') {
                throw new DomainException('Cannot change status from Closed to ' + newStatus);
            }
        }
    }
    
    public void assignToAgent(String agentId, fflib_ISObjectUnitOfWork uow) {
        for(ece__Customer_Feedback__c feedback : (List<ece__Customer_Feedback__c>) Records) {
            // Would assign to agent if we had that field
            feedback.ece__Status__c = 'In Progress';
            uow.registerDirty(feedback);
        }
    }
    
    public void escalateFeedback(fflib_ISObjectUnitOfWork uow) {
        for(ece__Customer_Feedback__c feedback : (List<ece__Customer_Feedback__c>) Records) {
            if(feedback.ece__Feedback_Type__c == 'Bug') {
                feedback.ece__Status__c = 'In Progress';
                uow.registerDirty(feedback);
            }
        }
    }
    
    public class DomainException extends Exception {}
} 