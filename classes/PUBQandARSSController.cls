public class PUBQandARSSController {
public List<PUBQuestion> questions { get; private set; }
        
    public PUBQandARSSController() {
        this.questions = new List <PUBQuestion>();
        
        List <Account> questionlist = [SELECT Id, Name FROM Account ORDER BY CreatedDate DESC LIMIT 50];

        for (Account singleQuestion : questionlist) {
            questions.add(new PUBQuestion(singleQuestion.Name, 'singleQuestion.Body', 'singleQuestion.CreatorName', 'https://powerofus.force.com/_ui/chatter/service/ChatterAnswersUi#!/feedtype=SINGLE_QUESTION_DETAIL&id=' + singleQuestion.Id));
        }
    }

    public class PUBQuestion {
        public String title { get; private set; }
        public String description { get; private set; }
        public String creator { get; private set; }
        public String link { get; private set; }
           
        public PUBQuestion(String title, String description, String creator, String link) {
            this.title = title != null ? title.escapeXml() : null;
            this.description = description != null ? description.escapeXml() : null;
            this.creator = creator != null ? creator.escapeXml(): null;
            this.link = link != null ? link.escapeXml(): null;
        }
    }

   
}