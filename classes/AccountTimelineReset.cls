global with sharing class AccountTimelineReset implements Schedulable {

    global void execute(SchedulableContext sc) {
           new AccountTimelineController().resetTable();         
    }
}