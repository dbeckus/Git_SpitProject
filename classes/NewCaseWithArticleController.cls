/*
 * Controller of page NewCaseWithArticle
 */
public with sharing class NewCaseWithArticleController 
{
    private Case cs;
    private static final Id TechnicalSupportRecordTypeId = '012500000005Aui';
    
    public NewCaseWithArticleController(ApexPages.StandardController controller)
    {
        cs = (Case)controller.getRecord();
        RenderPage = 1;
    }

    public Integer  RenderPage      { get; private set; }
    public Boolean  SearchCompleted { get; private set; }

    public String   Keyword         { get; set; }
    public String   ArticleId       { get; set; }
    public KB__kav  Article
    {
        get
        {
            if(String.isNotBlank(ArticleId))
            {
                List<KB__kav> articles = [select Id, Title, Summary, Category__c, Solution__c, ArticleNumber, LastPublishedDate from KB__kav where KnowledgeArticleId = :ArticleId and PublishStatus = 'Online' and IsLatestVersion = true limit 1];
                if(articles.size() > 0)
                {
                    return articles[0];
                }
            }
            return new KB__kav();
        }
    }
    
    public List<ArticleInfo> SearchResult 
    {
        get
        {
            List<ArticleInfo> result = new List<ArticleInfo>();
            if(String.isNotBlank(Keyword) && Keyword.trim().length() > 1)
            {
                List<List<sObject>> searches = [find :Keyword returning KB__kav (Id, KnowledgeArticleId, ArticleNumber, Title, Summary, LastPublishedDate where PublishStatus='Online' and Language='en_US' and IsLatestVersion=true limit 15)];
                List<KB__kav> kbs = (List<KB__kav>)searches[0];
                List<Id> articleIds = new List<Id>();
                for(KB__kav kb : kbs)
                {
                    articleIds.add(kb.KnowledgeArticleId);
                    result.add(new ArticleInfo(kb.Id, kb.KnowledgeArticleId, kb.ArticleNumber, kb.Title, kb.Summary, kb.LastPublishedDate));
                }
                List<KB__ViewStat> stats = [select ParentId, NormalizedScore from KB__ViewStat where ParentId in :articleIds and Channel='Csp'];
                List<KB__VoteStat> votes = [select ParentId, NormalizedScore from KB__VoteStat where ParentId in :articleIds and Channel='Csp'];
                for(ArticleInfo article : result)
                {
                    for(KB__ViewStat stat : stats)
                    {
                        if(stat.ParentId == article.ArticleId)
                        {
                            article.ViewCount = stat.NormalizedScore;
                            break;
                        }
                    }
                    for(KB__VoteStat vote : votes)
                    {
                        if(vote.ParentId == article.ArticleId)
                        {
                            article.VoteCount = vote.NormalizedScore;
                            break;
                        }
                    }
                }
            }
            return result;
        }
    }
    
    public PageReference searchArticle()
    {
        RenderPage = 1;
        SearchCompleted = true;
        return null;
    }
    
    public PageReference viewArticle()
    {
        RenderPage = 2;
        return null;
    }

    public PageReference openCaseAnyway() 
    {
        RenderPage = 3;
        return null;
    }
    
    public PageReference markArticle()
    {
        try
        {
            cs.Status = 'Closed';
            cs.Case_Disposition__c = 'KB Self Serve';
            cs.Close_Code__c = cs.Case_Disposition__c;
            updateCase();
            Database.upsert(cs, true);
            insert new CaseArticle(KnowledgeArticleId=ArticleId, CaseId=cs.Id);
        }
        catch(Exception ex)
        {
            Apexpages.addMessages(ex);
        }
        return new PageReference('/home/home.jsp');
    }
    
    public PageReference saveCase()
    {
        try
        {
            cs.Status = 'Unassigned';
            updateCase();
            Database.DMLOptions options = new Database.DMLOptions();
            options.assignmentRuleHeader.useDefaultRule= true;
            Database.insert(cs, options);
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return new PageReference('/' + cs.Id);
    }
    
    private void updateCase()
    {
        User currentUser = [select Id, ContactId, Contact.AccountId from User where Id = :UserInfo.getUserId() limit 1];
        if(currentUser.ContactId != null)
        {
            cs.ContactId = currentUser.ContactId;
            cs.AccountId = currentUser.Contact.AccountId;
            cs.RecordTypeId = TechnicalSupportRecordTypeId;
        }
    }
    
    public class ArticleInfo 
    {
        public ArticleInfo(String aid, String kaid, String ano, String title, String summary, DateTime publishDate)
        {
            this.ArticleId = aid;
            this.KnowledgeArticleId = kaid;
            this.ArticleNumber = ano;
            this.Title = title;
            this.Summary = summary;
            this.PublishDate = publishDate;
            this.ViewCount = 0;
            this.VoteCount = 0;
        }
        
        public String ArticleId { get; set; }
        public String KnowledgeArticleId { get; set; }
        public String Title { get; set; }
        public String Summary { get; set; }
        public String ArticleNumber { get; set; }
        public DateTime PublishDate { get; set; }
        public Decimal ViewCount { get; set; }
        public Decimal VoteCount { get; set; }
    }
}