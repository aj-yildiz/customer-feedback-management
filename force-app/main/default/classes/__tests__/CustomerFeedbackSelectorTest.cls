@isTest
private class CustomerFeedbackSelectorTest {
    
    @TestSetup
    static void makeData() {
        List<ece__Customer_Feedback__c> testFeedbacks = new List<ece__Customer_Feedback__c>();
        
        testFeedbacks.add(new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer 1',
            ece__Customer_Email__c = 'test1@example.com',
            ece__Feedback_Type__c = 'Bug',
            ece__Description__c = 'Test description 1',
            ece__Status__c = 'New'
        ));
        
        testFeedbacks.add(new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer 2',
            ece__Customer_Email__c = 'test2@example.com',
            ece__Feedback_Type__c = 'Feature Request',
            ece__Description__c = 'Test description 2',
            ece__Status__c = 'In Progress'
        ));
        
        testFeedbacks.add(new ece__Customer_Feedback__c(
            ece__Customer_Name__c = 'Test Customer 3',
            ece__Customer_Email__c = 'test3@example.com',
            ece__Feedback_Type__c = 'General Inquiry',
            ece__Description__c = 'Test description 3',
            ece__Status__c = 'Resolved'
        ));
        
        insert testFeedbacks;
    }
    
    @isTest
    static void testFetchAll() {
        Test.startTest();
        List<ece__Customer_Feedback__c> results = CustomerFeedbackSelector.fetchAll();
        Test.stopTest();
        
        System.assertEquals(3, results.size(), 'Should return all feedback records');
        System.assertNotEquals(null, results[0].ece__Customer_Name__c, 'Customer name should be populated');
    }
    
    @isTest
    static void testSelectById() {
        ece__Customer_Feedback__c testFeedback = [SELECT Id FROM ece__Customer_Feedback__c LIMIT 1];
        
        Test.startTest();
        ece__Customer_Feedback__c result = CustomerFeedbackSelector.fetchById(testFeedback.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return the feedback record');
        System.assertEquals(testFeedback.Id, result.Id, 'Should return correct record');
    }
    
    @isTest
    static void testSelectByStatus() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<ece__Customer_Feedback__c> newFeedbacks = selector.selectByStatus('New');
        List<ece__Customer_Feedback__c> inProgressFeedbacks = selector.selectByStatus('In Progress');
        Test.stopTest();
        
        System.assertEquals(1, newFeedbacks.size(), 'Should return 1 New feedback');
        System.assertEquals(1, inProgressFeedbacks.size(), 'Should return 1 In Progress feedback');
    }
    
    @isTest
    static void testSelectByType() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<ece__Customer_Feedback__c> bugFeedbacks = selector.selectByType('Bug');
        List<ece__Customer_Feedback__c> featureFeedbacks = selector.selectByType('Feature Request');
        Test.stopTest();
        
        System.assertEquals(1, bugFeedbacks.size(), 'Should return 1 Bug feedback');
        System.assertEquals(1, featureFeedbacks.size(), 'Should return 1 Feature Request feedback');
    }
    
    @isTest
    static void testGetSObjectFieldList() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();
        
        System.assert(fields.size() > 0, 'Should return field list');
        System.assert(fields.contains(ece__Customer_Feedback__c.Id), 'Should include Id field');
    }
} 