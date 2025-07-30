// Factory pattern : The UnitOfWork keeps track of all new, modified, 
//or deleted SObjects during a business process

public class Application {
    
    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType> {
                // register
                Customer_Feedback__c.SObjectType,
                FeedbackResponse__c.SObjectType
            });
    
    //  create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> {
                // returns the Selector for the Customer_Feedback__c object
                Customer_Feedback__c.SObjectType => CustomerFeedbackSelector.class
            });
    
    // create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain = 
        new fflib_Application.DomainFactory(
            Application.Selector, //passes the SelectorFactory to the DomainFactory
            new Map<SObjectType, Type> {
                Customer_Feedback__c.SObjectType => CustomerFeedbackDomain.Constructor.class
            });
            
    // Holds the current ServiceFactory instance
    private static fflib_Application.ServiceFactory serviceInstance;
            
    // Get/Set the ServiceFactory
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