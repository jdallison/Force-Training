trigger CourseCalendarCreate on Opportunity (after insert, after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            CourseTriggerHandler.ManageCourseEvents(Trigger.new,Trigger.oldMap);
            CourseTriggerHandler.updateCourseName(Trigger.new);
        }
        else if(Trigger.isUpdate){
            CourseTriggerHandler.ManageCourseEvents(Trigger.new,Trigger.oldMap);
            CourseTriggerHandler.SendEmails(Trigger.new);
            CourseTriggerHandler.OppsInvoices(Trigger.new,Trigger.oldMap);
        }
    }
}