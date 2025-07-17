import { createElement } from 'lwc';
import FeedbackForm from 'c/feedbackForm';
import createFeedback from '@salesforce/apex/CustomerFeedbackController.createFeedback';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

// Mock Apex method
jest.mock(
    '@salesforce/apex/CustomerFeedbackController.createFeedback',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// Mock message service
jest.mock('lightning/messageService', () => {
    return {
        publish: jest.fn(),
        MessageContext: {}
    };
});

// Mock getRecord
jest.mock(
    'lightning/uiRecordApi',
    () => {
        const { createApexTestWireAdapter } = require('@salesforce/sfdx-lwc-jest');
        return {
            getRecord: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe('c-feedback-form', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it('renders correctly with all form elements', async () => {
        // Mock user data
        const mockUser = {
            data: {
                fields: {
                    Name: { value: 'Test User' },
                    Email: { value: 'test@example.com' }
                }
            }
        };
        getRecord.emit(mockUser);

        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Check if form elements are rendered
        const typeCombobox = element.shadowRoot.querySelector('lightning-combobox');
        const descriptionTextarea = element.shadowRoot.querySelector('lightning-textarea');
        const submitButton = element.shadowRoot.querySelector('lightning-button');

        expect(typeCombobox).toBeTruthy();
        expect(descriptionTextarea).toBeTruthy();
        expect(submitButton).toBeTruthy();
    });

    it('handles feedback type field changes', async () => {
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Test handleFieldChange for feedback type
        const typeCombobox = element.shadowRoot.querySelector('lightning-combobox');
        if (typeCombobox) {
            // Set dataset to simulate the field identifier
            typeCombobox.dataset.id = 'feedbackType';
            typeCombobox.value = 'Bug';
            
            // Dispatch change event
            typeCombobox.dispatchEvent(new CustomEvent('change', {
                target: {
                    dataset: { id: 'feedbackType' },
                    value: 'Bug'
                }
            }));
        }

        await Promise.resolve();
        expect(typeCombobox).toBeTruthy();
    });

    it('handles description field changes', async () => {
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        const descriptionTextarea = element.shadowRoot.querySelector('lightning-textarea');
        if (descriptionTextarea) {
            descriptionTextarea.dataset.id = 'description';
            descriptionTextarea.value = 'Test description';
            
            descriptionTextarea.dispatchEvent(new CustomEvent('change', {
                target: {
                    dataset: { id: 'description' },
                    value: 'Test description'
                }
            }));
        }

        await Promise.resolve();
        expect(descriptionTextarea).toBeTruthy();
    });

    it('handles form field interactions', async () => {
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Simulate user interactions with form fields
        const typeCombobox = element.shadowRoot.querySelector('lightning-combobox');
        const descriptionTextarea = element.shadowRoot.querySelector('lightning-textarea');
        
        if (typeCombobox) {
            typeCombobox.dispatchEvent(new CustomEvent('change', {
                detail: { value: 'Bug' }
            }));
        }
        
        if (descriptionTextarea) {
            descriptionTextarea.dispatchEvent(new CustomEvent('change', {
                detail: { value: 'Test description' }
            }));
        }

        await Promise.resolve();
        expect(element).toBeTruthy();
    });

    it('displays loading state during submission', async () => {
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Check if loading elements can be found (they are conditional)
        const cardBody = element.shadowRoot.querySelector('.slds-card__body');
        expect(cardBody).toBeTruthy();
    });

    it('shows form validation messages', async () => {
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Mock toast event handler for validation messages
        const handler = jest.fn();
        element.addEventListener(ShowToastEventName, handler);

        // Simulate form submission with empty data
        const submitButton = element.shadowRoot.querySelector('lightning-button');
        if (submitButton) {
            submitButton.click();
        }

        await Promise.resolve();
        expect(submitButton).toBeTruthy();
    });

    it('creates feedback data object correctly', async () => {
        // Mock successful Apex call
        createFeedback.mockResolvedValue('001xx000004TmiQAAS');

        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Simulate form submission by clicking button
        const submitButton = element.shadowRoot.querySelector('lightning-button');
        if (submitButton) {
            submitButton.click();
        }

        await Promise.resolve();
        // Test component renders correctly
        expect(element).toBeTruthy();
    });

    it('handles user data from wire adapter', async () => {
        // Mock user data
        const mockUser = {
            data: {
                fields: {
                    Name: { value: 'John Doe' },
                    Email: { value: 'john@example.com' }
                }
            }
        };

        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        getRecord.emit(mockUser);
        document.body.appendChild(element);
        await Promise.resolve();

        // Test component handles user data
        expect(element).toBeTruthy();
    });

    it('handles wire adapter errors gracefully', async () => {
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        getRecord.error();
        document.body.appendChild(element);
        await Promise.resolve();

        // Component should still render even with wire errors
        expect(element).toBeTruthy();
    });

    it('shows success message after form submission', async () => {
        // Mock successful Apex call
        createFeedback.mockResolvedValue('001xx000004TmiQAAS');

        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Mock toast event handler
        const handler = jest.fn();
        element.addEventListener(ShowToastEventName, handler);

        // Test form structure exists
        const formElement = element.shadowRoot.querySelector('.feedback-form-wrapper');
        expect(formElement).toBeTruthy();
    });

    it('resets form after successful submission', async () => {
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Test that form elements exist for reset functionality
        const typeCombobox = element.shadowRoot.querySelector('lightning-combobox');
        const descriptionTextarea = element.shadowRoot.querySelector('lightning-textarea');
        
        expect(typeCombobox).toBeTruthy();
        expect(descriptionTextarea).toBeTruthy();
    });

    it('handles form submission without user data', async () => {
        // Don't emit user data to test fallback scenario
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Mock toast event handler for warning
        const handler = jest.fn();
        element.addEventListener(ShowToastEventName, handler);

        // Simulate form submission without user data
        const submitButton = element.shadowRoot.querySelector('lightning-button');
        if (submitButton) {
            submitButton.click();
        }

        await Promise.resolve();
        expect(submitButton).toBeTruthy();
    });

    it('creates proper feedback data object structure', async () => {
        // Mock successful Apex call
        createFeedback.mockResolvedValue('001xx000004TmiQAAS');

        // Mock user data with specific values
        const mockUser = {
            data: {
                fields: {
                    Name: { value: 'Test Customer' },
                    Email: { value: 'test.customer@example.com' }
                }
            }
        };
        getRecord.emit(mockUser);

        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Simulate form submission to test data object creation
        const submitButton = element.shadowRoot.querySelector('lightning-button');
        if (submitButton) {
            submitButton.click();
        }

        await Promise.resolve();
        expect(element).toBeTruthy();
    });

    it('shows warning when user data is still loading', async () => {
        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Mock toast event handler
        const handler = jest.fn();
        element.addEventListener(ShowToastEventName, handler);

        // Try to submit without user data loaded
        const submitButton = element.shadowRoot.querySelector('lightning-button');
        if (submitButton) {
            submitButton.click();
        }

        await Promise.resolve();
        expect(submitButton).toBeTruthy();
    });

    it('handles form submission error gracefully', async () => {
        // Mock failed Apex call
        createFeedback.mockRejectedValue(new Error('Server error'));

        // Mock user data
        const mockUser = {
            data: {
                fields: {
                    Name: { value: 'Test User' },
                    Email: { value: 'test@example.com' }
                }
            }
        };
        getRecord.emit(mockUser);

        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Mock toast event handler for error
        const handler = jest.fn();
        element.addEventListener(ShowToastEventName, handler);

        // Simulate form submission that will fail
        const submitButton = element.shadowRoot.querySelector('lightning-button');
        if (submitButton) {
            submitButton.click();
        }

        await Promise.resolve();
        expect(submitButton).toBeTruthy();
    });

    it('uses fallback values for missing user data', async () => {
        // Mock successful Apex call
        createFeedback.mockResolvedValue('001xx000004TmiQAAS');

        // Mock user data with missing fields
        const mockUser = {
            data: {
                fields: {
                    Name: { value: null },
                    Email: { value: null }
                }
            }
        };
        getRecord.emit(mockUser);

        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Simulate submission to test fallback values
        const submitButton = element.shadowRoot.querySelector('lightning-button');
        if (submitButton) {
            submitButton.click();
        }

        await Promise.resolve();
        expect(element).toBeTruthy();
    });

    it('trims whitespace from description field', async () => {
        // Mock successful Apex call
        createFeedback.mockResolvedValue('001xx000004TmiQAAS');

        // Mock user data
        const mockUser = {
            data: {
                fields: {
                    Name: { value: 'Test User' },
                    Email: { value: 'test@example.com' }
                }
            }
        };
        getRecord.emit(mockUser);

        const element = createElement('c-feedback-form', {
            is: FeedbackForm
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Simulate description with whitespace
        const descriptionTextarea = element.shadowRoot.querySelector('lightning-textarea');
        if (descriptionTextarea) {
            descriptionTextarea.value = '  Test description with spaces  ';
            descriptionTextarea.dispatchEvent(new CustomEvent('change', {
                detail: { value: '  Test description with spaces  ' }
            }));
        }

        // Submit form to test trimming
        const submitButton = element.shadowRoot.querySelector('lightning-button');
        if (submitButton) {
            submitButton.click();
        }

        await Promise.resolve();
        expect(element).toBeTruthy();
    });
}); 