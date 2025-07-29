// DOMAIN CLASS encapsulate the domain logic for the Customer_Feedback__c object
// business rules for the object validations, triggers, handlers)


//OUR CONSTRUCTOR virtual so we can subclass it if needed.
public virtual class CustomerFeedbackDomain extends fflib_SObjectDomain {
    // fflibSObjectDomain is a base class for all domain classes
    
    //I inherits from fflib_SObjectDomain, so you get a Records 
    //property (a List<SObject>) and lifecycle hooks (onApplyDefaults(), onValidate(), etc.).


    //inner consturtor to cast the list of Customer_Feedback__c records to a list of SObject
    //Casts your strongly-typed List<Customer_Feedback__c> into the base List<SObject> that fflib_SObjectDomain expects.

    public CustomerFeedbackDomain(List<Customer_Feedback__c> records) { 
        super((List<SObject>) records);  // casting 
    }

    
   // a nested (inner) class named Constructor.
   // Its job is solely to give the FFLib Unit‑of‑Work framework a way to
   // create your domain when all it has is a List<SObject>
    //when you register new or dirty SObjects,
    // under the hood it needs to spin up your domain class
    // to run the lifecycle hooks. 
    // It finds your Constructor inner class, calls its construct() method, and gets back an instance of CustomerFeedbackDomain.

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        //create a new instance of the domain class and pass it the list of records 
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CustomerFeedbackDomain((List<Customer_Feedback__c>) sObjectList);
        }
    }

    
    
    //  onApplyDefaults() is called after the records are inserted, but before they are validated.
    //  This is where we set default values for the records.
    
    
    // Records is a List<SObject> that you cast to your typed list.

    //looping over the records and setting the default values for the records. before any DML 
    //set default values for the records.
    public override void onApplyDefaults() { 
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            if(feedback.Status__c == null) {
                feedback.Status__c = 'New';
            }
            if(feedback.Priority__c == null) {
                feedback.Priority__c = 'Medium';
            }
        }
    }
    
    // we have onValidate method that gets called 
    // onValidate() is called after the records are inserted,
    // before any DML actually hits the database.
    public override void onValidate() {
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            // Validate description is not blank
            if(String.isBlank(feedback.Description__c)) {
                feedback.Description__c.addError('Description is required');
            }
            
            // Validate email when status is closed
            if(feedback.Status__c == 'Closed' && String.isBlank(feedback.Customer_Email__c)) {
                feedback.Customer_Email__c.addError('Email is required when closing feedback');
            }
                        
            // Validate feedback type is valid
            Set<String> validTypes = new Set<String>{'Bug', 'Feature Request', 'General Inquiry'};
            if(feedback.Feedback_Type__c != null && !validTypes.contains(feedback.Feedback_Type__c)) {
                feedback.Feedback_Type__c.addError('Invalid feedback type');
            }
            
            // Validate priority is valid
            Set<String> validPriorities = new Set<String>{'Low', 'Medium', 'High'};
            if(feedback.Priority__c != null && !validPriorities.contains(feedback.Priority__c)) {
                feedback.Priority__c.addError('Invalid priority value');
            }
        }
    } 

    
    // a domain‑level operation that bulk‑changes the Status__c field.
    // domain‑level operation that bulk‑changes the Status__c field on all the Customer_Feedback__c records in your Records list, 
   //  while enforcing your business rules and queuing the updates in the FFLib Unit of Work.
    public void changeStatus(String newStatus, fflib_ISObjectUnitOfWork uow) {
        validateStatusTransition(newStatus);
        
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            feedback.Status__c = newStatus;
            uow.registerDirty(feedback);
        }
    }
    

    // validateStatusTransition guards all status changes against your allowed set and the "no re‑open" rule.
    // assignToAgent and escalateFeedback are higher‑level operations that change status and queue the updates in bulk.
    // Any violation throws a DomainException, halting execution with a meaningful message.
    
    private void validateStatusTransition(String newStatus) {
        Set<String> validStatuses = new Set<String>{'New', 'In Progress', 'Resolved', 'Closed'};
        if(!validStatuses.contains(newStatus)) {
            throw new DomainException('Invalid status: ' + newStatus);
        }
        
        // Business rule: Can't go from Closed back to other statuses
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            if(feedback.Status__c == 'Closed' && newStatus != 'Closed') {
                throw new DomainException('Cannot change status from Closed to ' + newStatus);
            }
        }
    }
    
    // assignToAgent is a higher‑level operation that changes status and queues the updates in bulk.
    // Any violation throws a DomainException, halting execution with a meaningful message.
    public void assignToAgent(String agentId, fflib_ISObjectUnitOfWork uow) {
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            // Would assign to agent if we had that field
            feedback.Status__c = 'In Progress';
            uow.registerDirty(feedback);
        }
    }
    
    // escalateFeedback is a higher‑level operation that changes status and queues the updates in bulk.
    // Any violation throws a DomainException, halting execution with a meaningful message.
    public void escalateFeedback(fflib_ISObjectUnitOfWork uow) {
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            if(feedback.Feedback_Type__c == 'Bug') {
                feedback.Status__c = 'In Progress';
                uow.registerDirty(feedback);
            }
        }
    }
    
    public class DomainException extends Exception {}
} 