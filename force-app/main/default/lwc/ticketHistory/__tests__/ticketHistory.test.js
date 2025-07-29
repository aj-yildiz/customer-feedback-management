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
jest.mock('lightning/messageService', () => {
    return {
        publish: jest.fn(),
        subscribe: jest.fn(),
        unsubscribe: jest.fn(),
        MessageContext: jest.fn()
    };
});

// Mock the message channel
jest.mock('@salesforce/messageChannel/FeedbackChannel__c', () => ({
    default: {}
}), { virtual: true });

// Mock refreshApex
jest.mock('@salesforce/apex', () => {
    return {
        refreshApex: jest.fn().mockResolvedValue(undefined)
    };
}, { virtual: true });

describe('c-ticket-history', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
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

    it('should handle successful wire response with history data', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        const mockTicketHistory = {
            feedback: {
                Name: 'Test Feedback',
                Id: 'a03000000000001'
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

        // Emit data from the wire adapter
        mockGetTicketHistory.emit(mockTicketHistory);

        expect(element.ticketHistory).toEqual(mockTicketHistory);
        expect(element.historyEntries).toEqual(mockTicketHistory.historyEntries);
        expect(element.error).toBeUndefined();
    });

    it('should handle wire adapter error', () => {
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

        // Emit error from the wire adapter
        mockGetTicketHistory.error(mockError);

        expect(element.error).toEqual(mockError);
        expect(element.ticketHistory).toBeNull();
        expect(element.historyEntries).toEqual([]);
    });

    it('should subscribe to message channel on connected callback', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        
        // Mock the subscription
        const mockSubscription = { id: 'test-subscription' };
        subscribe.mockReturnValue(mockSubscription);

        document.body.appendChild(element);

        // Allow setTimeout to execute
        return Promise.resolve().then(() => {
            expect(subscribe).toHaveBeenCalledWith(
                element.messageContext,
                FEEDBACK_CHANNEL,
                expect.any(Function)
            );
            expect(element.subscription).toEqual(mockSubscription);
        });
    });

    it('should unsubscribe from message channel on disconnected callback', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        
        // Mock the subscription
        const mockSubscription = { id: 'test-subscription' };
        element.subscription = mockSubscription;

        document.body.appendChild(element);
        document.body.removeChild(element);

        expect(unsubscribe).toHaveBeenCalledWith(mockSubscription);
    });

    it('should handle replyAdded message and refresh apex', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        element.recordId = 'a03000000000001';
        element.wiredHistoryResult = { data: null };
        
        document.body.appendChild(element);

        // Simulate receiving a replyAdded message
        const mockMessage = {
            type: 'replyAdded',
            feedbackId: 'a03000000000001'
        };

        element.handleMessage(mockMessage);

        expect(refreshApex).toHaveBeenCalledWith(element.wiredHistoryResult);
    });

    it('should handle feedbackSelected message', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        const mockMessage = {
            type: 'feedbackSelected',
            feedbackId: 'a03000000000002'
        };

        element.handleMessage(mockMessage);

        expect(element.recordId).toBe('a03000000000002');
    });

    it('should handle requestCurrentFeedback message and publish current selection', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        element.recordId = 'a03000000000001';
        document.body.appendChild(element);

        const mockMessage = {
            type: 'requestCurrentFeedback'
        };

        element.handleMessage(mockMessage);

        expect(publish).toHaveBeenCalledWith(
            element.messageContext,
            FEEDBACK_CHANNEL,
            {
                type: 'feedbackSelected',
                feedbackId: 'a03000000000001'
            }
        );
    });

    it('should not publish when no recordId for requestCurrentFeedback', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        element.recordId = null;
        document.body.appendChild(element);

        const mockMessage = {
            type: 'requestCurrentFeedback'
        };

        element.handleMessage(mockMessage);

        expect(publish).not.toHaveBeenCalled();
    });

    it('should request current selection in connected callback', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        
        document.body.appendChild(element);

        // Wait for setTimeout to execute
        return new Promise(resolve => {
            setTimeout(() => {
                expect(publish).toHaveBeenCalledWith(
                    element.messageContext,
                    FEEDBACK_CHANNEL,
                    {
                        type: 'requestCurrentFeedback'
                    }
                );
                resolve();
            }, 150);
        });
    });

    it('should return correct showHistory getter value', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        element.recordId = null;
        expect(element.showHistory).toBe(false);

        element.recordId = 'a03000000000001';
        expect(element.showHistory).toBe(true);
    });

    it('should return correct hasHistory getter value', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        element.historyEntries = [];
        expect(element.hasHistory).toBe(false);

        element.historyEntries = null;
        expect(element.hasHistory).toBe(false);

        element.historyEntries = [{ id: '1', message: 'Test' }];
        expect(element.hasHistory).toBe(true);
    });

    it('should return correct ticketName getter value', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        element.recordId = 'a03000000000001';
        element.ticketHistory = null;
        expect(element.ticketName).toBe('a03000000000001');

        element.ticketHistory = {
            feedback: { Name: 'Test Feedback Name' }
        };
        expect(element.ticketName).toBe('Test Feedback Name');
    });

    it('should return correct selectedFeedbackName getter value', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        element.recordId = 'a03000000000001';
        element.ticketHistory = {
            feedback: { Name: 'Selected Feedback' }
        };
        document.body.appendChild(element);

        expect(element.selectedFeedbackName).toBe('Selected Feedback');
    });

    it('should handle different message types without errors', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        const unknownMessage = {
            type: 'unknownType',
            data: 'test'
        };

        expect(() => {
            element.handleMessage(unknownMessage);
        }).not.toThrow();
    });

    it('should handle replyAdded message for different feedback ID', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        element.recordId = 'a03000000000001';
        element.wiredHistoryResult = { data: null };
        
        document.body.appendChild(element);

        const mockMessage = {
            type: 'replyAdded',
            feedbackId: 'a03000000000002' // Different ID
        };

        element.handleMessage(mockMessage);

        expect(refreshApex).not.toHaveBeenCalled();
    });

    it('should handle subscription already exists scenario', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        
        // Set existing subscription
        element.subscription = { id: 'existing' };
        
        document.body.appendChild(element);

        // Subscribe should not be called again if subscription exists
        expect(subscribe).not.toHaveBeenCalled();
    });

    it('should handle unsubscribe when no subscription exists', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        element.subscription = null;
        
        document.body.appendChild(element);
        
        // Call unsubscribe directly
        element.unsubscribeToMessageChannel();
        
        expect(unsubscribe).not.toHaveBeenCalled();
    });

    it('should handle wire data with null result', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        // Emit null data from the wire adapter
        mockGetTicketHistory.emit(null);

        expect(element.ticketHistory).toBeNull();
        expect(element.historyEntries).toEqual([]);
    });

    it('should handle wire data with empty history entries', () => {
        const element = createElement('c-ticket-history', {
            is: TicketHistory
        });
        document.body.appendChild(element);

        const mockTicketHistory = {
            feedback: {
                Name: 'Test Feedback',
                Id: 'a03000000000001'
            },
            historyEntries: null // Explicitly null
        };

        mockGetTicketHistory.emit(mockTicketHistory);

        expect(element.historyEntries).toEqual([]);
    });
}); 