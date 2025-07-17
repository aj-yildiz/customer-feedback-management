@isTest
public class CustomerFeedbackControllerTest {
    
    @isTest
    static void testCreateFeedback() {
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('ece__Feedback_Type__c', 'Bug');
        testData.put('ece__Description__c', 'Test description for bug report');
        testData.put('ece__Status__c', 'New');
        testData.put('ece__Customer_Name__c', 'Test User');
        testData.put('ece__Customer_Email__c', 'test@example.com');
        
        Test.startTest();
        String result = CustomerFeedbackController.createFeedback(testData);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.length() > 0);
        
        // Verify the record was created with correct data
        List<ece__Customer_Feedback__c> createdRecords = [
            SELECT Id, ece__Customer_Name__c, ece__Customer_Email__c, ece__Feedback_Type__c, ece__Description__c, ece__Status__c
            FROM ece__Customer_Feedback__c 
            WHERE Id = :result
        ];
        System.assertEquals(1, createdRecords.size());
        System.assertEquals('Test User', createdRecords[0].ece__Customer_Name__c);
        System.assertEquals('test@example.com', createdRecords[0].ece__Customer_Email__c);
    }
    
    @isTest
    static void testGetAllFeedback() {
        // Create test data
        ece__Customer_Feedback__c testRecord = new ece__Customer_Feedback__c();
        testRecord.ece__Feedback_Type__c = 'Feature Request';
        testRecord.ece__Description__c = 'Test description';
        testRecord.ece__Status__c = 'New';
        testRecord.ece__Customer_Name__c = 'John Doe';
        testRecord.ece__Customer_Email__c = 'john@example.com';
        insert testRecord;
        
        Test.startTest();
        List<ece__Customer_Feedback__c> result = CustomerFeedbackController.getAllFeedback();
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('John Doe', result[0].ece__Customer_Name__c);
        System.assertEquals('john@example.com', result[0].ece__Customer_Email__c);
    }
    
    @isTest
    static void testUpdateFeedbackStatus() {
        // Create test data
        ece__Customer_Feedback__c testRecord = new ece__Customer_Feedback__c();
        testRecord.ece__Status__c = 'New';
        testRecord.ece__Customer_Name__c = 'Jane Smith';
        testRecord.ece__Customer_Email__c = 'jane@example.com';
        insert testRecord;
        
        Test.startTest();
        CustomerFeedbackController.updateFeedbackStatus(testRecord.Id, 'In Progress');
        Test.stopTest();
        
        // Verify the status was updated
        ece__Customer_Feedback__c updatedRecord = [
            SELECT ece__Status__c 
            FROM ece__Customer_Feedback__c 
            WHERE Id = :testRecord.Id
        ];
        System.assertEquals('In Progress', updatedRecord.ece__Status__c);
    }
    
    @isTest
    static void testCreateFeedbackMinimalData() {
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('ece__Description__c', 'Minimal test description');
        testData.put('ece__Customer_Name__c', 'Minimal User');
        testData.put('ece__Customer_Email__c', 'minimal@example.com');
        
        Test.startTest();
        String result = CustomerFeedbackController.createFeedback(testData);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.length() > 0);
    }
}
