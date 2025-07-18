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
    @track priority = 'Medium';
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

    get priorityOptions() {
        return [
            { label: 'Low', value: 'Low' },
            { label: 'Medium', value: 'Medium' },
            { label: 'High', value: 'High' }
        ];
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        const value = event.target.value;
        
        if (field === 'feedbackType') {
            this.feedbackType = value;
        } else if (field === 'description') {
            this.description = value;
        }
    }

    handlePriorityChange(event) {
        this.priority = event.target.value;
    }

    validateForm() {
        const allValid = [...this.template.querySelectorAll('lightning-combobox, lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
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

        if (!this.description || this.description.trim().length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation Error',
                message: 'Please provide a description.',
                variant: 'error'
            }));
            return false;
        }

        if (!this.priority) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Validation Error',
                message: 'Please select a priority.',
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
            'Feedback_Type__c': this.feedbackType,
            'Description__c': this.description.trim(),
            'Priority__c': this.priority,
            'Customer_Name__c': customerName,
            'Customer_Email__c': customerEmail
        };

        try {
            const result = await createFeedback({ recordData: feedbackData });
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!',
                message: 'Feedback submitted successfully!',
                variant: 'success'
            }));

            // Reset form after successful submission
            this.resetForm();

            // Publish message to update other components
            publish(this.messageContext, FEEDBACK_CHANNEL, {
                action: 'create',
                recordId: result
            });

            // Call callback if provided
            if (this.feedbackCreatedCallback) {
                this.feedbackCreatedCallback();
            }

        } catch (error) {
            console.error('Error creating feedback:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'An error occurred while submitting feedback.',
                variant: 'error'
            }));
        } finally {
            this.isLoading = false;
        }
    }

    resetForm() {
        this.feedbackType = 'General Inquiry';
        this.description = '';
        this.priority = 'Medium';
        
        // Reset form field validation states
        const formElements = this.template.querySelectorAll('lightning-combobox, lightning-textarea');
        formElements.forEach(element => {
            element.setCustomValidity('');
            element.reportValidity();
        });
    }

    @api
    reset() {
        this.resetForm();
    }
}
