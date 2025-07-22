import { LightningElement, wire } from 'lwc';
import getAllFeedback from '@salesforce/apex/CustomerFeedbackController.getAllFeedback';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DebugFeedback extends LightningElement {
    feedbackData;
    error;
    
    @wire(getAllFeedback)
    wiredFeedback({ error, data }) {
        if (data) {
            this.feedbackData = data;
            this.error = undefined;
            
            // Show success toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `Loaded ${data.length} feedback records`,
                    variant: 'success'
                })
            );
        } else if (error) {
            this.error = error;
            this.feedbackData = undefined;
            
            // Show error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || error.message,
                    variant: 'error'
                })
            );
        }
    }
    
    get hasData() {
        return this.feedbackData && this.feedbackData.length > 0;
    }
} 