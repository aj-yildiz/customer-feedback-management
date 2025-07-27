import { LightningElement, api, wire, track } from 'lwc';
import getResponses from '@salesforce/apex/FeedbackResponseController.getResponses';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';
import { refreshApex } from '@salesforce/apex';

export default class FeedbackInbox extends LightningElement {
    @track recordId = null;  // Start with null, will be set by statusManager
    @track responses = [];
    @track error;
    wiredResponsesResult;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getResponses, { feedbackId: '$recordId' })
    wiredResponses(result) {
        this.wiredResponsesResult = result;
        if (this.recordId && result.data) {
            this.responses = result.data;
            this.error = undefined;
            console.log('Agent Notes loaded for:', this.recordId, 'Count:', result.data.length);
        } else if (result.error) {
            this.error = result.error;
            this.responses = [];
            console.error('Error loading agent notes:', result.error);
        } else if (!this.recordId) {
            // No recordId selected yet
            this.responses = [];
            this.error = undefined;
        }
    }

    connectedCallback() {
        console.log('Agent Notes component connected');
        this.subscribeToMessageChannel();
        // Request current feedback selection from statusManager
        setTimeout(() => {
            this.requestCurrentSelection();
        }, 500);
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

    requestCurrentSelection() {
        // Request current feedback selection from statusManager
        const message = {
            type: 'requestCurrentFeedback'
        };
        publish(this.messageContext, FEEDBACK_CHANNEL, message);
        console.log('Requested current feedback selection');
    }

    handleMessage(message) {
        console.log('Agent Notes received message:', message);
        if (message.type === 'replyAdded' && message.feedbackId === this.recordId) {
            // Refresh responses when a new reply is added
            console.log('Refreshing agent notes for new reply');
            refreshApex(this.wiredResponsesResult);
        } else if (message.type === 'feedbackSelected') {
            // Update to show responses for the selected feedback
            console.log('Switching to feedback:', message.feedbackId);
            this.recordId = message.feedbackId;
        }
    }

    get hasResponses() {
        return this.responses && this.responses.length > 0;
    }

    get responseCount() {
        return this.responses ? this.responses.length : 0;
    }

    get showInbox() {
        return this.recordId != null;
    }

    get selectedFeedbackName() {
        return this.recordId ? this.recordId : '';
    }
} 