public class Application {
    
    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType> {
                Customer_Feedback__c.SObjectType
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
            
    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory Service =
        new fflib_Application.ServiceFactory(
            new Map<Type, Type> {
                IFeedbackNotifier.class => EmailFeedbackNotifier.class
            });
            
    // Get the feedback notifier instance
    public static IFeedbackNotifier Notifier {
        get {
            return (IFeedbackNotifier)Service.newInstance(IFeedbackNotifier.class);
        }
    }
} 