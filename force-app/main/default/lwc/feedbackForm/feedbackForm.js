import { LightningElement, track, wire } from 'lwc';
import createFeedback from '@salesforce/apex/CustomerFeedbackController.createFeedback';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';

export default class FeedbackForm extends NavigationMixin(LightningElement) {
    // use track to update the properties
    @track feedbackType = '';
    @track priority = '';
    @track description = '';
    @track isSubmitting = false;
    
    @wire(MessageContext)
    messageContext;

    get feedbackTypeOptions() {
        return [
            { label: '🐛 Bug Report', value: 'Bug' },
            { label: '💡 Feature Request', value: 'Feature Request' },
            { label: '❓ General Inquiry', value: 'General Inquiry' }
        ];
    }

    get priorityOptions() {
        return [
            { label: '🟢 Low Priority', value: 'Low' },
            { label: '🟡 Medium Priority', value: 'Medium' },
            { label: '🔴 High Priority', value: 'High' }
        ];
    }

    get characterCount() {
        return this.description ? this.description.length : 0;
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

    async handleSubmit() { // call the validateForm() method to validate the form
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

            this.showToast('Success', 'Your feedback has been submitted successfully! 🎉', 'success');
            this.resetForm();
            
            // Notify other components that feedback was created
            this.notifyFeedbackCreated();

        } catch (error) {
            console.error('Error submitting feedback:', error);
            this.showToast('Error', 'Failed to submit feedback: ' + error.body.message, 'error');
        } finally {
            this.isSubmitting = false;
        }
    }

    notifyFeedbackCreated() {
        const message = {
            type: 'feedbackCreated'
        };
        publish(this.messageContext, FEEDBACK_CHANNEL, message);
    }

    validateForm() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-textarea')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (!allValid) {
            this.showToast('Error', 'Please complete all required fields ⚠️', 'error');
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
