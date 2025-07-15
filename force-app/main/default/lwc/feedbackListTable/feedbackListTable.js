import { LightningElement, api } from 'lwc';

export default class FeedbackListTable extends LightningElement {
    @api feedbacks = [];

    get formattedFeedbacks() {
        return this.feedbacks.map(feedback => ({
            ...feedback,
            customerName: feedback.ece__Customer_Name__c,
            customerEmail: feedback.ece__Customer_Email__c
        }));
    }
}
