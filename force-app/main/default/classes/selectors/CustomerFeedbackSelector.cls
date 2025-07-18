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
            Customer_Feedback__c.Priority__c
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
                       Customer_Name__c, Customer_Email__c, Description__c
                FROM Customer_Feedback__c
                WHERE Id = :feedbackId 
                LIMIT 1];
    }
    
    public List<Customer_Feedback__c> selectByStatus(String status) {
        return [SELECT Id, Name, CreatedDate, LastModifiedDate,
                       Customer_Name__c, Customer_Email__c,
                       Feedback_Type__c, Description__c, Status__c, Priority__c
                FROM Customer_Feedback__c
                WHERE Status__c = :status
                ORDER BY CreatedDate DESC];
    }
    
    public List<Customer_Feedback__c> selectByType(String feedbackType) {
        return [SELECT Id, Name, CreatedDate, LastModifiedDate,
                       Customer_Name__c, Customer_Email__c,
                       Feedback_Type__c, Description__c, Status__c, Priority__c
                FROM Customer_Feedback__c
                WHERE Feedback_Type__c = :feedbackType
                ORDER BY CreatedDate DESC];
    }
} 