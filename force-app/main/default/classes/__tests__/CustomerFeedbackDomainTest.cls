@isTest
private class CustomerFeedbackDomainTest {
    
    @isTest
    static void testOnApplyDefaults() {
        // Create feedback without status
        ece__Customer_Feedback__c feedback = new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer',
            ece__Customer_Email__c = 'test@example.com',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test description'
            // ece__Status__c deliberately not set
        );
        
        Test.startTest();
        insert feedback; // This should trigger the domain logic via trigger
        Test.stopTest();
        
        // Refresh the record to see the applied defaults
        feedback = [SELECT ece__Status__c FROM ece__Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('New', feedback.ece__Status__c, 'Status should default to New');
    }
    
    @isTest
    static void testOnValidateDescriptionRequired() {
        ece__Customer_Feedback__c feedback = new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer',
            ece__Customer_Email__c = 'test@example.com',
            ece__Feedback_Type__c = 'Bug'
            // ece__Description__c deliberately not set
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
        ece__Customer_Feedback__c feedback = new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test description',
            ece__Status__c = 'Closed'
            // ece__Customer_Email__c deliberately not set
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
        ece__Customer_Feedback__c feedback = new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer',
            ece__Customer_Email__c = 'test@example.com',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test description',
            ece__Status__c = 'New'
        );
        insert feedback;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<ece__Customer_Feedback__c>{feedback});
        domain.changeStatus('In Progress', uow);
        uow.commitWork();
        Test.stopTest();
        
        feedback = [SELECT ece__Status__c FROM ece__Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.ece__Status__c, 'Status should be updated');
    }
    
    @isTest
    static void testChangeStatusInvalid() {
        ece__Customer_Feedback__c feedback = new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer',
            ece__Customer_Email__c = 'test@example.com',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test description',
            ece__Status__c = 'New'
        );
        insert feedback;
        
        Test.startTest();
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<ece__Customer_Feedback__c>{feedback});
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
        ece__Customer_Feedback__c feedback = new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer',
            ece__Customer_Email__c = 'test@example.com',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test description',
            ece__Status__c = 'Closed'
        );
        insert feedback;
        
        Test.startTest();
        try {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<ece__Customer_Feedback__c>{feedback});
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
        ece__Customer_Feedback__c feedback = new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer',
            ece__Customer_Email__c = 'test@example.com',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test description',
            ece__Status__c = 'New'
        );
        insert feedback;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<ece__Customer_Feedback__c>{feedback});
        domain.escalateFeedback(uow);
        uow.commitWork();
        Test.stopTest();
        
        feedback = [SELECT ece__Status__c FROM ece__Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.ece__Status__c, 'Bug feedback should be escalated to In Progress');
    }
    
    @isTest
    static void testAssignToAgent() {
        ece__Customer_Feedback__c feedback = new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer',
            ece__Customer_Email__c = 'test@example.com',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test description',
            ece__Status__c = 'New'
        );
        insert feedback;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<ece__Customer_Feedback__c>{feedback});
        domain.assignToAgent('someAgentId', uow);
        uow.commitWork();
        Test.stopTest();
        
        feedback = [SELECT ece__Status__c FROM ece__Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.ece__Status__c, 'Assigned feedback should be In Progress');
    }
} 