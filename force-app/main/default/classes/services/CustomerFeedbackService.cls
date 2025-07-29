public virtual class CustomerFeedbackService {
    
    /**
     * Service method to create new customer feedback
     * Orchestrates the complete business process
     */
    public static String createFeedback(Map<String, Object> recordData) {
        // Input validation (business rule)
        if (recordData == null) {
            throw new CustomerFeedbackServiceException('Record data cannot be null');
        }
        
        // Create feedback record from input data
        Customer_Feedback__c newFeedback = mapInputToFeedback(recordData);
        
        // Use Unit of Work for transaction management
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerNew(newFeedback);
        uow.commitWork();
        
        return newFeedback.Id;
    }
    
    /**
     * Service method to update feedback status with business rules
     */
    public static void updateFeedbackStatus(Id feedbackId, String newStatus) {
        // Use Selector to get the record (data access)
        Customer_Feedback__c feedback = ((CustomerFeedbackSelector) 
            Application.Selector.newInstance(Customer_Feedback__c.SObjectType))
            .selectById(feedbackId);
            
        if (feedback == null) {
            throw new CustomerFeedbackServiceException('Feedback record not found');
        }
        
        // Use Domain for business logic and Unit of Work for transaction
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
        domain.changeStatus(newStatus, uow);
        uow.commitWork();
    }
    
    /**
     * Service method to escalate feedback (complex business process)
     */
    public static void escalateFeedback(Id feedbackId) {
        // Get feedback record
        Customer_Feedback__c feedback = ((CustomerFeedbackSelector) 
            Application.Selector.newInstance(Customer_Feedback__c.SObjectType))
            .selectById(feedbackId);
            
        if (feedback == null) {
            throw new CustomerFeedbackServiceException('Feedback record not found');
        }
        
        // Business process: Escalation logic
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
        
        // Apply escalation business rules
        domain.escalateFeedback(uow);
        
        // Additional business logic could go here:
        // - Create case records
        // - Send notifications
        // - Update related records
        
        uow.commitWork();
    }
    
    /**
     * Service method to get all feedback (simple delegation to selector)
     */
    public static List<Customer_Feedback__c> getAllFeedback() {
        return ((CustomerFeedbackSelector) 
            Application.Selector.newInstance(Customer_Feedback__c.SObjectType))
            .selectAllWithOptionalCriteria();
    }
    
    /**
     * Service method to get feedback by status with business rules
     */
    public static List<Customer_Feedback__c> getFeedbackByStatus(String status) {
        // Business validation
        if (String.isBlank(status)) {
            throw new CustomerFeedbackServiceException('Status cannot be blank');
        }
        
        return ((CustomerFeedbackSelector) 
            Application.Selector.newInstance(Customer_Feedback__c.SObjectType))
            .selectByStatus(status);
    }
    
    /**
     * Service method to get feedback by type with business rules
     */
    public static List<Customer_Feedback__c> getFeedbackByType(String feedbackType) {
        // Business validation
        if (String.isBlank(feedbackType)) {
            throw new CustomerFeedbackServiceException('Feedback type cannot be blank');
        }
        
        return ((CustomerFeedbackSelector) 
            Application.Selector.newInstance(Customer_Feedback__c.SObjectType))
            .selectByType(feedbackType);
    }
    
    /**
     * Complex business process: Process bulk feedback updates
     */
    public static void processBulkFeedbackUpdates(List<Map<String, Object>> feedbackUpdates) {
        if (feedbackUpdates == null) {
            throw new CustomerFeedbackServiceException('Feedback updates cannot be null');
        }
        
        if (feedbackUpdates.isEmpty()) {
            return;
        }
        
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        for (Map<String, Object> updateData : feedbackUpdates) {
            Id feedbackId = (Id) updateData.get('Id');
            String newStatus = (String) updateData.get('Status__c');
            String newEmail = (String) updateData.get('Customer_Email__c');
            
            if (feedbackId != null && String.isNotBlank(newStatus)) {
                Customer_Feedback__c feedback = ((CustomerFeedbackSelector) 
                    Application.Selector.newInstance(Customer_Feedback__c.SObjectType))
                    .selectById(feedbackId);
                    
                if (feedback != null) {
                    // Update fields
                    feedback.Status__c = newStatus;
                    if (String.isNotBlank(newEmail)) {
                        feedback.Customer_Email__c = newEmail;
                    }
                    
                    CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
                    domain.changeStatus(newStatus, uow);
                }
            }
        }
        
        uow.commitWork();
    }
    
    // PRIVATE HELPER METHODS
    
    /**
     * Helper method to map input data to Customer_Feedback__c record
     */
    private static Customer_Feedback__c mapInputToFeedback(Map<String, Object> recordData) {
        Customer_Feedback__c newFeedback = new Customer_Feedback__c();
        
        // Map the recordData to Customer_Feedback__c fields
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
        
        return newFeedback;
    }
    
    // EXCEPTION CLASS
    public class CustomerFeedbackServiceException extends Exception {}
} 