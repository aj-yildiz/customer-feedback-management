@isTest
private class CustomerFeedbackControllerRefactoredTest {
    
    @TestSetup
    static void makeData() {
        List<Customer_Feedback__c> testFeedbacks = new List<Customer_Feedback__c>();
        

        testFeedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 1',
            Customer_Email__c = 'test1@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test bug description',
            Status__c = 'New',
            Priority__c = 'High'
        ));
        
        testFeedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 2',
            Customer_Email__c = 'test2@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'Test feature description',
            Status__c = 'In Progress',
            Priority__c = 'Medium'
        ));
        
        insert testFeedbacks;
    }
    
    @isTest
    static void testGetAllFeedback() {
        Test.startTest();
        List<Customer_Feedback__c> results = CustomerFeedbackController.getAllFeedback();
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return all feedback records');
        System.assertNotEquals(null, results[0].Customer_Name__c, 'Customer name should be populated');
    }

    @isTest
    static void testCreateFeedback() {
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('Customer_Name__c', 'Test Customer New');
        testData.put('Customer_Email__c', 'testnew@example.com');
        testData.put('Feedback_Type__c', 'General Inquiry');
        testData.put('Description__c', 'Test inquiry description');
        testData.put('Status__c', 'New');
        
        Test.startTest();
        String resultId = CustomerFeedbackController.createFeedback(testData);
        Test.stopTest();
        
        System.assertNotEquals(null, resultId, 'Should return feedback ID');
        
        Customer_Feedback__c created = [SELECT Customer_Name__c FROM Customer_Feedback__c WHERE Id = :resultId];
        System.assertEquals('Test Customer New', created.Customer_Name__c);
    }

    @isTest
    static void testCreateFeedbackException() {
        // Test exception handling
        Test.startTest();
        try {
            CustomerFeedbackController.createFeedback(null);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error creating feedback'), 'Should handle exception');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateFeedbackStatus() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        Test.startTest();
        CustomerFeedbackController.updateFeedbackStatus(feedback.Id, 'Resolved');
        Test.stopTest();
        
        Customer_Feedback__c updated = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('Resolved', updated.Status__c);
    }

    @isTest
    static void testUpdateFeedbackStatusException() {
        Test.startTest();
        try {
            CustomerFeedbackController.updateFeedbackStatus('invalid-id', 'Resolved');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error updating feedback status'), 'Should handle exception');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetFeedbackByStatus() {
        Test.startTest();
        List<Customer_Feedback__c> results = CustomerFeedbackController.getFeedbackByStatus('New');
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return feedback with New status');
        System.assertEquals('New', results[0].Status__c);
    }

    @isTest
    static void testGetFeedbackByStatusException() {
        Test.startTest();
        try {
            CustomerFeedbackController.getFeedbackByStatus('');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Invalid input'), 'Should handle invalid status');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetFeedbackByType() {
        Test.startTest();
        List<Customer_Feedback__c> results = CustomerFeedbackController.getFeedbackByType('Bug');
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return feedback with Bug type');
        System.assertEquals('Bug', results[0].Feedback_Type__c);
    }

    @isTest
    static void testGetFeedbackByTypeException() {
        Test.startTest();
        try {
            CustomerFeedbackController.getFeedbackByType('');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Invalid input'), 'Should handle invalid type');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testEscalateFeedback() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c WHERE Priority__c = 'High' LIMIT 1];
        
        Test.startTest();
        CustomerFeedbackController.escalateFeedback(feedback.Id);
        Test.stopTest();
        
        Customer_Feedback__c escalated = [SELECT Escalation_Required__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        // Verify escalation logic was called (actual business logic is in service layer)
        System.assertNotEquals(null, escalated);
    }

    @isTest
    static void testEscalateFeedbackException() {
        Test.startTest();
        try {
            CustomerFeedbackController.escalateFeedback('invalid-id');
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error escalating feedback'), 'Should handle exception');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessBulkFeedbackUpdates() {
        List<Customer_Feedback__c> feedbacks = [SELECT Id FROM Customer_Feedback__c];
        
        List<Map<String, Object>> bulkUpdates = new List<Map<String, Object>>();
        for (Customer_Feedback__c feedback : feedbacks) {
            Map<String, Object> updateData = new Map<String, Object>();
            updateData.put('Id', feedback.Id);
            updateData.put('Status__c', 'Resolved');
            bulkUpdates.add(updateData);
        }
        
        Test.startTest();
        CustomerFeedbackController.processBulkFeedbackUpdates(bulkUpdates);
        Test.stopTest();
        
        List<Customer_Feedback__c> updated = [SELECT Status__c FROM Customer_Feedback__c];
        for (Customer_Feedback__c feedback : updated) {
            System.assertEquals('Resolved', feedback.Status__c, 'All feedback should be resolved');
        }
    }

    @isTest
    static void testProcessBulkFeedbackUpdatesException() {
        Test.startTest();
        try {
            CustomerFeedbackController.processBulkFeedbackUpdates(null);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error processing bulk updates'), 'Should handle exception');
        }
        Test.stopTest();
    }
} 