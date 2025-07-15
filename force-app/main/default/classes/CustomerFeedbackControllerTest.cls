@isTest
public class CustomerFeedbackControllerTest {
    
    @isTest
    static void testCreateFeedback() {
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('Feedback_Type__c', 'Bug');
        testData.put('Description__c', 'Test description for bug report');
        testData.put('Status__c', 'New');
        testData.put('Customer_Name__c', 'Test User');
        testData.put('Customer_Email__c', 'test@example.com');
        
        Test.startTest();
        String result = CustomerFeedbackController.createFeedback(testData);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.length() > 0);
        
        // Verify the record was created with correct data
        List<ece__Customer_Feedback__c> createdRecords = [
            SELECT Id, Customer_Name__c, Customer_Email__c, Feedback_Type__c, Description__c, Status__c
            FROM ece__Customer_Feedback__c 
            WHERE Id = :result
        ];
        System.assertEquals(1, createdRecords.size());
        System.assertEquals('Test User', createdRecords[0].Customer_Name__c);
        System.assertEquals('test@example.com', createdRecords[0].Customer_Email__c);
    }
    
    @isTest
    static void testGetAllFeedback() {
        // Create test data
        ece__Customer_Feedback__c testRecord = new ece__Customer_Feedback__c();
        testRecord.Feedback_Type__c = 'Feature Request';
        testRecord.Description__c = 'Test description';
        testRecord.Status__c = 'New';
        testRecord.Customer_Name__c = 'John Doe';
        testRecord.Customer_Email__c = 'john@example.com';
        insert testRecord;
        
        Test.startTest();
        List<ece__Customer_Feedback__c> result = CustomerFeedbackController.getAllFeedback();
        Test.stopTest();
        
        System.assertEquals(1, result.size());
        System.assertEquals('John Doe', result[0].Customer_Name__c);
        System.assertEquals('john@example.com', result[0].Customer_Email__c);
    }
    
    @isTest
    static void testUpdateFeedbackStatus() {
        // Create test data
        ece__Customer_Feedback__c testRecord = new ece__Customer_Feedback__c();
        testRecord.Status__c = 'New';
        testRecord.Customer_Name__c = 'Jane Smith';
        testRecord.Customer_Email__c = 'jane@example.com';
        insert testRecord;
        
        Test.startTest();
        CustomerFeedbackController.updateFeedbackStatus(testRecord.Id, 'In Progress');
        Test.stopTest();
        
        // Verify the status was updated
        ece__Customer_Feedback__c updatedRecord = [
            SELECT Status__c 
            FROM ece__Customer_Feedback__c 
            WHERE Id = :testRecord.Id
        ];
        System.assertEquals('In Progress', updatedRecord.Status__c);
    }
    
    @isTest
    static void testCreateFeedbackMinimalData() {
        Map<String, Object> testData = new Map<String, Object>();
        testData.put('Description__c', 'Minimal test description');
        testData.put('Customer_Name__c', 'Minimal User');
        testData.put('Customer_Email__c', 'minimal@example.com');
        
        Test.startTest();
        String result = CustomerFeedbackController.createFeedback(testData);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.length() > 0);
    }
}
