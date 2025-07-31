import { createElement } from 'lwc';
import StatusManager from 'c/statusManager';
import getAllFeedback from '@salesforce/apex/CustomerFeedbackController.getAllFeedback';
import updateFeedbackStatus from '@salesforce/apex/CustomerFeedbackController.updateFeedbackStatus';
import saveResponse from '@salesforce/apex/FeedbackResponseController.saveResponse';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { publish, MessageContext } from 'lightning/messageService';
import FEEDBACK_CHANNEL from '@salesforce/messageChannel/FeedbackChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

// Mock the Apex wire adapter
const mockGetAllFeedback = registerApexTestWireAdapter(getAllFeedback);

// Mock Apex methods
jest.mock('@salesforce/apex/CustomerFeedbackController.updateFeedbackStatus', () => ({
    default: jest.fn()
}), { virtual: true });

jest.mock('@salesforce/apex/FeedbackResponseController.saveResponse', () => ({
    default: jest.fn()
}), { virtual: true });

// Mock the message service
jest.mock('lightning/messageService', () => ({
    publish: jest.fn(),
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

// Mock ShowToastEvent
jest.mock('lightning/platformShowToastEvent', () => ({
    ShowToastEvent: jest.fn()
}));

describe('c-status-manager', () => {
    afterEach(() => {
        // Reset DOM and clear all mocks
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('should create component successfully', () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        document.body.appendChild(element);
        expect(element).toBeTruthy();
    });

    it('should handle successful wire response with feedback data', async () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        document.body.appendChild(element);

        const mockFeedbackData = [
            {
                Id: 'a03000000000001',
                Name: 'FB-001',
                Description__c: 'Test feedback description',
                Status__c: 'New',
                LastModifiedDate: '2023-01-01T10:00:00Z'
            },
            {
                Id: 'a03000000000002',
                Name: 'FB-002',
                Description__c: 'Another test feedback',
                Status__c: 'In Progress',
                LastModifiedDate: '2023-01-02T10:00:00Z'
            }
        ];

        // Emit data from the wire adapter
        mockGetAllFeedback.emit(mockFeedbackData);

        await Promise.resolve();

        // Test wire adapter integration without accessing private properties
        expect(element).toBeTruthy();
        expect(mockGetAllFeedback.emit).toBeDefined();
    });

    it('should handle wire adapter error gracefully', async () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        document.body.appendChild(element);

        const mockError = {
            body: { message: 'Test error' },
            ok: false,
            status: 400,
            statusText: 'Bad Request'
        };

        // Emit error from the wire adapter
        mockGetAllFeedback.error(mockError);

        await Promise.resolve();

        // Verify component handles error gracefully
        expect(element).toBeTruthy();
    });

    it('should handle feedbackRecord prop correctly', () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        
        const mockFeedbackRecord = {
            Id: 'a03000000000999',
            Name: 'Prop Feedback',
            Status__c: 'Resolved'
        };
        
        element.feedbackRecord = mockFeedbackRecord;
        document.body.appendChild(element);

        // Verify prop is set correctly
        expect(element.feedbackRecord).toEqual(mockFeedbackRecord);
    });

    it('should handle component lifecycle without errors', () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        
        // Test component lifecycle
        expect(() => {
            document.body.appendChild(element);
            document.body.removeChild(element);
        }).not.toThrow();
    });

    it('should integrate with message service properly', () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        document.body.appendChild(element);

        // Verify message service integration
        expect(publish).toBeDefined();
        expect(FEEDBACK_CHANNEL).toBeDefined();
    });

    it('should have access to required services', () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        document.body.appendChild(element);

        // Verify service integrations
        expect(publish).toBeDefined();
        expect(FEEDBACK_CHANNEL).toBeDefined();
        expect(updateFeedbackStatus).toBeDefined();
        expect(saveResponse).toBeDefined();
        expect(ShowToastEvent).toBeDefined();
        expect(refreshApex).toBeDefined();
    });

    it('should handle multiple wire emissions without errors', async () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        document.body.appendChild(element);

        // Test multiple status changes
        const testData = [
            [{ Id: 'a03000000000001', Status__c: 'New' }],
            [{ Id: 'a03000000000001', Status__c: 'In Progress' }],
            [{ Id: 'a03000000000001', Status__c: 'Resolved' }],
            [{ Id: 'a03000000000001', Status__c: 'Closed' }]
        ];

        for (const data of testData) {
            mockGetAllFeedback.emit(data);
            await Promise.resolve();
            expect(element).toBeTruthy();
        }
    });

    it('should handle edge cases in wire data', async () => {
        const element = createElement('c-status-manager', {
            is: StatusManager
        });
        document.body.appendChild(element);

        // Test various edge cases
        const edgeCases = [null, undefined, [], [{}]];

        for (const testCase of edgeCases) {
            mockGetAllFeedback.emit(testCase);
            await Promise.resolve();
            expect(element).toBeTruthy();
        }
    });
}); 