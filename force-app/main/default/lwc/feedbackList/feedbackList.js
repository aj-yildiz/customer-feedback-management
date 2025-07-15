import { LightningElement, track, wire } from 'lwc';
import getAllFeedback from '@salesforce/apex/CustomerFeedbackController.getAllFeedback';
import { subscribe, MessageContext } from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const USER_FIELDS = [
    'User.Profile.Name'
];

export default class FeedbackList extends LightningElement {
    @track selectedStatus = 'All Statuses';
    @track selectedType = 'All Types';
    @track isLoading = false;
    @track canViewAdminDashboard = false;
    
    userId = USER_ID;
    
    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$userId', fields: USER_FIELDS })
    wiredUser({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.value.fields.Name.value;
            this.canViewAdminDashboard = profileName === 'System Administrator' || 
                                       profileName.includes('Admin');
        }
    }

    wiredFeedbackResult;
    
    @wire(getAllFeedback)
    wiredFeedback(result) {
        this.wiredFeedbackResult = result;
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (this.messageContext) {
            this.subscription = subscribe(
                this.messageContext,
                FEEDBACK_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }
    }

    handleMessage(message) {
        if (message.action === 'create') {
            this.refreshData();
        }
    }

    async refreshData() {
        this.isLoading = true;
        try {
            await refreshApex(this.wiredFeedbackResult);
        } catch (error) {
            // Handle error silently
        } finally {
            this.isLoading = false;
        }
    }

    get feedbacks() {
        const data = this.wiredFeedbackResult && this.wiredFeedbackResult.data ? this.wiredFeedbackResult.data : [];
        
        return data.map(fb => {
            let typeIcon = 'utility:question';
            let typeText = 'General Inquiry';
            
            if (fb.ece__Feedback_Type__c) {
                if (fb.ece__Feedback_Type__c === 'Bug') {
                    typeIcon = 'utility:bug';
                    typeText = 'Bug';
                } else if (fb.ece__Feedback_Type__c === 'Feature Request') {
                    typeIcon = 'utility:light_bulb';
                    typeText = 'Feature Request';
                } else if (fb.ece__Feedback_Type__c === 'General Inquiry') {
                    typeIcon = 'utility:question';
                    typeText = 'General Inquiry';
                } else {
                    typeText = fb.ece__Feedback_Type__c;
                }
            }
            
            let statusBadgeClass = 'slds-theme_shade';
            let statusLabel = fb.ece__Status__c || 'New';
            
            if (statusLabel === 'New') {
                statusBadgeClass = 'slds-theme_shade';
            } else if (statusLabel === 'In Progress') {
                statusBadgeClass = 'slds-theme_warning';
            } else if (statusLabel === 'Resolved') {
                statusBadgeClass = 'slds-theme_success';
            }
            
            let description = fb.ece__Description__c || 'No description provided';
            
            return {
                ...fb,
                typeIcon,
                typeText,
                statusBadgeClass,
                statusLabel,
                displayDescription: description
            };
        });
    }

    get filteredFeedbacks() {
        let filtered = this.feedbacks;
        
        if (this.selectedStatus !== 'All Statuses') {
            filtered = filtered.filter(fb => fb.ece__Status__c === this.selectedStatus);
        }
        
        if (this.selectedType !== 'All Types') {
            filtered = filtered.filter(fb => fb.ece__Feedback_Type__c === this.selectedType);
        }
        
        return filtered;
    }

    get statusOptions() {
        return [
            { label: 'All Statuses', value: 'All Statuses' },
            { label: 'New', value: 'New' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Resolved', value: 'Resolved' }
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
        this.selectedStatus = event.target.value;
    }

    handleTypeChange(event) {
        this.selectedType = event.target.value;
    }

    handleRefresh() {
        this.selectedStatus = 'All Statuses';
        this.selectedType = 'All Types';
        this.refreshData();
    }

    get hasData() {
        return this.filteredFeedbacks && this.filteredFeedbacks.length > 0;
    }

    get isFilteringDisabled() {
        return this.isLoading;
    }
}