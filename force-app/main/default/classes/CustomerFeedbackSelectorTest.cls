@isTest
private class CustomerFeedbackSelectorTest {
    
    @TestSetup
    static void makeData() {
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        
        // Create diverse test data
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 1',
            Customer_Email__c = 'test1@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Bug description',
            Status__c = 'New',
            Priority__c = 'High'
        ));
        
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 2',
            Customer_Email__c = 'test2@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'Feature description',
            Status__c = 'In Progress',
            Priority__c = 'Medium'
        ));
        
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer 3',
            Customer_Email__c = 'test3@example.com',
            Feedback_Type__c = 'General Inquiry',
            Description__c = 'General description',
            Status__c = 'Resolved',
            Priority__c = 'Low'
        ));
        
        insert feedbacks;
    }
    
    @isTest
    static void testDefaultConstructor() {
        Test.startTest();
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        Test.stopTest();
        
        System.assertNotEquals(null, selector, 'Default constructor should work');
        System.assertEquals(Customer_Feedback__c.SObjectType, selector.getSObjectType(), 'Should return correct SObject type');
    }
    
    @isTest
    static void testParameterizedConstructor() {
        // Test the uncovered constructor lines 17-18
        Test.startTest();
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector(true, true, true);
        Test.stopTest();
        
        System.assertNotEquals(null, selector, 'Parameterized constructor should work');
        System.assertEquals(Customer_Feedback__c.SObjectType, selector.getSObjectType(), 'Should return correct SObject type');
    }
    
    @isTest
    static void testParameterizedConstructorAllFalse() {
        // Test with different parameter combinations
        Test.startTest();
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector(false, false, false);
        Test.stopTest();
        
        System.assertNotEquals(null, selector, 'Parameterized constructor with false values should work');
    }
    
    @isTest
    static void testGetSObjectFieldList() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();
        
        System.assertNotEquals(null, fields, 'Field list should not be null');
        System.assert(fields.size() > 0, 'Should return field list');
        System.assert(fields.contains(Customer_Feedback__c.Id), 'Should contain Id field');
        System.assert(fields.contains(Customer_Feedback__c.Customer_Name__c), 'Should contain Customer_Name__c field');
    }
    
    @isTest
    static void testGetSObjectType() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        Schema.SObjectType objectType = selector.getSObjectType();
        Test.stopTest();
        
        System.assertEquals(Customer_Feedback__c.SObjectType, objectType, 'Should return Customer_Feedback__c SObjectType');
    }
    
    @isTest
    static void testFetchAllStatic() {
        // Test the static fetchAll method - line 48-49
        Test.startTest();
        List<Customer_Feedback__c> results = CustomerFeedbackSelector.fetchAll();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'FetchAll should not return null');
        System.assertEquals(3, results.size(), 'Should return all 3 test records');
    }
    
    @isTest
    static void testSelectAllWithOptionalCriteria() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Customer_Feedback__c> results = selector.selectAllWithOptionalCriteria();
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'SelectAll should not return null');
        System.assertEquals(3, results.size(), 'Should return all 3 test records');
    }
    
    @isTest
    static void testFetchByIdStatic() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        // Test the static fetchById method - line 66
        Test.startTest();
        Customer_Feedback__c result = CustomerFeedbackSelector.fetchById(feedback.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'FetchById should return record');
        System.assertEquals(feedback.Id, result.Id, 'Should return correct record');
    }
    
    @isTest
    static void testSelectById() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        Customer_Feedback__c result = selector.selectById(feedback.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'SelectById should return record');
        System.assertEquals(feedback.Id, result.Id, 'Should return correct record');
    }
    
    @isTest
    static void testSelectByStatus() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Customer_Feedback__c> results = selector.selectByStatus('New');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'SelectByStatus should not return null');
        System.assertEquals(1, results.size(), 'Should return 1 New record');
        System.assertEquals('New', results[0].Status__c, 'Should return correct status');
    }
    
    @isTest
    static void testSelectByStatusEmpty() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Customer_Feedback__c> results = selector.selectByStatus('Nonexistent');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'SelectByStatus should not return null');
        System.assertEquals(0, results.size(), 'Should return empty list for nonexistent status');
    }
    
    @isTest
    static void testSelectByType() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Customer_Feedback__c> results = selector.selectByType('Bug');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'SelectByType should not return null');
        System.assertEquals(1, results.size(), 'Should return 1 Bug record');
        System.assertEquals('Bug', results[0].Feedback_Type__c, 'Should return correct type');
    }
    
    @isTest
    static void testSelectByTypeEmpty() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Customer_Feedback__c> results = selector.selectByType('Nonexistent Type');
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'SelectByType should not return null');
        System.assertEquals(0, results.size(), 'Should return empty list for nonexistent type');
    }
    
    @isTest
    static void testSelectSObjectsById() {
        List<Customer_Feedback__c> feedbacks = [SELECT Id FROM Customer_Feedback__c];
        Set<Id> ids = new Set<Id>();
        for (Customer_Feedback__c fb : feedbacks) {
            ids.add(fb.Id);
        }
        
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Customer_Feedback__c> results = selector.selectSObjectsById(ids);
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'SelectSObjectsById should not return null');
        System.assertEquals(3, results.size(), 'Should return all 3 records');
    }
    
    @isTest
    static void testSelectSObjectsByIdEmpty() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Customer_Feedback__c> results = selector.selectSObjectsById(new Set<Id>());
        Test.stopTest();
        
        System.assertNotEquals(null, results, 'SelectSObjectsById should not return null');
        System.assertEquals(0, results.size(), 'Should return empty list for empty ID set');
    }
    
    @isTest
    static void testQueryFactoryMethods() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        // Test that we can create query factory and it includes our fields
        fflib_QueryFactory factory = selector.newQueryFactory();
        String soql = factory.toSOQL();
        Test.stopTest();
        
        System.assertNotEquals(null, factory, 'Query factory should be created');
        System.assertNotEquals(null, soql, 'SOQL should be generated');
        System.assert(soql.contains('Customer_Feedback__c'), 'SOQL should query Customer_Feedback__c');
        System.assert(soql.contains('Customer_Name__c'), 'SOQL should include custom fields');
    }
    
    @isTest
    static void testBulkOperations() {
        // Test bulk operations with large data set
        List<Customer_Feedback__c> bulkFeedbacks = new List<Customer_Feedback__c>();
        for (Integer i = 0; i < 50; i++) {
            bulkFeedbacks.add(new Customer_Feedback__c(
                Customer_Name__c = 'Bulk Customer ' + i,
                Customer_Email__c = 'bulk' + i + '@example.com',
                Feedback_Type__c = 'Bug',
                Description__c = 'Bulk description ' + i,
                Status__c = 'New',
                Priority__c = 'Low'
            ));
        }
        insert bulkFeedbacks;
        
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        List<Customer_Feedback__c> allResults = selector.selectAllWithOptionalCriteria();
        List<Customer_Feedback__c> bugResults = selector.selectByType('Bug');
        List<Customer_Feedback__c> newResults = selector.selectByStatus('New');
        Test.stopTest();
        
        System.assert(allResults.size() >= 53, 'Should return all records including bulk');
        System.assert(bugResults.size() >= 51, 'Should return all Bug records including bulk');
        System.assert(newResults.size() >= 51, 'Should return all New records including bulk');
    }
    
    @isTest
    static void testErrorHandling() {
        CustomerFeedbackSelector selector = new CustomerFeedbackSelector();
        
        Test.startTest();
        try {
            // Try to select by invalid ID format
            Customer_Feedback__c result = selector.selectById(null);
            System.assert(false, 'Should have thrown exception for null ID');
        } catch (Exception e) {
            System.assert(true, 'Exception expected for null ID');
        }
        Test.stopTest();
    }
} 