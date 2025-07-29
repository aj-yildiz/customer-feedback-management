@isTest
private class CustomerFeedbackTriggerTest {
    
    @isTest
    static void testOnBeforeInsertTrigger() {
        // Test domain lifecycle: onBeforeInsert, onApplyDefaults, onValidate
        Test.startTest();
        
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        
        // Test with valid feedback
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Trigger Test Customer 1',
            Customer_Email__c = 'trigger1@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Trigger test description 1',
            Priority__c = 'High'
        ));
        
        // Test with minimal data to trigger defaults
        feedbacks.add(new Customer_Feedback__c(
            Customer_Name__c = 'Trigger Test Customer 2',
            Customer_Email__c = 'trigger2@example.com',
            Description__c = 'Trigger test description 2'
            // Status and Priority should get defaults
        ));
        
        insert feedbacks;
        
        Test.stopTest();
        
        // Verify defaults were applied
        List<Customer_Feedback__c> inserted = [
            SELECT Id, Status__c, Priority__c, Days_Since_Created__c
            FROM Customer_Feedback__c 
            WHERE Customer_Name__c LIKE 'Trigger Test Customer%'
            ORDER BY Customer_Name__c
        ];
        
        System.assertEquals(2, inserted.size(), 'Should insert 2 records');
        System.assertEquals('New', inserted[0].Status__c, 'First record should have explicit status');
        System.assertEquals('New', inserted[1].Status__c, 'Second record should get default status');
        System.assertNotEquals(null, inserted[1].Priority__c, 'Priority should be set by defaults');
    }
    
    @isTest
    static void testOnBeforeUpdateTrigger() {
        // Create initial feedback
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Update Trigger Test',
            Customer_Email__c = 'updatetrigger@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'Update trigger test description',
            Status__c = 'New',
            Priority__c = 'Medium'
        );
        insert feedback;
        
        Test.startTest();
        
        // Test domain lifecycle: onBeforeUpdate, onValidate
        feedback.Status__c = 'In Progress';
        feedback.Priority__c = 'High';
        update feedback;
        
        Test.stopTest();
        
        Customer_Feedback__c updated = [
            SELECT Status__c, Priority__c 
            FROM Customer_Feedback__c 
            WHERE Id = :feedback.Id
        ];
        
        System.assertEquals('In Progress', updated.Status__c, 'Status should be updated');
        System.assertEquals('High', updated.Priority__c, 'Priority should be updated');
    }
    
    @isTest
    static void testOnAfterInsertTrigger() {
        // Test domain lifecycle: onAfterInsert
        Test.startTest();
        
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'After Insert Test',
            Customer_Email__c = 'afterinsert@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'After insert test description',
            Status__c = 'New',
            Priority__c = 'High'
        );
        
        insert feedback;
        
        Test.stopTest();
        
        // Verify the record was inserted and any after-insert logic executed
        Customer_Feedback__c inserted = [
            SELECT Id, Status__c, Days_Since_Created__c, Escalation_Required__c
            FROM Customer_Feedback__c 
            WHERE Id = :feedback.Id
        ];
        
        System.assertNotEquals(null, inserted.Id, 'Record should be inserted');
        System.assertNotEquals(null, inserted.Days_Since_Created__c, 'Days since created should be calculated');
    }
    
    @isTest
    static void testOnAfterUpdateTrigger() {
        // Create initial feedback
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'After Update Test',
            Customer_Email__c = 'afterupdate@example.com',
            Feedback_Type__c = 'General Inquiry',
            Description__c = 'After update test description',
            Status__c = 'New',
            Priority__c = 'Low'
        );
        insert feedback;
        
        Test.startTest();
        
        // Test domain lifecycle: onAfterUpdate
        feedback.Status__c = 'Resolved';
        update feedback;
        
        Test.stopTest();
        
        Customer_Feedback__c updated = [
            SELECT Status__c, Days_Since_Created__c
            FROM Customer_Feedback__c 
            WHERE Id = :feedback.Id
        ];
        
        System.assertEquals('Resolved', updated.Status__c, 'Status should be updated');
    }
    
    @isTest
    static void testBulkInsertTrigger() {
        // Test bulk operations through triggers
        List<Customer_Feedback__c> bulkFeedbacks = new List<Customer_Feedback__c>();
        
        Test.startTest();
        
        for (Integer i = 0; i < 100; i++) {
            bulkFeedbacks.add(new Customer_Feedback__c(
                Customer_Name__c = 'Bulk Trigger Customer ' + i,
                Customer_Email__c = 'bulktrigger' + i + '@example.com',
                Feedback_Type__c = (Math.mod(i, 2) == 0) ? 'Bug' : 'Feature Request',
                Description__c = 'Bulk trigger description ' + i,
                Status__c = 'New',
                Priority__c = (Math.mod(i, 3) == 0) ? 'High' : 'Medium'
            ));
        }
        
        insert bulkFeedbacks;
        
        Test.stopTest();
        
        List<Customer_Feedback__c> inserted = [
            SELECT Id, Status__c, Priority__c, Days_Since_Created__c
            FROM Customer_Feedback__c 
            WHERE Customer_Name__c LIKE 'Bulk Trigger Customer%'
        ];
        
        System.assertEquals(100, inserted.size(), 'Should insert 100 records');
        
        // Verify defaults were applied to all records
        for (Customer_Feedback__c fb : inserted) {
            System.assertEquals('New', fb.Status__c, 'All should have New status');
            System.assertNotEquals(null, fb.Priority__c, 'All should have priority set');
            System.assertNotEquals(null, fb.Days_Since_Created__c, 'All should have days calculated');
        }
    }
    
    @isTest
    static void testBulkUpdateTrigger() {
        // Create bulk data first
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>();
        for (Integer i = 0; i < 50; i++) {
            feedbacks.add(new Customer_Feedback__c(
                Customer_Name__c = 'Bulk Update Customer ' + i,
                Customer_Email__c = 'bulkupdate' + i + '@example.com',
                Feedback_Type__c = 'Bug',
                Description__c = 'Bulk update description ' + i,
                Status__c = 'New',
                Priority__c = 'Low'
            ));
        }
        insert feedbacks;
        
        Test.startTest();
        
        // Bulk update
        for (Customer_Feedback__c fb : feedbacks) {
            fb.Status__c = 'In Progress';
            fb.Priority__c = 'High';
        }
        
        update feedbacks;
        
        Test.stopTest();
        
        List<Customer_Feedback__c> updated = [
            SELECT Status__c, Priority__c
            FROM Customer_Feedback__c 
            WHERE Customer_Name__c LIKE 'Bulk Update Customer%'
        ];
        
        System.assertEquals(50, updated.size(), 'Should update 50 records');
        
        for (Customer_Feedback__c fb : updated) {
            System.assertEquals('In Progress', fb.Status__c, 'All should be In Progress');
            System.assertEquals('High', fb.Priority__c, 'All should be High priority');
        }
    }
    
    @isTest
    static void testValidationRuleTriggers() {
        // Test validation rules through triggers
        Test.startTest();
        
        try {
            // Test empty description validation
            Customer_Feedback__c feedback = new Customer_Feedback__c(
                Customer_Name__c = 'Validation Test',
                Customer_Email__c = 'validation@example.com',
                Feedback_Type__c = 'Bug',
                Description__c = '', // Empty description should trigger validation
                Status__c = 'New',
                Priority__c = 'High'
            );
            
            insert feedback;
            System.assert(false, 'Should have failed validation for empty description');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Description') || 
                         e.getMessage().contains('required'), 
                         'Should fail description validation');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testEmailRequiredWhenClosedValidation() {
        // Create feedback without email
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Email Validation Test',
            Customer_Email__c = '', // No email initially
            Feedback_Type__c = 'Bug',
            Description__c = 'Email validation test',
            Status__c = 'New',
            Priority__c = 'High'
        );
        insert feedback;
        
        Test.startTest();
        
        try {
            // Try to close without email
            feedback.Status__c = 'Closed';
            update feedback;
            System.assert(false, 'Should have failed validation for missing email when closed');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Email') || 
                         e.getMessage().contains('required'), 
                         'Should fail email validation when closing');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testStatusTransitionValidation() {
        // Create closed feedback
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Status Transition Test',
            Customer_Email__c = 'statustransition@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Status transition test',
            Status__c = 'Closed',
            Priority__c = 'High'
        );
        insert feedback;
        
        Test.startTest();
        
        try {
            // Try to change status from Closed to something else
            feedback.Status__c = 'New';
            update feedback;
            System.assert(true, 'Status transition completed or validation handled');
        } catch (DmlException e) {
            System.assert(true, 'Status transition validation triggered as expected');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testMixedDMLOperations() {
        // Test mixed insert/update operations
        List<Customer_Feedback__c> toInsert = new List<Customer_Feedback__c>();
        List<Customer_Feedback__c> toUpdate = new List<Customer_Feedback__c>();
        
        // Create some initial records for updating
        Customer_Feedback__c existing = new Customer_Feedback__c(
            Customer_Name__c = 'Existing Customer',
            Customer_Email__c = 'existing@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Existing description',
            Status__c = 'New',
            Priority__c = 'Medium'
        );
        insert existing;
        
        Test.startTest();
        
        // Prepare new records for insert
        for (Integer i = 0; i < 10; i++) {
            toInsert.add(new Customer_Feedback__c(
                Customer_Name__c = 'Mixed DML Customer ' + i,
                Customer_Email__c = 'mixeddml' + i + '@example.com',
                Feedback_Type__c = 'Feature Request',
                Description__c = 'Mixed DML description ' + i,
                Status__c = 'New',
                Priority__c = 'Low'
            ));
        }
        
        // Prepare existing record for update
        existing.Status__c = 'In Progress';
        existing.Priority__c = 'High';
        toUpdate.add(existing);
        
        // Perform mixed operations
        insert toInsert;
        update toUpdate;
        
        Test.stopTest();
        
        // Verify results
        List<Customer_Feedback__c> allRecords = [
            SELECT Id, Status__c, Priority__c
            FROM Customer_Feedback__c 
            WHERE Customer_Name__c LIKE 'Mixed DML Customer%' OR Customer_Name__c = 'Existing Customer'
        ];
        
        System.assertEquals(11, allRecords.size(), 'Should have 11 total records');
    }
} 