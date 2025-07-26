// how we get the data , queries 
// encapsulate logic responsible to select data
// bulkification: most selector methodd should return a sobject list 
// method apareters hsould also be list for bulkificxations 


// with sharing because :  record‑level security
// the running user’s sharing rules (who can see which records) when this Apex executes. 
// Without it, your selector could return records the user isn’t supposed to see.

public with sharing class CustomerFeedbackSelector extends fflib_SObjectSelector {
    
    public CustomerFeedbackSelector() { 
        super(); 
    }
    
    public CustomerFeedbackSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS) {
        super(includeFieldSetFields, enforceCRUD, enforceFLS);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Customer_Feedback__c.Id,
            Customer_Feedback__c.Name,
            Customer_Feedback__c.CreatedDate,
            Customer_Feedback__c.LastModifiedDate,
            Customer_Feedback__c.Customer_Name__c,
            Customer_Feedback__c.Customer_Email__c,
            Customer_Feedback__c.Feedback_Type__c,
            Customer_Feedback__c.Description__c,
            Customer_Feedback__c.Status__c,
            Customer_Feedback__c.Priority__c,
            Customer_Feedback__c.Days_Since_Created__c,
            Customer_Feedback__c.Escalation_Required__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return Customer_Feedback__c.SObjectType;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Customer_Feedback__c> fetchAll() {
        return new CustomerFeedbackSelector().selectAllWithOptionalCriteria();
    }
    
    public List<Customer_Feedback__c> selectAllWithOptionalCriteria() {
        return (List<Customer_Feedback__c>) Database.query(
            newQueryFactory().toSOQL()
        );
    }
    
    public static Customer_Feedback__c fetchById(Id feedbackId) {
        return new CustomerFeedbackSelector().selectById(feedbackId);
    }
    
    public Customer_Feedback__c selectById(Id feedbackId) {
        return [SELECT Id, Status__c, Priority__c, Feedback_Type__c,
                       Customer_Name__c, Customer_Email__c, Description__c,
                       Days_Since_Created__c, Escalation_Required__c
                FROM Customer_Feedback__c
                WHERE Id = :feedbackId 
                LIMIT 1];
    }
    
    public List<Customer_Feedback__c> selectByStatus(String status) {
        return [SELECT Id, Name, CreatedDate, LastModifiedDate,
                       Customer_Name__c, Customer_Email__c,
                       Feedback_Type__c, Description__c, Status__c, Priority__c,
                       Days_Since_Created__c, Escalation_Required__c
                FROM Customer_Feedback__c
                WHERE Status__c = :status
                ORDER BY CreatedDate DESC];
    }
    
    public List<Customer_Feedback__c> selectByType(String feedbackType) {
        return [SELECT Id, Name, CreatedDate, LastModifiedDate,
                       Customer_Name__c, Customer_Email__c,
                       Feedback_Type__c, Description__c, Status__c, Priority__c,
                       Days_Since_Created__c, Escalation_Required__c
                FROM Customer_Feedback__c
                WHERE Feedback_Type__c = :feedbackType
                ORDER BY CreatedDate DESC];
    }
} 