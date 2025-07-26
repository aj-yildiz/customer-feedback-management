import { LightningElement, wire, track } from 'lwc';
import getAllFeedback from '@salesforce/apex/SimpleCustomerFeedbackController.getAllFeedback';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FeedbackList extends LightningElement {
    @track feedbackData = [];
    @track error;
    @track isLoading = true;
    @track statusFilter = '';
    @track typeFilter = '';
    
    wiredFeedbackResult;

    // Type icon mapping
    typeIconMap = {
        'Bug': '🐛',
        'Feature Request': '💡',
        'General Inquiry': '❓',
        'Complaint': '😠',
        'Suggestion': '💭',
        'Praise': '👏'
    };

    @wire(getAllFeedback)
    wiredFeedback(result) {
        this.wiredFeedbackResult = result;
        this.isLoading = true;
        
        if (result.data) {
            this.feedbackData = result.data.map(feedback => {
                return {
                    ...feedback,
                    typeIcon: this.typeIconMap[feedback.Feedback_Type__c] || '❓',
                    statusClass: this.getStatusClass(feedback.Status__c),
                    priorityClass: this.getPriorityClass(feedback.Priority__c),
                    descriptionClass: feedback.Description__c ? 'feedback-description' : 'feedback-description empty',
                    displayDescription: feedback.Description__c || 'No description provided',
                    customerName: feedback.Customer_Name__c,
                    customerEmail: feedback.Customer_Email__c
                };
            });
            this.error = undefined;
        } else if (result.error) {
            console.error('Error loading feedback:', result.error);
            this.error = result.error.body?.message || 'Unknown error occurred';
            this.feedbackData = [];
        }
        this.isLoading = false;
    }

    get statusOptions() {
        return [
            { label: 'All Statuses', value: '' },
            { label: 'New', value: 'New' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Resolved', value: 'Resolved' },
            { label: 'Closed', value: 'Closed' }
        ];
    }

    get typeOptions() {
        return [
            { label: 'All Types', value: '' },
            { label: 'Bug', value: 'Bug' },
            { label: 'Feature Request', value: 'Feature Request' },
            { label: 'General Inquiry', value: 'General Inquiry' },
            { label: 'Complaint', value: 'Complaint' },
            { label: 'Suggestion', value: 'Suggestion' },
            { label: 'Praise', value: 'Praise' }
        ];
    }

    get filteredFeedback() {
        let filtered = [...this.feedbackData];

        if (this.statusFilter) {
            filtered = filtered.filter(feedback => 
                feedback.Status__c === this.statusFilter
            );
        }

        if (this.typeFilter) {
            filtered = filtered.filter(feedback => 
                feedback.Feedback_Type__c === this.typeFilter
            );
        }

        return filtered;
    }

    get hasFeedback() {
        return this.filteredFeedback.length > 0;
    }

    get recordCount() {
        return this.filteredFeedback.length;
    }

    getStatusClass(status) {
        const statusMap = {
            'New': 'status-badge status-new',
            'In Progress': 'status-badge status-in-progress',
            'Resolved': 'status-badge status-resolved',
            'Closed': 'status-badge status-closed'
        };
        return statusMap[status] || 'status-badge status-new';
    }

    getPriorityClass(priority) {
        const priorityMap = {
            'High': 'priority-badge priority-high',
            'Medium': 'priority-badge priority-medium',
            'Low': 'priority-badge priority-low'
        };
        return priorityMap[priority] || 'priority-badge priority-medium';
    }

    handleStatusFilterChange(event) {
        this.statusFilter = event.detail.value;
    }

    handleTypeFilterChange(event) {
        this.typeFilter = event.detail.value;
    }

    refreshData() {
        this.isLoading = true;
        return refreshApex(this.wiredFeedbackResult)
            .then(() => {
                this.showToast('Success', 'Data refreshed successfully', 'success');
            })
            .catch(error => {
                console.error('Error refreshing data:', error);
                this.showToast('Error', 'Failed to refresh data', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }

    connectedCallback() {
        // Add CORS headers for Experience Cloud
        if (document.location.hostname.includes('force.com')) {
            document.cookie = "CORSAllowOrigin=*; SameSite=None; Secure";
        }
    }
}