import { LightningElement, api, wire, track } from 'lwc';
import getTicketHistory from '@salesforce/apex/FeedbackResponseController.getTicketHistory';
import { subscribe, unsubscribe, MessageContext, publish } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';
import { refreshApex } from '@salesforce/apex';

export default class FeedbackInbox extends LightningElement {
    @track recordId = null;
    @track ticketHistory = null;
    @track historyEntries = [];
    @track error;
    wiredHistoryResult;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getTicketHistory, { feedbackId: '$recordId' })
    wiredHistory(result) {
        this.wiredHistoryResult = result;
        if (result.data && result.data !== null) {
            this.ticketHistory = result.data;
            this.historyEntries = result.data.historyEntries || [];
            this.error = undefined;
            console.log('Ticket History:', this.ticketHistory);
        } else if (result.error) {
            this.error = result.error;
            this.ticketHistory = null;
            this.historyEntries = [];
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

    // unsubscribe from the message channel -  Lightning Message Service c
    unsubscribeToMessageChannel() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }

    // handle messages from the message channel
    handleMessage(message) {
        if (message.type === 'replyAdded' && message.feedbackId === this.recordId) {
            refreshApex(this.wiredHistoryResult);
        } else if (message.type === 'feedbackSelected') {
            // Update to show history for the selected feedback
            this.recordId = message.feedbackId;
        } else if (message.type === 'requestCurrentFeedback') {
            // Respond with current selection
            if (this.recordId) {
                publish(this.messageContext, FEEDBACK_CHANNEL, {
                    type: 'feedbackSelected',
                    feedbackId: this.recordId
                });
            }
        }
    }

    requestCurrentSelection() {
        // Request current feedback selection from statusManager
        publish(this.messageContext, FEEDBACK_CHANNEL, {
            type: 'requestCurrentFeedback'
        });
    }

    
    //set up real-time updates and sync its state with the rest of the app 
    connectedCallback() {
        this.subscribeToMessageChannel();
        // Request current selection when component loads
        setTimeout(() => {
            this.requestCurrentSelection();
        }, 100);
    }

    // return true if there is a recordId
    get showInbox() {
        return this.recordId != null;
    }

    // return true idf there is ticket history
    get hasHistory() {
        return this.historyEntries && this.historyEntries.length > 0;
    }

    get ticketName() {
        return this.ticketHistory && this.ticketHistory.feedback ? 
               this.ticketHistory.feedback.Name : this.recordId;
    }

    get selectedFeedbackName() {
        return this.ticketName;
    }
} 