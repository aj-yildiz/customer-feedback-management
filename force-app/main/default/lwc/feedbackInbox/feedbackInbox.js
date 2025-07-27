import { LightningElement, api, wire, track } from 'lwc';
import getResponses from '@salesforce/apex/FeedbackResponseController.getResponses';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';
import { refreshApex } from '@salesforce/apex';

export default class FeedbackInbox extends LightningElement {
    @api recordId;
    @track responses = [];
    @track error;
    wiredResponsesResult;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getResponses, { feedbackId: '$recordId' })
    wiredResponses(result) {
        this.wiredResponsesResult = result;
        if (result.data) {
            this.responses = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.responses = [];
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                FEEDBACK_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    unsubscribeToMessageChannel() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    handleMessage(message) {
        if (message.type === 'replyAdded' && message.feedbackId === this.recordId) {
            refreshApex(this.wiredResponsesResult);
        } else if (message.type === 'feedbackSelected') {
            // Update to show responses for the selected feedback
            this.recordId = message.feedbackId;
        }
    }

    get hasResponses() {
        return this.responses && this.responses.length > 0;
    }

    get responseCount() {
        return this.responses ? this.responses.length : 0;
    }
} 