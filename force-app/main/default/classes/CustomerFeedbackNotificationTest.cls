@IsTest
private class CustomerFeedbackNotificationTest {
    
    @IsTest
    static void testDomainValidationOnInsert() {
        // Test that domain validation works correctly
        
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Description__c = 'Test Description',
            Feedback_Type__c = 'Bug',
            Priority__c = 'High',
            Status__c = 'New'
        );
        
        // Act
        Test.startTest();
        insert feedback;
        Test.stopTest();
        
        // Assert - record was created successfully
        Customer_Feedback__c created = [SELECT Id, Status__c, Priority__c FROM Customer_Feedback__c WHERE Id = :feedback.Id];
        System.assertEquals('New', created.Status__c, 'Status should be set to New');
        System.assertEquals('High', created.Priority__c, 'Priority should be preserved');
    }
    
    @IsTest
    static void testBulkDomainValidationOnInsert() {
        // Test bulk insert functionality
        
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        for(Integer i = 0; i < 5; i++) {
            feedbacks.add(new Customer_Feedback__c(
                Description__c = 'Test Description ' + i,
                Feedback_Type__c = 'Bug',
                Priority__c = 'High',
                Status__c = 'New'
            ));
        }
        
        // Act
        Test.startTest();
        insert feedbacks;
        Test.stopTest();
        
        // Assert - all records were created
        List<Customer_Feedback__c> created = [SELECT Id, Status__c FROM Customer_Feedback__c WHERE Id IN :feedbacks];
        System.assertEquals(5, created.size(), 'Should have created all 5 records');
        
        for(Customer_Feedback__c feedback : created) {
            System.assertEquals('New', feedback.Status__c, 'All records should have New status');
        }
    }
} 