public with sharing class CustomerFeedbackSelector extends fflib_SObjectSelector {
    public CustomerFeedbackSelector() { 
        super(ece__Customer_Feedback__c.SObjectType); 
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ece__Customer_Feedback__c.Id,
            ece__Customer_Feedback__c.Name,
            ece__Customer_Feedback__c.CreatedDate,
            ece__Customer_Feedback__c.LastModifiedDate,
            ece__Customer_Feedback__c.ece__Customer_Name__c,
            ece__Customer_Feedback__c.ece__Customer_Email__c,
            ece__Customer_Feedback__c.ece__Feedback_Type__c,
            ece__Customer_Feedback__c.ece__Description__c,
            ece__Customer_Feedback__c.ece__Status__c
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return ece__Customer_Feedback__c.SObjectType;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ece__Customer_Feedback__c> fetchAll() {
        return new CustomerFeedbackSelector().selectAllWithOptionalCriteria();
    }
    
    public List<ece__Customer_Feedback__c> selectAllWithOptionalCriteria() {
        return [SELECT Id, Name, CreatedDate, LastModifiedDate,
                       ece__Customer_Name__c, ece__Customer_Email__c,
                       ece__Feedback_Type__c, ece__Description__c, ece__Status__c
                FROM ece__Customer_Feedback__c
                ORDER BY CreatedDate DESC];
    }
    
    public static ece__Customer_Feedback__c fetchById(Id feedbackId) {
        return new CustomerFeedbackSelector().selectById(feedbackId);
    }
    
    public ece__Customer_Feedback__c selectById(Id feedbackId) {
        return [SELECT Id, ece__Status__c
                FROM ece__Customer_Feedback__c
                WHERE Id = :feedbackId 
                LIMIT 1];
    }
    
    public List<ece__Customer_Feedback__c> selectByStatus(String status) {
        return [SELECT Id, Name, CreatedDate, LastModifiedDate,
                       ece__Customer_Name__c, ece__Customer_Email__c,
                       ece__Feedback_Type__c, ece__Description__c, ece__Status__c
                FROM ece__Customer_Feedback__c
                WHERE ece__Status__c = :status
                ORDER BY CreatedDate DESC];
    }
    
    public List<ece__Customer_Feedback__c> selectByType(String feedbackType) {
        return [SELECT Id, Name, CreatedDate, LastModifiedDate,
                       ece__Customer_Name__c, ece__Customer_Email__c,
                       ece__Feedback_Type__c, ece__Description__c, ece__Status__c
                FROM ece__Customer_Feedback__c
                WHERE ece__Feedback_Type__c = :feedbackType
                ORDER BY CreatedDate DESC];
    }
} 