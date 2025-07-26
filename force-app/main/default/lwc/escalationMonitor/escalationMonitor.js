import { LightningElement, wire, track } from 'lwc';
import getAllFeedback from '@salesforce/apex/SimpleCustomerFeedbackController.getAllFeedback';
import { refreshApex } from '@salesforce/apex';
import { subscribe, MessageContext } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';

export default class EscalationMonitor extends LightningElement {
    @track escalatedFeedback = [];
    @track error;
    @wire(MessageContext) messageContext;
    wiredFeedbackResult;

    @wire(getAllFeedback)
    wiredFeedback(result) {
        this.wiredFeedbackResult = result;
        if (result.data) {
            // Filter for escalated items (High priority and older than 2 days)
            this.escalatedFeedback = result.data
                .filter(feedback => feedback.Escalation_Required__c)
                .map(feedback => ({
                    ...feedback,
                    daysOldClass: this.getDaysOldClass(feedback.Days_Since_Created__c),
                    statusClass: this.getStatusClass(feedback.Status__c)
                }))
                .sort((a, b) => b.Days_Since_Created__c - a.Days_Since_Created__c);
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.escalatedFeedback = [];
        }
    }

    connectedCallback() {
        // Subscribe to the feedback channel for real-time updates
        this.subscription = subscribe(
            this.messageContext,
            FEEDBACK_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        if (message.type === 'feedbackUpdated') {
            refreshApex(this.wiredFeedbackResult);
        }
    }

    getDaysOldClass(days) {
        if (days > 5) return 'slds-theme_error';
        if (days > 2) return 'slds-theme_warning';
        return 'slds-theme_info';
    }

    getStatusClass(status) {
        switch(status) {
            case 'New': return 'status-new';
            case 'In Progress': return 'status-inprogress';
            case 'Resolved': return 'status-resolved';
            case 'Closed': return 'status-closed';
            default: return '';
        }
    }
} 