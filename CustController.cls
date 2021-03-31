public class CustController {
 
private final Invoice__c account;
    
    public CustController() { 
        account = [SELECT Id, Invoice_Date__c, Invoice_Owner__c, Invoice_Number__c, RecordTypeId, Course__c,   Tax_rate__c,    
        VAT__c, Sub_Total__c, Name, VAT_Rate__c, Amount_After_Tax__c, Invoice_Total__c, Course__r.Instructor__c
        FROM Invoice__c 
        WHERE Id = : ApexPages.currentPage().getParameters().get('id')];
    }
       
    public Invoice__c getInvoices() {
        return account;
    }
    
    public PageReference save() {
        update account;
        return null;
    }
       
    public static List<Invoice_Line_Item__c> getlineItems() {
        List<Invoice_Line_Item__c> results = [
        SELECT Id, Amount__c,  Description__c,  Date__c, Invoice__c, Name, RecordTypeId
        FROM Invoice_Line_Item__c 
        WHERE Invoice__c = :ApexPages.currentPage().getParameters().get('id')];
        return results;
    }
       
}