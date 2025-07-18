@isTest
private class CustomerFeedbackDomainTest {
    
    @isTest
    static void testOnApplyDefaults() {
        // Create feedback without status
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description'
            // Status__c deliberately not set
        );
        
        Test.startTest();
        insert feedback; // This should trigger the domain logic via trigger
        Test.stopTest();
        
        // Refresh the record to see the applied defaults
        feedback = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('New', feedback.Status__c, 'Status should default to New');
    }
    
    @isTest
    static void testOnValidateDescriptionRequired() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug'
            // Description__c deliberately not set
        );
        
        Test.startTest();
        try {
            insert feedback;
            System.assert(false, 'Should have thrown validation error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Description is required'), 
                         'Should validate description is required');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testOnValidateEmailRequiredWhenClosed() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'Closed'
            // Customer_Email__c deliberately not set
        );
        
        Test.startTest();
        try {
            insert feedback;
            System.assert(false, 'Should have thrown validation error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Email is required when closing'), 
                         'Should validate email is required when status is closed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testChangeStatusValid() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'New'
        );
        insert feedback;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
        domain.changeStatus('In Progress', uow);
        uow.commitWork();
        Test.stopTest();
        
        feedback = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.Status__c, 'Status should be updated');
    }
    
    @isTest
    static void testChangeStatusInvalid() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'New'
        );
        insert feedback;
        
        Test.startTest();
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
            domain.changeStatus('Invalid Status', uow);
            System.assert(false, 'Should have thrown domain exception');
        } catch (CustomerFeedbackDomain.DomainException e) {
            System.assert(e.getMessage().contains('Invalid status'), 
                         'Should throw domain exception for invalid status');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testChangeStatusFromClosed() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'Closed'
        );
        insert feedback;
        
        Test.startTest();
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
            domain.changeStatus('New', uow);
            System.assert(false, 'Should have thrown domain exception');
        } catch (CustomerFeedbackDomain.DomainException e) {
            System.assert(e.getMessage().contains('Cannot change status from Closed'), 
                         'Should not allow changing from Closed status');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testEscalateFeedback() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'New'
        );
        insert feedback;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
        domain.escalateFeedback(uow);
        uow.commitWork();
        Test.stopTest();
        
        feedback = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.Status__c, 'Bug feedback should be escalated to In Progress');
    }
    
    @isTest
    static void testAssignToAgent() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'New'
        );
        insert feedback;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
        domain.assignToAgent('someAgentId', uow);
        uow.commitWork();
        Test.stopTest();
        
        feedback = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.Status__c, 'Assigned feedback should be In Progress');
    }
} 