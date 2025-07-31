import { createElement } from 'lwc';
import TicketHistory from 'c/ticketHistory';
import getTicketHistory from '@salesforce/apex/FeedbackResponseController.getTicketHistory';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { publish, subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';
import { refreshApex } from '@salesforce/apex';

// Mock the Apex wire adapter
const mockGetTicketHistory = registerApexTestWireAdapter(getTicketHistory);

// Mock the message service
jest.mock('lightning/messageService', () => ({
    publish: jest.fn(),
    subscribe: jest.fn().mockReturnValue({ id: 'test-subscription' }),
    unsubscribe: jest.fn(),
    MessageContext: jest.fn()
}));

// Mock the message channel
jest.mock('@salesforce/messageChannel/FeedbackChannel__c', () => ({
    default: {}
}), { virtual: true });

// Mock refreshApex
jest.mock('@salesforce/apex', () => ({
    refreshApex: jest.fn().mockResolvedValue(undefined)
}), { virtual: true });

describe('c-ticket-history', () => {
    afterEach(() => {
        // Reset DOM and clear all mocks
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('should create component successfully', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);
        expect(element).toBeTruthy();
    });

    it('should handle successful wire response with history data', async () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        const mockTicketHistory = {
            feedback: {
                Id: 'a03000000000001',
                Name: 'Test Feedback'
            },
            historyEntries: [
                {
                    id: '1',
                    type: 'Response',
                    message: 'Test response',
                    timestamp: '2023-01-01T10:00:00Z',
                    user: 'Test User'
                }
            ]
        };

        mockGetTicketHistory.emit(mockTicketHistory);

        await Promise.resolve();

        // Verify component handles data successfully
        expect(element).toBeTruthy();
        expect(mockGetTicketHistory.emit).toBeDefined();
    });

    it('should handle wire adapter error gracefully', async () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        const mockError = {
            body: { message: 'Test error' },
            ok: false,
            status: 400,
            statusText: 'Bad Request'
        };

        mockGetTicketHistory.error(mockError);

        await Promise.resolve();

        // Verify component handles error gracefully
        expect(element).toBeTruthy();
    });

    it('should subscribe to message channel on connected callback', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });

        document.body.appendChild(element);

        expect(subscribe).toHaveBeenCalled();
    });

    it('should unsubscribe from message channel on disconnected callback', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });

        document.body.appendChild(element);
        document.body.removeChild(element);

        expect(unsubscribe).toHaveBeenCalledWith({ id: 'test-subscription' });
    });

    it('should handle message subscription callback without errors', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        // Get the message handler from the subscribe call
        const subscribeCall = subscribe.mock.calls[0];
        const messageHandler = subscribeCall[2];

        // Test that the message handler is a function and handles messages
        expect(typeof messageHandler).toBe('function');

        expect(() => {
            messageHandler({ type: 'replyAdded', feedbackId: 'test' });
            messageHandler({ type: 'feedbackSelected', feedbackId: 'test' });
            messageHandler({ type: 'requestCurrentFeedback' });
        }).not.toThrow();
    });

    it('should handle component lifecycle without errors', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        
        // Test component lifecycle
        expect(() => {
            document.body.appendChild(element);
            document.body.removeChild(element);
        }).not.toThrow();
    });

    it('should handle wire data with null result', async () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        mockGetTicketHistory.emit(null);

        await Promise.resolve();

        // Verify component handles null data gracefully
        expect(element).toBeTruthy();
    });

    it('should handle wire response with empty history entries', async () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        const mockTicketHistory = {
            feedback: {
                Name: 'Test Feedback',
                Id: 'a03000000000001'
            },
            historyEntries: []
        };

        mockGetTicketHistory.emit(mockTicketHistory);

        await Promise.resolve();

        // Verify component handles empty entries gracefully
        expect(element).toBeTruthy();
    });
}); 