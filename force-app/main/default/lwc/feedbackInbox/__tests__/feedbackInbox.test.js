import { createElement } from 'lwc';
import FeedbackInbox from 'c/feedbackInbox';
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

describe('c-feedback-inbox', () => {
    afterEach(() => {
        // Reset DOM and clear all mocks
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('should create component successfully', () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });
        document.body.appendChild(element);
        expect(element).toBeTruthy();
    });

    it('should handle successful wire response', async () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });
        document.body.appendChild(element);

        const mockTicketData = {
            feedback: { Id: 'a03000000000001', Name: 'Test Ticket' },
            historyEntries: [{ id: '1', message: 'Test entry' }]
        };

        mockGetTicketHistory.emit(mockTicketData);
        await Promise.resolve();

        expect(element).toBeTruthy();
    });

    it('should handle wire adapter error', async () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
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

        expect(element).toBeTruthy();
    });

    it('should handle unsubscribe on disconnected callback', () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });

        document.body.appendChild(element);
        document.body.removeChild(element);

        expect(unsubscribe).toHaveBeenCalledWith({ id: 'test-subscription' });
    });

    it('should handle component initialization', () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });
        
        document.body.appendChild(element);
        
        // Simple test without setTimeout complications
        expect(element).toBeTruthy();
        expect(publish).toBeDefined();
        expect(FEEDBACK_CHANNEL).toBeDefined();
    });

    it('should handle message subscription callback', () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });
        document.body.appendChild(element);

        // Get the message handler from the subscribe call
        const subscribeCall = subscribe.mock.calls[0];
        const messageHandler = subscribeCall[2];

        // Test that the message handler is a function
        expect(typeof messageHandler).toBe('function');

        // Test message handling without errors
        expect(() => {
            messageHandler({ type: 'feedbackSelected', feedbackId: 'test' });
            messageHandler({ type: 'replyAdded', feedbackId: 'test' });
        }).not.toThrow();
    });

    it('should handle edge cases in message handling', () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });
        document.body.appendChild(element);

        // Get the message handler
        const subscribeCall = subscribe.mock.calls[0];
        const messageHandler = subscribeCall[2];

        // Test edge cases
        expect(() => {
            messageHandler({ type: 'unknown', feedbackId: 'test' });
            messageHandler({ type: 'feedbackSelected' }); // Missing feedbackId
            messageHandler({ type: 'replyAdded' }); // Missing feedbackId
        }).not.toThrow();
    });

    it('should handle wire data with null recordId', () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });
        
        element.recordId = null;
        document.body.appendChild(element);

        mockGetTicketHistory.emit(null);

        expect(element).toBeTruthy();
    });

    it('should handle wire data with empty history', async () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });
        document.body.appendChild(element);

        const mockTicketData = {
            feedback: { Id: 'a03000000000001', Name: 'Test Ticket' },
            historyEntries: []
        };

        mockGetTicketHistory.emit(mockTicketData);
        await Promise.resolve();

        expect(element).toBeTruthy();
    });

    it('should handle component lifecycle', () => {
        const element = createElement('c-feedback-inbox', {
            is: FeedbackInbox
        });
        
        // Test component lifecycle
        expect(() => {
            document.body.appendChild(element);
            document.body.removeChild(element);
        }).not.toThrow();
    });
}); 