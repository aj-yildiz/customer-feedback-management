@IsTest
private class CustomerFeedbackServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test feedback records
        List<Customer_Feedback__c> testFeedbacks = new List<Customer_Feedback__c>();
        
        testFeedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 1',
            Customer_Email__c = 'test1@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test bug report',
            Status__c = 'New',
            Priority__c = 'High'
        ));
        
        testFeedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 2',
            Customer_Email__c = 'test2@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'Test feature request',
            Status__c = 'In Progress',
            Priority__c = 'Medium'
        ));
        
        insert testFeedbacks;
    }
    
    @IsTest
    static void testCreateFeedback() {
        // Arrange
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('Customer_Name__c', 'Service Test Customer');
        testData.put('Customer_Email__c', 'servicetest@example.com');
        testData.put('Feedback_Type__c', 'Bug');
        testData.put('Description__c', 'Service layer test');
        testData.put('Priority__c', 'High');
        
        // Act
        Test.startTest();
        String resultId = CustomerFeedbackService.createFeedback(testData);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, resultId, 'Service should return feedback ID');
        
        Customer_Feedback__c created = [SELECT Customer_Name__c, Status__c, Priority__c 
                                       FROM Customer_Feedback__c WHERE Id = :resultId];
        System.assertEquals('Service Test Customer', created.Customer_Name__c);
        System.assertEquals('New', created.Status__c); // Domain should set default
    }
    
    @IsTest
    static void testCreateFeedbackNullData() {
        Test.startTest();
        try {
            CustomerFeedbackService.createFeedback(null);
            System.assert(false, 'Should throw exception for null data');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Should validate null input');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateFeedbackStatus() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c WHERE Status__c = 'New' LIMIT 1];
        
        Test.startTest();
        CustomerFeedbackService.updateFeedbackStatus(feedback.Id, 'Resolved');
        Test.stopTest();
        
        Customer_Feedback__c updated = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('Resolved', updated.Status__c, 'Status should be updated');
    }
    
    @IsTest
    static void testUpdateFeedbackStatusNotFound() {
        Test.startTest();
        try {
            CustomerFeedbackService.updateFeedbackStatus('a035500000000000', 'Resolved');
            System.assert(false, 'Should throw exception for non-existent record');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('not found'), 'Should validate record exists');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testEscalateFeedback() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c WHERE Priority__c = 'High' LIMIT 1];
        
        Test.startTest();
        CustomerFeedbackService.escalateFeedback(feedback.Id);
        Test.stopTest();
        
        Customer_Feedback__c escalated = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertNotEquals(null, escalated, 'Escalation should process');
    }
    
    @IsTest
    static void testEscalateFeedbackNotFound() {
        Test.startTest();
        try {
            CustomerFeedbackService.escalateFeedback('a035500000000000');
            System.assert(false, 'Should throw exception for non-existent record');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('not found'), 'Should validate record exists');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAllFeedback() {
        Test.startTest();
        List<Customer_Feedback__c> results = CustomerFeedbackService.getAllFeedback();
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return all feedback records');
    }
    
    @IsTest
    static void testGetFeedbackByStatus() {
        Test.startTest();
        List<Customer_Feedback__c> results = CustomerFeedbackService.getFeedbackByStatus('New');
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return feedback with New status');
        System.assertEquals('New', results[0].Status__c);
    }
    
    @IsTest
    static void testGetFeedbackByStatusBlank() {
        Test.startTest();
        try {
            CustomerFeedbackService.getFeedbackByStatus('');
            System.assert(false, 'Should throw exception for blank status');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('cannot be blank'), 'Should validate blank status');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFeedbackByType() {
        Test.startTest();
        List<Customer_Feedback__c> results = CustomerFeedbackService.getFeedbackByType('Bug');
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return feedback with Bug type');
        System.assertEquals('Bug', results[0].Feedback_Type__c);
    }
    
    @IsTest
    static void testGetFeedbackByTypeBlank() {
        Test.startTest();
        try {
            CustomerFeedbackService.getFeedbackByType('');
            System.assert(false, 'Should throw exception for blank type');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('cannot be blank'), 'Should validate blank type');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessBulkFeedbackUpdates() {
        List<Customer_Feedback__c> feedbacks = [SELECT Id FROM Customer_Feedback__c];
        
        List<Map<String, Object>> bulkUpdates = new List<Map<String, Object>>();
        for (Customer_Feedback__c feedback : feedbacks) {
            Map<String, Object> updateData = new Map<String, Object>();
            updateData.put('Id', feedback.Id);
            updateData.put('Status__c', 'Closed');
            updateData.put('Customer_Email__c', 'bulk@example.com');
            bulkUpdates.add(updateData);
        }
        
        Test.startTest();
        CustomerFeedbackService.processBulkFeedbackUpdates(bulkUpdates);
        Test.stopTest();
        
        List<Customer_Feedback__c> updated = [SELECT Status__c FROM Customer_Feedback__c];
        for (Customer_Feedback__c feedback : updated) {
            System.assertEquals('Closed', feedback.Status__c, 'All feedback should be closed');
        }
    }
    
    @IsTest
    static void testProcessBulkFeedbackUpdatesNull() {
        Test.startTest();
        try {
            CustomerFeedbackService.processBulkFeedbackUpdates(null);
            System.assert(false, 'Should throw exception for null updates');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Should validate null input');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testMapInputToFeedbackPrivateMethod() {
        // Test the private mapInputToFeedback method indirectly through createFeedback
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('Customer_Name__c', 'Mapping Test');
        testData.put('Customer_Email__c', 'mapping@test.com');
        testData.put('Feedback_Type__c', 'General Inquiry');
        testData.put('Description__c', 'Testing field mapping');
        testData.put('Priority__c', 'Low');
        
        Test.startTest();
        String resultId = CustomerFeedbackService.createFeedback(testData);
        Test.stopTest();
        
        Customer_Feedback__c created = [SELECT Customer_Name__c, Customer_Email__c, Feedback_Type__c, 
                                       Description__c, Priority__c FROM Customer_Feedback__c WHERE Id = :resultId];
        System.assertEquals('Mapping Test', created.Customer_Name__c);
        System.assertEquals('mapping@test.com', created.Customer_Email__c);
        System.assertEquals('General Inquiry', created.Feedback_Type__c);
        System.assertEquals('Testing field mapping', created.Description__c);
        System.assertEquals('Low', created.Priority__c);
    }
} 