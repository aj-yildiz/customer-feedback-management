public class EmailFeedbackNotifier implements IFeedbackNotifier {
    public void notifyOnNewFeedback(List<Customer_Feedback__c> newRecords) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Customer_Feedback__c fb : newRecords) {
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setToAddresses(new String[]{ fb.Customer_Email__c });
            msg.setSubject('Thank you for your feedback');
            msg.setHtmlBody(
                'Hi ' + fb.Customer_Name__c + ',<br/><br/>' +
                'Thanks for submitting: ' + fb.Description__c + '<br/><br/>' +
                'We appreciate your input!'
            );
            mails.add(msg);
        }
        if (!mails.isEmpty()) {
            Messaging.sendEmail(mails);
        }
    }
} 