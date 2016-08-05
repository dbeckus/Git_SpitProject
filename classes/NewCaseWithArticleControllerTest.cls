@isTest
public class NewCaseWithArticleControllerTest
{
    @isTest
    static void test()
    {
        NewCaseWithArticleController controller = new NewCaseWithArticleController(new ApexPages.StandardController(new Case()));
        controller.Keyword = 'test';
        controller.searchArticle();
        controller.viewArticle();
        controller.openCaseAnyway();
        controller.saveCase();
        controller.markArticle();
        KB__kav  Article = controller.Article;
        List<NewCaseWithArticleController.ArticleInfo> articles = controller.SearchResult;
        NewCaseWithArticleController.ArticleInfo a = new NewCaseWithArticleController.ArticleInfo('a', 'b', 'c', 'd', 'e', null);
    }
}