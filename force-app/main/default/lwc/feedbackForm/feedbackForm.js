import { LightningElement, track } from 'lwc';
import createFeedback from '@salesforce/apex/SimpleCustomerFeedbackController.createFeedback';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class FeedbackForm extends NavigationMixin(LightningElement) {
    @track feedbackType = '';
    @track priority = '';
    @track description = '';
    @track isSubmitting = false;

    get feedbackTypeOptions() {
        return [
            { label: 'Bug', value: 'Bug' },
            { label: 'Feature Request', value: 'Feature Request' },
            { label: 'General Inquiry', value: 'General Inquiry' }
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
        const field = event.target.name;
        const value = event.target.value;
        
        if (field === 'feedbackType') {
            this.feedbackType = value;
        } else if (field === 'priority') {
            this.priority = value;
        } else if (field === 'description') {
            this.description = value;
        }
    }

    async handleSubmit() {
        if (!this.validateForm()) {
            return;
        }

        this.isSubmitting = true;

        try {
            const recordData = {
                Feedback_Type__c: this.feedbackType,
                Priority__c: this.priority,
                Description__c: this.description,
                Status__c: 'New'
            };

            const result = await createFeedback({ recordData });

            this.showToast('Success', 'Feedback submitted successfully!', 'success');
            this.resetForm();

        } catch (error) {
            console.error('Error submitting feedback:', error);
            this.showToast('Error', 'Failed to submit feedback: ' + error.body.message, 'error');
        } finally {
            this.isSubmitting = false;
        }
    }

    validateForm() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
            ...this.template.querySelectorAll('lightning-textarea')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (!allValid) {
            this.showToast('Error', 'Please complete all required fields', 'error');
        }

        return allValid;
    }

    resetForm() {
        this.feedbackType = '';
        this.priority = '';
        this.description = '';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}
