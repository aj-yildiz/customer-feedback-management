@isTest
private class CustomerFeedbackControllerTest {
    
    @TestSetup
    static void makeData() {
        List<Customer_Feedback__c> testFeedbacks = new List<Customer_Feedback__c>();
        
        testFeedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 1',
            Customer_Email__c = 'test1@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test bug description',
            Status__c = 'New'
        ));
        
        testFeedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 2',
            Customer_Email__c = 'test2@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'Test feature description',
            Status__c = 'In Progress'
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
        System.assertNotEquals(null, results[0].Customer_Email__c, 'Customer email should be populated');
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
        String result = CustomerFeedbackController.createFeedback(testData);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return record Id');
        System.assert(result.length() > 0, 'Record Id should not be empty');
        
        Customer_Feedback__c created = [SELECT Customer_Name__c FROM Customer_Feedback__c WHERE Id = :result];
        System.assertEquals('Test Customer New', created.Customer_Name__c, 'Customer name should match');
    }
    
    @isTest
    static void testUpdateFeedbackStatus() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c WHERE Status__c = 'New' LIMIT 1];
        
        Test.startTest();
        CustomerFeedbackController.updateFeedbackStatus(feedback.Id, 'In Progress');
        Test.stopTest();
        
        Customer_Feedback__c updatedRecord = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', updatedRecord.Status__c, 'Status should be updated');
    }
    
    @isTest
    static void testGetFeedbackByStatus() {
        Test.startTest();
        List<Customer_Feedback__c> newFeedbacks = CustomerFeedbackController.getFeedbackByStatus('New');
        List<Customer_Feedback__c> inProgressFeedbacks = CustomerFeedbackController.getFeedbackByStatus('In Progress');
        Test.stopTest();
        
        System.assertEquals(1, newFeedbacks.size(), 'Should return 1 New feedback');
        System.assertEquals(1, inProgressFeedbacks.size(), 'Should return 1 In Progress feedback');
    }
    
    @isTest
    static void testGetFeedbackByType() {
        Test.startTest();
        List<Customer_Feedback__c> bugFeedbacks = CustomerFeedbackController.getFeedbackByType('Bug');
        List<Customer_Feedback__c> featureFeedbacks = CustomerFeedbackController.getFeedbackByType('Feature Request');
        Test.stopTest();
        
        System.assertEquals(1, bugFeedbacks.size(), 'Should return 1 Bug feedback');
        System.assertEquals(1, featureFeedbacks.size(), 'Should return 1 Feature Request feedback');
    }
    
    @isTest
    static void testEscalateFeedback() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c WHERE Feedback_Type__c = 'Bug' LIMIT 1];
        
        Test.startTest();
        CustomerFeedbackController.escalateFeedback(feedback.Id);
        Test.stopTest();
        
        feedback = [SELECT Status__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('In Progress', feedback.Status__c, 'Bug should be escalated to In Progress');
    }
}
