@IsTest
private class CustomerFeedbackNotificationTest {
    
    private class SpyNotifier implements IFeedbackNotifier {
        public Boolean wasCalled = false;
        
        public void notifyOnNewFeedback(List<Customer_Feedback__c> newRecords) {
            wasCalled = true;
        }
    }
    
    @IsTest
    static void testNotificationOnInsert() {
        // Arrange
        SpyNotifier spy = new SpyNotifier();
        Application.Service.setMock(IFeedbackNotifier.class, spy);
        
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Description__c = 'Test Description',
            Feedback_Type__c = 'Bug',
            Priority__c = 'High',
            Status__c = 'New'
        );
        
        // Act
        Test.startTest();
        insert feedback;
        Test.stopTest();
        
        // Assert
        System.assert(spy.wasCalled, 'Notification should have been triggered');
    }
} 