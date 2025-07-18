@isTest
private class CustomerFeedbackControllerRefactoredTest {
    
    @TestSetup
    static void makeData() {
        List<ece__Customer_Feedback__c> testFeedbacks = new List<ece__Customer_Feedback__c>();
        
        testFeedbacks.add(new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer 1',
            ece__Customer_Email__c = 'test1@example.com',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test bug description',
            ece__Status__c = 'New'
        ));
        
        testFeedbacks.add(new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer 2',
            ece__Customer_Email__c = 'test2@example.com',
            ece__Feedback_Type__c = 'Feature Request',
            ece__Description__c = 'Test feature description',
            ece__Status__c = 'In Progress'
        ));
        
        insert testFeedbacks;
    }
    
    @isTest
    static void testGetAllFeedback() {
        Test.startTest();
        List<ece__Customer_Feedback__c> results = CustomerFeedbackController.getAllFeedback();
        Test.stopTest();
        
        System.assertEquals(2, results.size(), 'Should return all feedback records');
        System.assertNotEquals(null, results[0].ece__Customer_Name__c, 'Customer name should be populated');
    }
    
    @isTest
    static void testCreateFeedback() {
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('ece__Customer_Name__c', 'Test Customer New');
        testData.put('ece__Customer_Email__c', 'testnew@example.com');
        testData.put('ece__Feedback_Type__c', 'General Inquiry');
        testData.put('ece__Description__c', 'Test inquiry description');
        testData.put('ece__Status__c', 'New');
        
        Test.startTest();
        String result = CustomerFeedbackController.createFeedback(testData);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return record Id');
        System.assert(result.length() > 0, 'Record Id should not be empty');
        
        ece__Customer_Feedback__c created = [SELECT ece__Customer_Name__c FROM ece__Customer_Feedback__c WHERE Id = :result];
        System.assertEquals('Test Customer New', created.ece__Customer_Name__c, 'Customer name should match');
    }
    
    @isTest
    static void testCreateFeedbackNullData() {
        Test.startTest();
        try {
            CustomerFeedbackController.createFeedback(null);
            System.assert(false, 'Should have thrown exception for null data');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('cannot be null'), 'Should validate null data');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateFeedbackStatus() {
        ece__Customer_Feedback__c feedback = [SELECT Id FROM ece__Customer_Feedback__c WHERE ece__Status__c = 'New' LIMIT 1];
        
        Test.startTest();
        CustomerFeedbackController.updateFeedbackStatus(feedback.Id, 'In Progress');
        Test.stopTest();
        
        feedback = [SELECT ece__Status__c FROM ece__Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.ece__Status__c, 'Status should be updated');
    }
    
    @isTest
    static void testUpdateFeedbackStatusInvalidId() {
        Test.startTest();
        try {
            CustomerFeedbackController.updateFeedbackStatus('001000000000000', 'In Progress');
            System.assert(false, 'Should have thrown exception for invalid Id');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('not found'), 'Should validate record exists');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetFeedbackByStatus() {
        Test.startTest();
        List<ece__Customer_Feedback__c> newFeedbacks = CustomerFeedbackController.getFeedbackByStatus('New');
        List<ece__Customer_Feedback__c> inProgressFeedbacks = CustomerFeedbackController.getFeedbackByStatus('In Progress');
        Test.stopTest();
        
        System.assertEquals(1, newFeedbacks.size(), 'Should return 1 New feedback');
        System.assertEquals(1, inProgressFeedbacks.size(), 'Should return 1 In Progress feedback');
    }
    
    @isTest
    static void testGetFeedbackByType() {
        Test.startTest();
        List<ece__Customer_Feedback__c> bugFeedbacks = CustomerFeedbackController.getFeedbackByType('Bug');
        List<ece__Customer_Feedback__c> featureFeedbacks = CustomerFeedbackController.getFeedbackByType('Feature Request');
        Test.stopTest();
        
        System.assertEquals(1, bugFeedbacks.size(), 'Should return 1 Bug feedback');
        System.assertEquals(1, featureFeedbacks.size(), 'Should return 1 Feature Request feedback');
    }
    
    @isTest
    static void testEscalateFeedback() {
        ece__Customer_Feedback__c feedback = [SELECT Id FROM ece__Customer_Feedback__c WHERE ece__Feedback_Type__c = 'Bug' LIMIT 1];
        
        Test.startTest();
        CustomerFeedbackController.escalateFeedback(feedback.Id);
        Test.stopTest();
        
        feedback = [SELECT ece__Status__c FROM ece__Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.ece__Status__c, 'Bug should be escalated to In Progress');
    }
} 