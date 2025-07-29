@isTest
private class ApplicationTest {
    
    @isTest
    static void testUnitOfWorkFactory() {
        Test.startTest();
        fflib_Application.UnitOfWorkFactory factory = Application.UnitOfWork;
        Test.stopTest();
        
        System.assertNotEquals(null, factory, 'UnitOfWork factory should not be null');
        
        // Test that we can create a unit of work instance
        fflib_ISObjectUnitOfWork uow = factory.newInstance();
        System.assertNotEquals(null, uow, 'Unit of work instance should be created');
    }
    
    @isTest
    static void testSelectorFactory() {
        Test.startTest();
        fflib_Application.SelectorFactory factory = Application.Selector;
        Test.stopTest();
        
        System.assertNotEquals(null, factory, 'Selector factory should not be null');
        
        // Test that we can create a selector instance
        CustomerFeedbackSelector selector = (CustomerFeedbackSelector) factory.newInstance(Customer_Feedback__c.SObjectType);
        System.assertNotEquals(null, selector, 'Selector instance should be created');
    }
    
    @isTest
    static void testDomainFactory() {
        // Create test data for domain
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Test Customer',
            Customer_Email__c = 'test@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'Test description'
        );
        insert feedback;
        
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>{feedback};
        
        Test.startTest();
        fflib_Application.DomainFactory factory = Application.Domain;
        Test.stopTest();
        
        System.assertNotEquals(null, factory, 'Domain factory should not be null');
        
        // Test that we can create a domain instance
        fflib_IDomain domain = factory.newInstance((List<SObject>) feedbacks);
        System.assertNotEquals(null, domain, 'Domain instance should be created');
        System.assert(domain instanceof CustomerFeedbackDomain, 'Domain should be CustomerFeedbackDomain instance');
    }
    
    @isTest
    static void testServiceFactoryGetter() {
        Test.startTest();
        fflib_Application.ServiceFactory factory = Application.Service;
        Test.stopTest();
        
        System.assertNotEquals(null, factory, 'Service factory should not be null');
        
        // Test that we can get a service instance
        CustomerFeedbackService service = (CustomerFeedbackService) factory.newInstance(CustomerFeedbackService.class);
        System.assertNotEquals(null, service, 'Service instance should be created');
    }
    
    @isTest
    static void testServiceFactoryLazyInitialization() {
        // Test that the service factory is lazily initialized
        Test.startTest();
        
        // First access should initialize the factory
        fflib_Application.ServiceFactory factory1 = Application.Service;
        System.assertNotEquals(null, factory1, 'First access should initialize factory');
        
        // Second access should return the same instance
        fflib_Application.ServiceFactory factory2 = Application.Service;
        System.assertEquals(factory1, factory2, 'Second access should return same instance');
        
        Test.stopTest();
    }
    
    @isTest
    static void testServiceFactorySetter() {
        // Create a mock service factory for testing
        fflib_Application.ServiceFactory mockFactory = new fflib_Application.ServiceFactory(
            new Map<Type, Type> {
                CustomerFeedbackService.class => CustomerFeedbackService.class
            }
        );
        
        Test.startTest();
        
        // Test setter
        Application.Service = mockFactory;
        fflib_Application.ServiceFactory retrievedFactory = Application.Service;
        
        Test.stopTest();
        
        System.assertEquals(mockFactory, retrievedFactory, 'Setter should update the service factory');
    }
    
    @isTest
    static void testServiceFactorySetterAndGetter() {
        Test.startTest();
        
        // Reset to null first to test full initialization
        Application.Service = null;
        
        // Getting should auto-initialize
        fflib_Application.ServiceFactory factory = Application.Service;
        System.assertNotEquals(null, factory, 'Auto-initialization should work');
        
        // Create new mock factory
        fflib_Application.ServiceFactory newMockFactory = new fflib_Application.ServiceFactory(
            new Map<Type, Type> {
                CustomerFeedbackService.class => CustomerFeedbackService.class
            }
        );
        
        // Set new factory
        Application.Service = newMockFactory;
        
        // Verify it's the new factory
        fflib_Application.ServiceFactory currentFactory = Application.Service;
        System.assertEquals(newMockFactory, currentFactory, 'Should return the newly set factory');
        
        Test.stopTest();
    }
    
    @isTest
    static void testAllFactoriesWork() {
        // Create test feedback
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Integration Test Customer',
            Customer_Email__c = 'integration@example.com',
            Feedback_Type__c = 'Feature Request',
            Description__c = 'Integration test description'
        );
        insert feedback;
        
        Test.startTest();
        
        // Test UnitOfWork
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        System.assertNotEquals(null, uow, 'UnitOfWork should be created');
        
        // Test Selector
        CustomerFeedbackSelector selector = (CustomerFeedbackSelector) Application.Selector.newInstance(Customer_Feedback__c.SObjectType);
        List<Customer_Feedback__c> feedbacks = selector.selectSObjectsById(new Set<Id>{feedback.Id});
        System.assertEquals(1, feedbacks.size(), 'Selector should retrieve feedback');
        
        // Test Domain
        CustomerFeedbackDomain domain = (CustomerFeedbackDomain) Application.Domain.newInstance(feedbacks);
        System.assertNotEquals(null, domain, 'Domain should be created');
        
        // Test Service
        CustomerFeedbackService service = (CustomerFeedbackService) Application.Service.newInstance(CustomerFeedbackService.class);
        System.assertNotEquals(null, service, 'Service instance should be created');
        
        Test.stopTest();
    }
    
    @isTest
    static void testFactoryConfiguration() {
        Test.startTest();
        
        // Verify UnitOfWork factory is configured with correct SObject types
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        // Verify we can register Customer_Feedback__c objects
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'UOW Test Customer',
            Customer_Email__c = 'uow@example.com',
            Feedback_Type__c = 'Bug',
            Description__c = 'UOW test description'
        );
        
        uow.registerNew(feedback);
        uow.commitWork();
        
        // Verify the record was created
        List<Customer_Feedback__c> createdFeedbacks = [SELECT Id, Customer_Name__c FROM Customer_Feedback__c WHERE Customer_Name__c = 'UOW Test Customer'];
        System.assertEquals(1, createdFeedbacks.size(), 'UnitOfWork should create feedback record');
        
        Test.stopTest();
    }
    
    @isTest
    static void testServiceFactoryConfiguration() {
        Test.startTest();
        
        // Test that the service factory is configured correctly
        fflib_Application.ServiceFactory factory = Application.Service;
        
        // Verify we can create CustomerFeedbackService
        Object serviceObj = factory.newInstance(CustomerFeedbackService.class);
        System.assert(serviceObj instanceof CustomerFeedbackService, 'Should create CustomerFeedbackService instance');
        
        Test.stopTest();
    }
    
    @isTest
    static void testDomainFactoryConfiguration() {
        // Create test data
        Customer_Feedback__c feedback = new Customer_Feedback__c(
            Customer_Name__c = 'Domain Config Test',
            Customer_Email__c = 'domainconfig@example.com',
            Feedback_Type__c = 'General Inquiry',
            Description__c = 'Domain configuration test'
        );
        insert feedback;
        
        Test.startTest();
        
        // Test domain factory configuration
        fflib_Application.DomainFactory factory = Application.Domain;
        
        // Create domain instance using the factory
        List<Customer_Feedback__c> feedbacks = new List<Customer_Feedback__c>{feedback};
        fflib_IDomain domain = factory.newInstance((List<SObject>) feedbacks);
        
        // Verify it's the correct domain type
        System.assert(domain instanceof CustomerFeedbackDomain, 'Should create CustomerFeedbackDomain instance');
        
        Test.stopTest();
    }
} 