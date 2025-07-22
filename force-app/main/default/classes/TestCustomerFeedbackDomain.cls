@IsTest
public class TestCustomerFeedbackDomain extends CustomerFeedbackDomain {
    public static IFeedbackNotifier testNotifier;
    
    public TestCustomerFeedbackDomain(List<Customer_Feedback__c> records) {
        super(records);
    }
    
    public override void onAfterInsert() {
        testNotifier.notifyOnNewFeedback((List<Customer_Feedback__c>)Records);
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new TestCustomerFeedbackDomain((List<Customer_Feedback__c>) sObjectList);
        }
    }
} 