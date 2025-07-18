import { LightningElement, track, api } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';

export default class StatusFilter extends LightningElement {
    @track selectedStatus = 'All Statuses';
    @track selectedType = 'All Types';
    
    @api messageContext;
    
    get statusOptions() {
        return [
            { label: 'All Statuses', value: 'All Statuses' },
            { label: 'New', value: 'New' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Resolved', value: 'Resolved' },
            { label: 'Closed', value: 'Closed' }
        ];
    }
    
    get typeOptions() {
        return [
            { label: 'All Types', value: 'All Types' },
            { label: 'Bug', value: 'Bug' },
            { label: 'Feature Request', value: 'Feature Request' },
            { label: 'General Inquiry', value: 'General Inquiry' }
        ];
    }
    
    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.publishFilterChange();
    }
    
    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.publishFilterChange();
    }
    
    publishFilterChange() {
        const payload = {
            action: 'filter',
            filters: {
                status: this.selectedStatus,
                type: this.selectedType
            }
        };
        
        if (this.messageContext) {
            publish(this.messageContext, FEEDBACK_CHANNEL, payload);
        }
        
        // Also dispatch custom event for components that don't use LMS
        this.dispatchEvent(new CustomEvent('filterchange', {
            detail: payload.filters
        }));
    }
} 