public with sharing class CourseTriggerHandler {
public static boolean hasExecuted = False;

    public static void ManageCourseEvents(list<Opportunity> oppsIn, Map<Id,Opportunity> oldOppsIn){
    if(hasExecuted == False){    
    List<Event> lstNewEvents = new List<Event>();

    List<Opportunity> oppsToInsert = new List<Opportunity>();

    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    List<Opportunity> oppsToDelete = new List<Opportunity>();

    Set<Id> OppSet = new Set<Id>();

    for(Opportunity opp: OppsIn){
        
        OppSet.Add(opp.Id);
            If(oldOppsIn == Null || oldOppsIn.get(opp.id) == Null){
                oppsToInsert.Add(opp);
            } 
            else If(opp.StageName == 'Cancelled' && oldOppsIn.get(opp.id).StageName != 'Cancelled') {
                oppsToDelete.Add(opp);
            }
            else(oppsToUpdate.Add(opp));
    }

    Map<Id,Opportunity> InstructorMap = new Map<Id,Opportunity>([SELECT Id, Course_Rate__r.User__c FROM Opportunity WHERE Id IN : OppSet]);
    
    if(oppsToInsert.size()>0){
        for(Opportunity course: oppsToInsert){
            Event e = new Event();
            
            e.StartDateTime = course.Start_Date__c;
            e.EndDateTime = course.CloseDate;
            e.Subject = course.Type + ' - ' + course.Start_Date__c.format();
            e.Location = course.Location__c;
            e.OwnerId = InstructorMap.get(course.Id).Course_Rate__r.User__c;
            e.WhatId = course.Id;
            lstNewEvents.add(e);
        }
    }

    System.debug (lstNewEvents);
    insert lstNewEvents;

    if(oppsToDelete.size()>0){
        List<Event> delEvents = [SELECT Id FROM Event WHERE WhatId IN : oppsToDelete];
        delete delEvents;
    }

    if(oppsToUpdate.size()>0){
        List<Event> updEvents = [SELECT Id, WhatId FROM Event WHERE WhatId IN : oppsToUpdate];
        Map<Id, Event> eventMap = new Map<Id, Event>();

        for(Event event: updEvents){
            eventMap.put(event.WhatId, event);
        }

        for(Opportunity opp: oppsToUpdate){
            Event e = eventMap.get(opp.Id);
            e.StartDateTime = opp.Start_Date__c;
            e.EndDateTime = opp.CloseDate;
            e.Location = opp.Location__c;
            e.Subject = opp.Type + ' - ' + opp.Start_Date__c.format();
            eventMap.put(opp.id, e);
        }
        update eventMap.values();
    }
    }    
}

public static void updateCourseName(List<Opportunity> oppsToRename){
    List<Opportunity> lstOpp = [SELECT Id, Name, Type, Start_Date__c FROM Opportunity WHERE Id IN : oppsToRename];
    for(Opportunity opp: lstOpp){
        opp.Name = opp.Type + ' - ' + opp.Start_Date__c.format();
    }
update lstOpp;
}

public static void sendEmails(List<Opportunity> oppsToSend){

if(hasExecuted == False){
    List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
    EmailTemplate et=[SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'Course Deleted' Limit 1];
    EmailTemplate etScheduled=[SELECT Id, Subject, Body FROM EmailTemplate WHERE Name = 'New Course Assigned' Limit 1];
    List<Opportunity> lstCon = [SELECT Id, Name, Course_Rate__r.User__r.Name, Course_Rate__r.User__r.email, StageName FROM Opportunity WHERE Id IN : oppsToSend LIMIT 9];
    List<String> toAddresses = new List<String>();
    for(Opportunity opp : lstCon){
        if(opp.StageName == 'Cancelled'){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            toAddresses.Add(opp.Course_Rate__r.User__r.email);
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('System Admin');
            mail.setTemplateId(et.id);
            mail.setSubject(et.Subject);
            mail.setHTMLBody(et.Body);
            mail.setWhatId(opp.Id);
            mailsToSend.add(mail);
        }
        else if(opp.StageName == 'Scheduled'){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            toAddresses.Add(opp.Course_Rate__r.User__r.email);
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('System Admin');
            mail.setTemplateId(etScheduled.id);
            mail.setSubject(etScheduled.Subject);
            mail.setHTMLBody(etScheduled.Body);
            mail.setWhatId(opp.Id);
            mailsToSend.add(mail);
        }
    }
    messaging.sendEmail(mailsToSend);

    //mailsToSend.clear();
    }
}


public static void OppsInvoices(list<Opportunity> oppsIn, Map<Id,Opportunity> oldOppsIn){
system.Debug('Executing OppsInvoices Method');
system.Debug(OppsIn);
system.Debug(hasExecuted);
    
if(hasExecuted == False){
    Set<Id> InvSet = new Set<Id>();
    List<Opportunity> OpportunityList = new List<Opportunity>();
    List<Invoice__c> iList = new List<Invoice__c>();
    List<Invoice_Line_Item__c> lineList = new List<Invoice_Line_Item__c>();

    for(Opportunity opp: OppsIn){
        system.Debug(opp);
        if(opp.StageName == 'Completed'){
            system.Debug(opp);
            InvSet.Add(opp.Id);
            OpportunityList.add(opp);
        }
    }
    system.Debug(OpportunityList.size());
    system.Debug(OpportunityList);
    
    Map<Id,Opportunity> InvoiceMap = new Map<Id,Opportunity>([SELECT Id, Opportunity.Course_duration__c FROM Opportunity WHERE Id IN : InvSet]);

    if(OpportunityList.size()>0){

        for(Opportunity course: OpportunityList){
            Invoice__c i = new Invoice__c();
            i.RecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Service Invoice').getRecordTypeId();
            i.Name = 'g';
            i.Invoice_Date__c = course.CloseDate;
            i.Course__c = course.Id;
            iList.add(i);
        }

        insert iList;
        
        // for(Invoice__c invoice: iList){
		// 	integer Duration = integer.valueOf(invoice.Course__r.Course_Duration__c);
        //     for(integer i = 0; i < Duration; i++){
        //         //e.OwnerId = InstructorMap.get(course.Id).Course_Rate__r.User__c;

        //     Invoice_Line_Item__c line = new Invoice_Line_Item__c();

        //     line.RecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        //     line.Date__c = invoice.Invoice_Date__c + i;
        //     line.Amount__c = invoice.Sub_Total__c / invoice.Course__r.Course_Duration__c;
        //     line.Description__c = 'Day ' + (i + 1) + ' of course:' + invoice.Course__c;
        //     lineList.add(line);
        //     }


        // insert lineList;
        // }
    }        
}
    hasExecuted = True;
    }
}