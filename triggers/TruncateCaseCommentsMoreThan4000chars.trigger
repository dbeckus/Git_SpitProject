trigger TruncateCaseCommentsMoreThan4000chars on CaseComment (before insert,before update) {
    for(CaseComment item:Trigger.New)
    {
        if(item.CommentBody.length()>3000)
        {
            System.debug('In loop');
            item.CommentBody= item.CommentBody.substring(0,3000);
            System.debug(item.CommentBody);
        }
    }
    
}