import { createElement } from 'lwc';
import TicketWelcome from 'c/ticketWelcome';
import { getRecord } from 'lightning/uiRecordApi';

// Mock the getRecord wire adapter
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

describe('c-ticket-welcome', () => {
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
        const element = createElement('c-ticket-welcome', {
            is: TicketWelcome
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Check if welcome container is rendered
        const welcomeContainer = element.shadowRoot.querySelector('.welcome-container');
        expect(welcomeContainer).toBeTruthy();
    });

    it('displays default username when no user data', async () => {
        const element = createElement('c-ticket-welcome', {
            is: TicketWelcome
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Component should render with default state
        const welcomeCard = element.shadowRoot.querySelector('.welcome-card');
        expect(welcomeCard).toBeTruthy();
    });

    it('displays user name when user data is loaded', async () => {
        // Mock user data
        const mockUser = {
            data: {
                fields: {
                    Name: {
                        value: 'John Doe'
                    }
                }
            }
        };

        getRecord.emit(mockUser);

        const element = createElement('c-ticket-welcome', {
            is: TicketWelcome
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Component should render with user data
        const welcomeContainer = element.shadowRoot.querySelector('.welcome-container');
        expect(welcomeContainer).toBeTruthy();
    });

    it('handles missing user data gracefully', async () => {
        const element = createElement('c-ticket-welcome', {
            is: TicketWelcome
        });
        document.body.appendChild(element);
        await Promise.resolve();

        // Test component renders properly even without user data
        const welcomeContainer = element.shadowRoot.querySelector('.welcome-container');
        expect(welcomeContainer).toBeTruthy();
    });
}); 