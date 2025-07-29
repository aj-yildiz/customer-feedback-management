@isTest
private class CustomerFeedbackDomainTest {
    
    @isTest
    static void testOnApplyDefaults() {
        // Create feedback without status and priority
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description'
            // Status__c and Priority__c deliberately not set
        );
        
        Test.startTest();
        insert feedback; // This should trigger the domain logic via trigger
        Test.stopTest();
        
        // Refresh the record to see the applied defaults
        feedback = [SELECT Status__c, Priority__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('New', feedback.Status__c, 'Status should default to New');
        System.assertEquals('Medium', feedback.Priority__c, 'Priority should default to Medium');
    }

    @isTest
    static void testOnApplyDefaultsWithExistingValues() {
        // Create feedback with status and priority already set
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'In Progress',
            Priority__c = 'High'
        );
        
        Test.startTest();
        insert feedback;
        Test.stopTest();
        
        // Refresh the record - existing values should be preserved
        feedback = [SELECT Status__c, Priority__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.Status__c, 'Existing status should be preserved');
        System.assertEquals('High', feedback.Priority__c, 'Existing priority should be preserved');
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
    static void testOnValidateInvalidFeedbackType() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Invalid Type',
            Description__c = 'Test description',
            Status__c = 'New'
        );
        
        Test.startTest();
        try {
            insert feedback;
            System.assert(false, 'Should have thrown validation error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Invalid feedback type'), 
                         'Should validate feedback type');
        }
        Test.stopTest();
    }

    @isTest
    static void testOnValidateValidFeedbackTypes() {
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        
        // Test all valid feedback types
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 1',
            Customer_Email__c = 'test1@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Bug description'
        ));
        
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 2',
            Customer_Email__c = 'test2@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'Feature description'
        ));
        
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 3',
            Customer_Email__c = 'test3@example.com',
            Feedback_Type__c = 'General Inquiry',
            Description__c = 'General description'
        ));
        
        Test.startTest();
        insert feedbacks; // Should not throw any validation errors
        Test.stopTest();
        
        List<Customer_Feedback__c> inserted = [SELECT Feedback_Type__c FROM Customer_Feedback__c WHERE Id IN :feedbacks];
        System.assertEquals(3, inserted.size(), 'All valid feedback types should be accepted');
    }

    @isTest
    static void testOnValidateInvalidPriority() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Priority__c = 'Invalid Priority'
        );
        
        Test.startTest();
        try {
            insert feedback;
            System.assert(false, 'Should have thrown validation error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Invalid priority value'), 
                         'Should validate priority value');
        }
        Test.stopTest();
    }

    @isTest
    static void testOnValidateValidPriorities() {
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        
        // Test all valid priorities
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 1',
            Customer_Email__c = 'test1@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Low priority feedback',
            Priority__c = 'Low'
        ));
        
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 2',
            Customer_Email__c = 'test2@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Medium priority feedback',
            Priority__c = 'Medium'
        ));
        
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 3',
            Customer_Email__c = 'test3@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'High priority feedback',
            Priority__c = 'High'
        ));
        
        Test.startTest();
        insert feedbacks; // Should not throw any validation errors
        Test.stopTest();
        
        List<Customer_Feedback__c> inserted = [SELECT Priority__c FROM Customer_Feedback__c WHERE Id IN :feedbacks];
        System.assertEquals(3, inserted.size(), 'All valid priorities should be accepted');
    }

    @isTest
    static void testOnValidateNullFeedbackTypeAndPriority() {
        // Test that null feedback type and priority are allowed (will get defaults)
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Description__c = 'Test description'
            // Feedback_Type__c and Priority__c are null
        );
        
        Test.startTest();
        insert feedback; // Should not throw validation errors
        Test.stopTest();
        
        Customer_Feedback__c inserted = [SELECT Feedback_Type__c, Priority__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        // Null values should be allowed for these fields
        System.assertEquals('Medium', inserted.Priority__c, 'Priority should default to Medium');
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
    static void testChangeStatusAllValidTransitions() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'New'
        );
        insert feedback;
        
        // Test all valid status transitions
        List<String> validStatuses = new List<String>{'New', 'In Progress', 'Resolved', 'Closed'};
        
        for (String status : validStatuses) {
            Test.startTest();
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
            domain.changeStatus(status, uow);
            uow.commitWork();
            Test.stopTest();
            
            feedback = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
            System.assertEquals(status, feedback.Status__c, 'Status should be updated to ' + status);
        }
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
    static void testChangeStatusFromClosedToClosedAllowed() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description',
            Status__c = 'Closed'
        );
        insert feedback;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(new List<Customer_Feedback__c>{feedback});
        domain.changeStatus('Closed', uow); // Should be allowed
        uow.commitWork();
        Test.stopTest();
        
        feedback = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('Closed', feedback.Status__c, 'Closed to Closed should be allowed');
    }
    
    @isTest
    static void testEscalateFeedbackBug() {
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
    static void testEscalateFeedbackNonBug() {
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Feature Request',
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
        System.assertEquals('New', feedback.Status__c, 'Non-Bug feedback should remain unchanged');
    }

    @isTest
    static void testEscalateFeedbackBulk() {
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        
        // Mix of Bug and non-Bug feedback
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 1',
            Customer_Email__c = 'test1@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Bug description',
            Status__c = 'New'
        ));
        
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 2',
            Customer_Email__c = 'test2@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'Feature description',
            Status__c = 'New'
        ));
        
        insert feedbacks;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(feedbacks);
        domain.escalateFeedback(uow);
        uow.commitWork();
        Test.stopTest();
        
        List<Customer_Feedback__c> updated = [SELECT Status__c, Feedback_Type__c FROM Customer_Feedback__c WHERE Id IN :feedbacks ORDER BY Feedback_Type__c];
        System.assertEquals('In Progress', updated[0].Status__c, 'Bug should be escalated');
        System.assertEquals('New', updated[1].Status__c, 'Feature Request should remain New');
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

    @isTest
    static void testAssignToAgentBulk() {
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        
        for (Integer i = 0; i < 3; i++) {
            feedbacks.add(new Customer_Feedback__c(
                Customer_Name__c = 'Test Customer ' + i,
                Customer_Email__c = 'test' + i + '@example.com',
                Feedback_Type__c = 'Bug',
                Description__c = 'Test description ' + i,
                Status__c = 'New'
            ));
        }
        insert feedbacks;
        
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        CustomerFeedbackDomain domain = new CustomerFeedbackDomain(feedbacks);
        domain.assignToAgent('bulkAgentId', uow);
        uow.commitWork();
        Test.stopTest();
        
        List<Customer_Feedback__c> updated = [SELECT Status__c FROM Customer_Feedback__c WHERE Id IN :feedbacks];
        for (Customer_Feedback__c feedback : updated) {
            System.assertEquals('In Progress', feedback.Status__c, 'All feedback should be assigned');
        }
    }

    @isTest
    static void testConstructorInnerClass() {
        // Test the inner Constructor class
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description'
        ));
        
        Test.startTest();
        CustomerFeedbackDomain.Constructor constructor = new CustomerFeedbackDomain.Constructor();
        fflib_SObjectDomain domain = constructor.construct((List<SObject>) feedbacks);
        Test.stopTest();
        
        System.assertNotEquals(null, domain, 'Constructor should create domain instance');
        System.assert(domain instanceof CustomerFeedbackDomain, 'Should be CustomerFeedbackDomain instance');
    }

    @isTest
    static void testDomainExceptionClass() {
        Test.startTest();
        try {
            throw new CustomerFeedbackDomain.DomainException('Test exception message');
        } catch (CustomerFeedbackDomain.DomainException e) {
            System.assertEquals('Test exception message', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }
} 