@IsTest
public class SpyNotifier implements IFeedbackNotifier {
    public Boolean wasCalled = false;
    public List<Customer_Feedback__c> notifiedRecords;
 
    public void notifyOnNewFeedback(List<Customer_Feedback__c> newRecords) {
        wasCalled = true;
        notifiedRecords = newRecords;
    }
} 