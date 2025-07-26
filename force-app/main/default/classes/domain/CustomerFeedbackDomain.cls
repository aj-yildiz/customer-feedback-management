// DOMAIN CLASS
// encapsulate the domain logic for the Customer_Feedback__c object
//   business rules for the object validations, triggers, handlers)


//OUR CONSTRUCTOR 
public virtual class CustomerFeedbackDomain extends fflib_SObjectDomain {
    // fflibSObjectDomain is a base class for all domain classes
    
    //I inherits from fflib_SObjectDomain, so you get a Records 
    //property (a List<SObject>) and lifecycle hooks (onApplyDefaults(), onValidate(), etc.).
    //Declared virtual so you could subclass it if needed.

    // Constructor takes a list of Customer_Feedback__c records
    // Casts them to List<SObject> (required by the base class fflib_SObjectDomain)
    // this gives access to the Records property in your logic


    public CustomerFeedbackDomain(List<Customer_Feedback__c> records) { 
        super((List<SObject>) records);  // casting 
    }
    // gets the arguments and passes it to the super constructor

    //Casts your strongly-typed List<Customer_Feedback__c> into the base List<SObject> that fflib_SObjectDomain expects.
    // create enw instance of a domain class thru 
    
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

    
    
    // 1. onApplyDefaults() is called after the records are inserted, but before they are validated.
    // 2. This is where you can set default values for the records.
    // 3. In this case, we set the Status__c to 'New' and the Priority__c to 'Medium' if they are not set.
    
    // Before any DML (insert or update) occurs.
    // Records is a List<SObject> that you cast to your typed list.
    // You loop over each Customer_Feedback__c record in memory.
    // If Status__c or Priority__c is still null, you assign a sensible default.

    public override void onApplyDefaults() { // ` — Set default values before validation
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
    //  onValidate() is called after the records are inserted,
    // but before  but before any DML actually hits the database.
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
    
    public void assignToAgent(String agentId, fflib_ISObjectUnitOfWork uow) {
        for(Customer_Feedback__c feedback : (List<Customer_Feedback__c>) Records) {
            // Would assign to agent if we had that field
            feedback.Status__c = 'In Progress';
            uow.registerDirty(feedback);
        }
    }
    
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