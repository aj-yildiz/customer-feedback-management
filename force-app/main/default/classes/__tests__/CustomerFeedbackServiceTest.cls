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
        System.assertEquals('New', created.Status__c, 'Domain should set default status');
    }
    
    @IsTest
    static void testCreateFeedbackWithNullData() {
        // Act & Assert
        Test.startTest();
        try {
            CustomerFeedbackService.createFeedback(null);
            System.assert(false, 'Should have thrown exception');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('Record data cannot be null'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAllFeedback() {
        // Act
        Test.startTest();
        List<Customer_Feedback__c> results = CustomerFeedbackService.getAllFeedback();
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, results.size(), 'Should return all test feedback');
    }
    
    @IsTest
    static void testGetFeedbackByStatus() {
        // Act
        Test.startTest();
        List<Customer_Feedback__c> newFeedbacks = CustomerFeedbackService.getFeedbackByStatus('New');
        List<Customer_Feedback__c> inProgressFeedbacks = CustomerFeedbackService.getFeedbackByStatus('In Progress');
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, newFeedbacks.size(), 'Should return only New feedback');
        System.assertEquals(1, inProgressFeedbacks.size(), 'Should return only In Progress feedback');
        System.assertEquals('New', newFeedbacks[0].Status__c);
        System.assertEquals('In Progress', inProgressFeedbacks[0].Status__c);
    }
    
    @IsTest
    static void testGetFeedbackByStatusWithBlankStatus() {
        // Act & Assert
        Test.startTest();
        try {
            CustomerFeedbackService.getFeedbackByStatus('');
            System.assert(false, 'Should have thrown exception');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('Status cannot be blank'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetFeedbackByType() {
        // Act
        Test.startTest();
        List<Customer_Feedback__c> bugFeedbacks = CustomerFeedbackService.getFeedbackByType('Bug');
        List<Customer_Feedback__c> featureFeedbacks = CustomerFeedbackService.getFeedbackByType('Feature Request');
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, bugFeedbacks.size(), 'Should return only Bug feedback');
        System.assertEquals(1, featureFeedbacks.size(), 'Should return only Feature Request feedback');
        System.assertEquals('Bug', bugFeedbacks[0].Feedback_Type__c);
        System.assertEquals('Feature Request', featureFeedbacks[0].Feedback_Type__c);
    }
    
    @IsTest
    static void testGetFeedbackByTypeWithBlankType() {
        // Act & Assert
        Test.startTest();
        try {
            CustomerFeedbackService.getFeedbackByType('');
            System.assert(false, 'Should have thrown exception');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('Feedback type cannot be blank'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateFeedbackStatus() {
        // Arrange
        Customer_Feedback__c testFeedback = [SELECT Id FROM Customer_Feedback__c WHERE Status__c = 'New' LIMIT 1];
        
        // Act
        Test.startTest();
        CustomerFeedbackService.updateFeedbackStatus(testFeedback.Id, 'In Progress');
        Test.stopTest();
        
        // Assert
        Customer_Feedback__c updated = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :testFeedback.Id];
        System.assertEquals('In Progress', updated.Status__c, 'Status should be updated');
    }
    
    @IsTest
    static void testUpdateFeedbackStatusWithInvalidId() {
        // Arrange
        Id fakeId = fflib_IDGenerator.generate(Customer_Feedback__c.SObjectType);
        
        // Act & Assert
        Test.startTest();
        try {
            CustomerFeedbackService.updateFeedbackStatus(fakeId, 'In Progress');
            System.assert(false, 'Should have thrown exception');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('Feedback record not found'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testEscalateFeedback() {
        // Arrange
        Customer_Feedback__c testFeedback = [SELECT Id FROM Customer_Feedback__c WHERE Feedback_Type__c = 'Bug' LIMIT 1];
        
        // Act
        Test.startTest();
        CustomerFeedbackService.escalateFeedback(testFeedback.Id);
        Test.stopTest();
        
        // Assert
        Customer_Feedback__c escalated = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :testFeedback.Id];
        System.assertEquals('In Progress', escalated.Status__c, 'Bug feedback should be escalated to In Progress');
    }
    
    @IsTest
    static void testEscalateFeedbackWithInvalidId() {
        // Arrange
        Id fakeId = fflib_IDGenerator.generate(Customer_Feedback__c.SObjectType);
        
        // Act & Assert
        Test.startTest();
        try {
            CustomerFeedbackService.escalateFeedback(fakeId);
            System.assert(false, 'Should have thrown exception');
        } catch (CustomerFeedbackService.CustomerFeedbackServiceException e) {
            System.assert(e.getMessage().contains('Feedback record not found'));
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessBulkFeedbackUpdates() {
        // Arrange
        List<Customer_Feedback__c> testFeedbacks = [SELECT Id FROM Customer_Feedback__c];
        List<Map<String, Object>> updateData = new List<Map<String, Object>>();
        
        for (Customer_Feedback__c feedback : testFeedbacks) {
            updateData.add(new Map<String, Object>{
                'Id' => feedback.Id,
                'Status__c' => 'Resolved'
            });
        }
        
        // Act
        Test.startTest();
        CustomerFeedbackService.processBulkFeedbackUpdates(updateData);
        Test.stopTest();
        
        // Assert
        List<Customer_Feedback__c> updatedFeedbacks = [SELECT Status__c FROM Customer_Feedback__c];
        for (Customer_Feedback__c feedback : updatedFeedbacks) {
            System.assertEquals('Resolved', feedback.Status__c, 'All feedback should be updated to Resolved');
        }
    }
    
    @IsTest
    static void testProcessBulkFeedbackUpdatesWithEmptyList() {
        // Act
        Test.startTest();
        CustomerFeedbackService.processBulkFeedbackUpdates(new List<Map<String, Object>>());
        CustomerFeedbackService.processBulkFeedbackUpdates(null);
        Test.stopTest();
        
        // Assert - Should not throw any exceptions
        System.assert(true, 'Should handle empty/null lists gracefully');
    }
} 