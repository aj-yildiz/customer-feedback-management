import { LightningElement, api, track, wire } from 'lwc';
import updateFeedbackStatus from '@salesforce/apex/CustomerFeedbackController.updateFeedbackStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';

export default class StatusManager extends LightningElement {
    @api feedbackRecord;
    @track isUpdating = false;
    @track showStatusHistory = false;
    
    @wire(MessageContext)
    messageContext;

    get statusOptions() {
        return [
            { label: 'New', value: 'New' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Resolved', value: 'Resolved' },
            { label: 'Closed', value: 'Closed' }
        ];
    }

    get currentStatus() {
        return this.feedbackRecord?.Status__c || 'New';
    }

    get canTransitionTo() {
        const current = this.currentStatus;
        const transitions = {
            'New': ['In Progress', 'Closed'],
            'In Progress': ['Resolved', 'Closed'],
            'Resolved': ['Closed'],
            'Closed': [] // Cannot transition from closed
        };
        return transitions[current] || [];
    }

    get availableStatusOptions() {
        return this.statusOptions.filter(option => 
            this.canTransitionTo.includes(option.value)
        );
    }

    get statusClass() {
        const statusClasses = {
            'New': 'status-new',
            'In Progress': 'status-progress',
            'Resolved': 'status-resolved',
            'Closed': 'status-closed'
        };
        return `current-status ${statusClasses[this.currentStatus] || ''}`;
    }

    get daysInCurrentStatus() {
        if (!this.feedbackRecord?.LastModifiedDate) return 0;
        const lastModified = new Date(this.feedbackRecord.LastModifiedDate);
        const now = new Date();
        const diffTime = Math.abs(now - lastModified);
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }

    async handleStatusChange(event) {
        const newStatus = event.detail.value;
        
        if (!this.canTransitionTo.includes(newStatus)) {
            this.showToast('Error', `Cannot transition from ${this.currentStatus} to ${newStatus}`, 'error');
            return;
        }

        this.isUpdating = true;

        try {
            await updateFeedbackStatus({ 
                feedbackId: this.feedbackRecord.Id, 
                newStatus: newStatus 
            });

            this.showToast('Success', 
                `Status updated from ${this.currentStatus} to ${newStatus}`, 
                'success'
            );

            // Notify other components
            this.publishStatusChange(newStatus);

            // Fire event to parent component
            this.dispatchEvent(new CustomEvent('statuschanged', {
                detail: { 
                    feedbackId: this.feedbackRecord.Id,
                    oldStatus: this.currentStatus,
                    newStatus: newStatus
                }
            }));

        } catch (error) {
            this.showToast('Error', 
                `Failed to update status: ${error.body?.message || error.message}`, 
                'error'
            );
        } finally {
            this.isUpdating = false;
        }
    }

    publishStatusChange(newStatus) {
        const message = {
            type: 'statusChanged',
            feedbackId: this.feedbackRecord.Id,
            newStatus: newStatus
        };
        publish(this.messageContext, FEEDBACK_CHANNEL, message);
    }

    toggleStatusHistory() {
        this.showStatusHistory = !this.showStatusHistory;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
} 