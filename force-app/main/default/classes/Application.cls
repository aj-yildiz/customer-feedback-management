public class Application {
    
    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType> {
                Customer_Feedback__c.SObjectType,
                FeedbackResponse__c.SObjectType
            });
    
    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> {
                Customer_Feedback__c.SObjectType => CustomerFeedbackSelector.class
            });
    
    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain = 
        new fflib_Application.DomainFactory(
            Application.Selector,
            new Map<SObjectType, Type> {
                Customer_Feedback__c.SObjectType => CustomerFeedbackDomain.Constructor.class
            });
            
    // Service factory instance
    private static fflib_Application.ServiceFactory serviceInstance;
            
    // Get/Set the ServiceFactory (the setter is used for mocking in tests)
    public static fflib_Application.ServiceFactory Service {
        get { 
            if (serviceInstance == null) {
                serviceInstance = new fflib_Application.ServiceFactory(
                    new Map<Type, Type> {
                        CustomerFeedbackService.class => CustomerFeedbackService.class
                    });
            }
            return serviceInstance; 
        }
        set { serviceInstance = value; }
    }
} 