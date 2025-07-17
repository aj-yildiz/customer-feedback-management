import { createElement } from 'lwc';
import FeedbackListTable from 'c/feedbackListTable';

describe('c-feedback-list-table', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    it('renders correctly', async () => {
        // Create component
        const element = createElement('c-feedback-list-table', {
            is: FeedbackListTable
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Check if table is rendered
        const table = element.shadowRoot.querySelector('table');
        expect(table).toBeTruthy();
    });

    it('renders with feedback data', async () => {
        const mockFeedback = [
            {
                Id: '001xx000004TmiQAAS',
                Name: 'CF-0001',
                ece__Customer_Name__c: 'John Doe',
                ece__Customer_Email__c: 'john@example.com',
                ece__Feedback_Type__c: 'Bug',
                ece__Description__c: 'Sample feedback',
                ece__Status__c: 'New'
            }
        ];

        const element = createElement('c-feedback-list-table', {
            is: FeedbackListTable
        });
        element.feedbacks = mockFeedback;
        document.body.appendChild(element);
        await Promise.resolve();

        // Check if table structure exists
        const table = element.shadowRoot.querySelector('table');
        expect(table).toBeTruthy();
    });

    it('renders empty state', async () => {
        const element = createElement('c-feedback-list-table', {
            is: FeedbackListTable
        });
        element.feedbacks = [];
        document.body.appendChild(element);
        await Promise.resolve();

        // Component should still render table structure
        const table = element.shadowRoot.querySelector('table');
        expect(table).toBeTruthy();
    });
}); 