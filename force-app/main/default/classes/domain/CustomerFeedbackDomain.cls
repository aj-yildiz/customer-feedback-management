public class CustomerFeedbackDomain extends fflib_SObjectDomain {
    
    public CustomerFeedbackDomain(List<Customer_Feedback__c> records) { 
        super((List<SObject>) records); 
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CustomerFeedbackDomain((List<Customer_Feedback__c>) sObjectList);
        }
    }
    
    public override void onApplyDefaults() {
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            if(feedback.Status__c == null) {
                feedback.Status__c = 'New';
            }
            if(feedback.Priority__c == null) {
                feedback.Priority__c = 'Medium';
            }
        }
    }
    
    public override void onValidate() {
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            // Validate description is not blank
            if(String.isBlank(feedback.Description__c)) {
                feedback.Description__c.addError('Description is required');
            }
            
            // Validate email when status is closed
            if(feedback.Status__c == 'Closed' && String.isBlank(feedback.Customer_Email__c)) {
                feedback.Customer_Email__c.addError('Email is required when closing feedback');
            }
            
            // Validate customer name is provided
            if(String.isBlank(feedback.Customer_Name__c)) {
                feedback.Customer_Name__c.addError('Customer name is required');
            }
            
            // Validate feedback type is valid
            Set<String> validTypes = new Set<String>{'Bug', 'Feature Request', 'General Inquiry'};
            if(feedback.Feedback_Type__c != null && !validTypes.contains(feedback.Feedback_Type__c)) {
                feedback.Feedback_Type__c.addError('Invalid feedback type');
            }
            
            // Validate priority is valid
            Set<String> validPriorities = new Set<String>{'Low', 'Medium', 'High'};
            if(feedback.Priority__c != null && !validPriorities.contains(feedback.Priority__c)) {
                feedback.Priority__c.addError('Invalid priority value');
            }
        }
    }
    
    public override void afterInsert() {
        super.afterInsert();
        IFeedbackNotifier notifier = (IFeedbackNotifier)Application.context.getFactory(IFeedbackNotifier.class).newInstance();
        notifier.notifyOnNewFeedback((List<Customer_Feedback__c>)Records);
    }
    
    public void changeStatus(String newStatus, fflib_ISObjectUnitOfWork uow) {
        validateStatusTransition(newStatus);
        
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            feedback.Status__c = newStatus;
            uow.registerDirty(feedback);
        }
    }
    
    private void validateStatusTransition(String newStatus) {
        Set<String> validStatuses = new Set<String>{'New', 'In Progress', 'Resolved', 'Closed'};
        if(!validStatuses.contains(newStatus)) {
            throw new DomainException('Invalid status: ' + newStatus);
        }
        
        // Business rule: Can't go from Closed back to other statuses
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            if(feedback.Status__c == 'Closed' && newStatus != 'Closed') {
                throw new DomainException('Cannot change status from Closed to ' + newStatus);
            }
        }
    }
    
    public void assignToAgent(String agentId, fflib_ISObjectUnitOfWork uow) {
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            // Would assign to agent if we had that field
            feedback.Status__c = 'In Progress';
            uow.registerDirty(feedback);
        }
    }
    
    public void escalateFeedback(fflib_ISObjectUnitOfWork uow) {
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            if(feedback.Feedback_Type__c == 'Bug') {
                feedback.Status__c = 'In Progress';
                uow.registerDirty(feedback);
            }
        }
    }
    
    public class DomainException extends Exception {}
} 