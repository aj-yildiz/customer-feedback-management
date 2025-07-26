import { LightningElement, api, track, wire } from 'lwc';
import getAllFeedback from '@salesforce/apex/CustomerFeedbackController.getAllFeedback';
import updateFeedbackStatus from '@salesforce/apex/CustomerFeedbackController.updateFeedbackStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';

export default class StatusManager extends LightningElement {
    @api feedbackRecord;
    @track isUpdating = false;
    @track showStatusHistory = false;
    @track feedbackList = [];
    @track selectedFeedbackId = '';
    wiredFeedbackResult;
    
    @wire(MessageContext)
    messageContext;

    @wire(getAllFeedback)
    wiredFeedback(result) {
        this.wiredFeedbackResult = result;
        if (result.data) {
            this.feedbackList = result.data;
            // Auto-select first feedback if none selected
            if (!this.selectedFeedbackId && result.data.length > 0) {
                this.selectedFeedbackId = result.data[0].Id;
            }
        }
    }

    get feedbackOptions() {
        return this.feedbackList.map(feedback => ({
            label: `${feedback.Name} - ${feedback.Description__c?.substring(0, 40) || 'No description'}...`,
            value: feedback.Id
        }));
    }

    get currentFeedback() {
        if (this.feedbackRecord) {
            return this.feedbackRecord;
        }
        return this.feedbackList.find(f => f.Id === this.selectedFeedbackId) || {};
    }

    get statusOptions() {
        return [
            { label: 'New', value: 'New' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Resolved', value: 'Resolved' },
            { label: 'Closed', value: 'Closed' }
        ];
    }

    get currentStatus() {
        return this.currentFeedback?.Status__c || 'New';
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
        if (!this.currentFeedback?.LastModifiedDate) return 0;
        const lastModified = new Date(this.currentFeedback.LastModifiedDate);
        const now = new Date();
        const diffTime = Math.abs(now - lastModified);
        return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    }

    get hasSelectedFeedback() {
        return this.currentFeedback && this.currentFeedback.Id;
    }

    handleFeedbackSelection(event) {
        this.selectedFeedbackId = event.detail.value;
    }

    async handleStatusChange(event) {
        const newStatus = event.detail.value;
        
        // Reset the dropdown to show placeholder
        event.target.value = '';
        
        if (!this.hasSelectedFeedback) {
            this.showToast('Error', 'Please select a feedback record first', 'error');
            return;
        }
        
        if (!this.canTransitionTo.includes(newStatus)) {
            this.showToast('Error', `Cannot transition from ${this.currentStatus} to ${newStatus}`, 'error');
            return;
        }

        this.isUpdating = true;

        try {
            await updateFeedbackStatus({ 
                feedbackId: this.currentFeedback.Id, 
                newStatus: newStatus 
            });

            this.showToast('Success', 
                `Status updated from ${this.currentStatus} to ${newStatus}`, 
                'success'
            );

            // Refresh the data
            await refreshApex(this.wiredFeedbackResult);

            // Notify other components
            this.publishStatusChange(newStatus);

            // Fire event to parent component
            this.dispatchEvent(new CustomEvent('statuschanged', {
                detail: { 
                    feedbackId: this.currentFeedback.Id,
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
            feedbackId: this.currentFeedback.Id,
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