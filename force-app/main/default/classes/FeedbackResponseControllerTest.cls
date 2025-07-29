@isTest
private class FeedbackResponseControllerTest {
    
    @TestSetup
    static void makeData() {
        // Create test feedback record
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test feedback description',
            Status__c = 'New',
            Priority__c = 'High'
        );
        insert feedback;
        
        // Create test response records
        List<FeedbackResponse__c> responses = new List<FeedbackResponse__c>();
        for (Integer i = 0; i < 3; i++) {
            responses.add(new FeedbackResponse__c(
                Customer_Feedback__c = feedback.Id,
                Response__c = 'Test response ' + i
            ));
        }
        insert responses;
    }
    
    @isTest
    static void testSaveResponse_Success() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        Test.startTest();
        String responseId = FeedbackResponseController.saveResponse(feedback.Id, 'New test response');
        Test.stopTest();
        
        System.assertNotEquals(null, responseId, 'Response ID should be returned');
        
        FeedbackResponse__c savedResponse = [SELECT Customer_Feedback__c, Response__c 
                                           FROM FeedbackResponse__c WHERE Id = :responseId];
        System.assertEquals(feedback.Id, savedResponse.Customer_Feedback__c, 'Feedback ID should match');
        System.assertEquals('New test response', savedResponse.Response__c, 'Response message should match');
    }
    
    @isTest
    static void testSaveResponse_BlankFeedbackId() {
        Test.startTest();
        try {
            FeedbackResponseController.saveResponse('', 'Test message');
            System.assert(false, 'Should have thrown exception for blank feedback ID');
        } catch (AuraHandledException e) {
            // Exception was caught as expected
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveResponse_NullFeedbackId() {
        Test.startTest();
        try {
            FeedbackResponseController.saveResponse(null, 'Test message');
            System.assert(false, 'Should have thrown exception for null feedback ID');
        } catch (AuraHandledException e) {
            // Exception was caught as expected
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveResponse_BlankMessage() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        Test.startTest();
        try {
            FeedbackResponseController.saveResponse(feedback.Id, '');
            System.assert(false, 'Should have thrown exception for blank message');
        } catch (AuraHandledException e) {
            // Exception was caught as expected
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveResponse_NullMessage() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        Test.startTest();
        try {
            FeedbackResponseController.saveResponse(feedback.Id, null);
            System.assert(false, 'Should have thrown exception for null message');
        } catch (AuraHandledException e) {
            // Exception was caught as expected
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSaveResponse_InvalidFeedbackId() {
        Test.startTest();
        try {
            FeedbackResponseController.saveResponse('001000000000000', 'Test message');
            System.assert(false, 'Should have thrown exception for invalid feedback ID');
        } catch (AuraHandledException e) {
            // Exception was caught as expected
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetResponses_Success() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        Test.startTest();
        List<FeedbackResponseController.FeedbackResponseWrapper> responses = 
            FeedbackResponseController.getResponses(feedback.Id);
        Test.stopTest();
        
        System.assertEquals(3, responses.size(), 'Should return 3 responses');
        
        // Verify wrapper properties are set correctly
        FeedbackResponseController.FeedbackResponseWrapper wrapper = responses[0];
        System.assertNotEquals(null, wrapper.id, 'Wrapper ID should be set');
        System.assertNotEquals(null, wrapper.message, 'Wrapper message should be set');
        System.assertNotEquals(null, wrapper.createdDate, 'Wrapper created date should be set');
        System.assertNotEquals(null, wrapper.createdBy, 'Wrapper created by should be set');
        System.assertNotEquals(null, wrapper.formattedDate, 'Wrapper formatted date should be set');
    }
    
    @isTest
    static void testGetResponses_BlankFeedbackId() {
        Test.startTest();
        List<FeedbackResponseController.FeedbackResponseWrapper> responses = 
            FeedbackResponseController.getResponses('');
        Test.stopTest();
        
        System.assertEquals(0, responses.size(), 'Should return empty list for blank feedback ID');
    }
    
    @isTest
    static void testGetResponses_NullFeedbackId() {
        Test.startTest();
        List<FeedbackResponseController.FeedbackResponseWrapper> responses = 
            FeedbackResponseController.getResponses(null);
        Test.stopTest();
        
        System.assertEquals(0, responses.size(), 'Should return empty list for null feedback ID');
    }
    
    @isTest
    static void testGetResponses_NoResponses() {
        // Create feedback without responses
        Customer_Feedback__c newFeedback = new Customer_Feedback__c(
            Customer_Name__c = 'No Response Customer',
            Customer_Email__c = 'noresponse@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'No responses here',
            Status__c = 'New',
            Priority__c = 'Low'
        );
        insert newFeedback;
        
        Test.startTest();
        List<FeedbackResponseController.FeedbackResponseWrapper> responses = 
            FeedbackResponseController.getResponses(newFeedback.Id);
        Test.stopTest();
        
        System.assertEquals(0, responses.size(), 'Should return empty list when no responses exist');
    }
    
    @isTest
    static void testGetTicketHistory_Success() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        Test.startTest();
        FeedbackResponseController.TicketHistoryWrapper history = 
            FeedbackResponseController.getTicketHistory(feedback.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, history, 'History wrapper should not be null');
        System.assertNotEquals(null, history.feedback, 'Feedback should not be null');
        System.assertNotEquals(null, history.historyEntries, 'History entries should not be null');
        
        // Should have 1 ticket creation entry + 3 response entries = 4 total
        System.assertEquals(4, history.historyEntries.size(), 'Should have 4 history entries');
        
        // Verify first entry is ticket creation
        FeedbackResponseController.HistoryEntryWrapper firstEntry = history.historyEntries[0];
        System.assertEquals('ticket_created', firstEntry.entryType, 'First entry should be ticket creation');
        System.assertEquals('🎫', firstEntry.icon, 'First entry should have ticket icon');
        
        // Verify wrapper properties
        System.assertNotEquals(null, firstEntry.title, 'Entry title should be set');
        System.assertNotEquals(null, firstEntry.description, 'Entry description should be set');
        System.assertNotEquals(null, firstEntry.createdDate, 'Entry created date should be set');
        System.assertNotEquals(null, firstEntry.createdBy, 'Entry created by should be set');
        System.assertNotEquals(null, firstEntry.formattedDate, 'Entry formatted date should be set');
        System.assertNotEquals(null, firstEntry.formattedTime, 'Entry formatted time should be set');
    }
    
    @isTest
    static void testGetTicketHistory_BlankFeedbackId() {
        Test.startTest();
        FeedbackResponseController.TicketHistoryWrapper history = 
            FeedbackResponseController.getTicketHistory('');
        Test.stopTest();
        
        System.assertEquals(null, history, 'Should return null for blank feedback ID');
    }
    
    @isTest
    static void testGetTicketHistory_NullFeedbackId() {
        Test.startTest();
        FeedbackResponseController.TicketHistoryWrapper history = 
            FeedbackResponseController.getTicketHistory(null);
        Test.stopTest();
        
        System.assertEquals(null, history, 'Should return null for null feedback ID');
    }
    
    @isTest
    static void testGetTicketHistory_InvalidFeedbackId() {
        Test.startTest();
        try {
            FeedbackResponseController.TicketHistoryWrapper history = 
                FeedbackResponseController.getTicketHistory('001000000000000');
            System.assert(false, 'Should have thrown exception for invalid feedback ID');
        } catch (AuraHandledException e) {
            // Exception was caught as expected
            System.assert(true, 'Exception caught as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testFeedbackResponseWrapper_Constructor() {
        DateTime testDate = DateTime.now();
        
        Test.startTest();
        FeedbackResponseController.FeedbackResponseWrapper wrapper = 
            new FeedbackResponseController.FeedbackResponseWrapper(
                'test_id', 'test_message', testDate, 'test_user'
            );
        Test.stopTest();
        
        System.assertEquals('test_id', wrapper.id, 'ID should be set correctly');
        System.assertEquals('test_message', wrapper.message, 'Message should be set correctly');
        System.assertEquals(testDate, wrapper.createdDate, 'Created date should be set correctly');
        System.assertEquals('test_user', wrapper.createdBy, 'Created by should be set correctly');
        System.assertNotEquals(null, wrapper.formattedDate, 'Formatted date should be set');
    }
    
    @isTest
    static void testTicketHistoryWrapper_Constructor() {
        Customer_Feedback__c feedback = [SELECT Id, Name, Feedback_Type__c, Priority__c, Status__c, 
                                        Description__c, Customer_Email__c, CreatedDate 
                                        FROM Customer_Feedback__c LIMIT 1];
        List<FeedbackResponseController.HistoryEntryWrapper> entries = 
            new List<FeedbackResponseController.HistoryEntryWrapper>();
        
        Test.startTest();
        FeedbackResponseController.TicketHistoryWrapper wrapper = 
            new FeedbackResponseController.TicketHistoryWrapper(feedback, entries);
        Test.stopTest();
        
        System.assertEquals(feedback, wrapper.feedback, 'Feedback should be set correctly');
        System.assertEquals(entries, wrapper.historyEntries, 'History entries should be set correctly');
    }
    
    @isTest
    static void testHistoryEntryWrapper_Constructor() {
        DateTime testDate = DateTime.now();
        
        Test.startTest();
        FeedbackResponseController.HistoryEntryWrapper wrapper = 
            new FeedbackResponseController.HistoryEntryWrapper(
                'test_type', 'test_title', 'test_description', 
                testDate, 'test_user', 'test_icon'
            );
        Test.stopTest();
        
        System.assertEquals('test_type', wrapper.entryType, 'Entry type should be set correctly');
        System.assertEquals('test_title', wrapper.title, 'Title should be set correctly');
        System.assertEquals('test_description', wrapper.description, 'Description should be set correctly');
        System.assertEquals(testDate, wrapper.createdDate, 'Created date should be set correctly');
        System.assertEquals('test_user', wrapper.createdBy, 'Created by should be set correctly');
        System.assertEquals('test_icon', wrapper.icon, 'Icon should be set correctly');
        System.assertNotEquals(null, wrapper.formattedDate, 'Formatted date should be set');
        System.assertNotEquals(null, wrapper.formattedTime, 'Formatted time should be set');
    }
    
    @isTest
    static void testHistoryEntryWrapper_CompareTo() {
        DateTime earlierDate = DateTime.now().addDays(-1);
        DateTime laterDate = DateTime.now();
        DateTime sameDate = earlierDate;
        
        FeedbackResponseController.HistoryEntryWrapper earlierEntry = 
            new FeedbackResponseController.HistoryEntryWrapper(
                'type1', 'title1', 'desc1', earlierDate, 'user1', 'icon1'
            );
        
        FeedbackResponseController.HistoryEntryWrapper laterEntry = 
            new FeedbackResponseController.HistoryEntryWrapper(
                'type2', 'title2', 'desc2', laterDate, 'user2', 'icon2'
            );
            
        FeedbackResponseController.HistoryEntryWrapper sameEntry = 
            new FeedbackResponseController.HistoryEntryWrapper(
                'type3', 'title3', 'desc3', sameDate, 'user3', 'icon3'
            );
        
        Test.startTest();
        Integer result1 = earlierEntry.compareTo(laterEntry);
        Integer result2 = laterEntry.compareTo(earlierEntry);
        Integer result3 = earlierEntry.compareTo(sameEntry);
        Test.stopTest();
        
        System.assertEquals(-1, result1, 'Earlier date should return -1');
        System.assertEquals(1, result2, 'Later date should return 1');
        System.assertEquals(0, result3, 'Same date should return 0');
    }
    
    @isTest
    static void testBulkResponseCreation() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        // Test creating multiple responses
        Test.startTest();
        List<String> responseIds = new List<String>();
        for (Integer i = 0; i < 5; i++) {
            String responseId = FeedbackResponseController.saveResponse(
                feedback.Id, 'Bulk response ' + i
            );
            responseIds.add(responseId);
        }
        Test.stopTest();
        
        System.assertEquals(5, responseIds.size(), 'Should create 5 responses');
        
        // Verify all responses were created
        List<FeedbackResponse__c> savedResponses = [
            SELECT Id, Response__c FROM FeedbackResponse__c 
            WHERE Id IN :responseIds
        ];
        System.assertEquals(5, savedResponses.size(), 'All responses should be saved');
    }
    
    @isTest
    static void testResponseLimit() {
        Customer_Feedback__c feedback = [SELECT Id FROM Customer_Feedback__c LIMIT 1];
        
        // Create more than 100 responses to test the LIMIT clause
        List<FeedbackResponse__c> manyResponses = new List<FeedbackResponse__c>();
        for (Integer i = 0; i < 105; i++) {
            manyResponses.add(new FeedbackResponse__c(
                Customer_Feedback__c = feedback.Id,
                Response__c = 'Limit test response ' + i
            ));
        }
        insert manyResponses;
        
        Test.startTest();
        List<FeedbackResponseController.FeedbackResponseWrapper> responses = 
            FeedbackResponseController.getResponses(feedback.Id);
        Test.stopTest();
        
        System.assertEquals(100, responses.size(), 'Should limit to 100 responses');
    }
} 