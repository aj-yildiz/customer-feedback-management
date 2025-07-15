import { LightningElement, track, api, wire } from 'lwc';
import createFeedback from '@salesforce/apex/CustomerFeedbackController.createFeedback';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';

export default class FeedbackForm extends LightningElement {
    @track feedbackType = 'General Inquiry';
    @track description = '';
    @track status = 'New';
    @track isLoading = false;
    @api feedbackCreatedCallback;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, EMAIL_FIELD] })
    user;

    connectedCallback() {
        // Component initialization if needed
    }

    get typeOptions() {
        return [
            { label: '🐞 Bug', value: 'Bug' },
            { label: '💡 Feature Request', value: 'Feature Request' },
            { label: '❓ General Inquiry', value: 'General Inquiry' }
        ];
    }

    get statusOptions() {
        return [
            { label: 'New', value: 'New' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Resolved', value: 'Resolved' }
        ];
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        const value = event.target.value;
        
        if (field === 'feedbackType') {
            this.feedbackType = value;
        } else if (field === 'description') {
            this.description = value;
        } else if (field === 'status') {
            this.status = value;
        }
    }

    validateForm() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox,lightning-textarea')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (!this.feedbackType) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation Error',
                message: 'Please select a feedback type.',
                variant: 'error'
            }));
            return false;
        }

        if (!this.description || this.description.trim() === '') {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation Error',
                message: 'Please enter a description.',
                variant: 'error'
            }));
            return false;
        }

        if (!this.status) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation Error',
                message: 'Please select a status.',
                variant: 'error'
            }));
            return false;
        }

        return allValid;
    }



    async handleSubmit() {
        if (!this.validateForm()) {
            return;
        }

        // Extract customer name and email from wired user data
        const customerName = this.user?.data?.fields?.Name?.value || 'No name provided';
        const customerEmail = this.user?.data?.fields?.Email?.value || 'No email provided';

        if (!this.user?.data) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Warning',
                message: 'User information is still loading. Please try again.',
                variant: 'warning'
            }));
            return;
        }

        this.isLoading = true;

        const feedbackData = {
            'ece__Feedback_Type__c': this.feedbackType,
            'ece__Description__c': this.description.trim(),
            'ece__Status__c': this.status,
            'ece__Customer_Name__c': customerName,
            'ece__Customer_Email__c': customerEmail
        };
        
        try {
            const result = await createFeedback({ recordData: feedbackData });
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'Feedback submitted successfully!',
                variant: 'success'
            }));
            
            const payload = {
                recordId: result,
                action: 'create',
                data: feedbackData
            };
            publish(this.messageContext, FEEDBACK_CHANNEL, payload);
            
            this.resetForm();
            
            if (this.feedbackCreatedCallback) {
                this.feedbackCreatedCallback();
            }
            
            this.dispatchEvent(new CustomEvent('feedbackcreated', { 
                detail: { id: result, ...feedbackData } 
            }));
            
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Submitting Feedback',
                message: error.body && error.body.message ? error.body.message : 'Unknown error occurred.',
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }

    resetForm() {
        this.feedbackType = 'General Inquiry';
        this.description = '';
        this.status = 'New';
        
        // Reset form validation
        const inputFields = this.template.querySelectorAll('lightning-combobox,lightning-textarea');
        if (inputFields) {
            inputFields.forEach(field => {
                field.setCustomValidity('');
                field.reportValidity();
            });
        }
    }
}
