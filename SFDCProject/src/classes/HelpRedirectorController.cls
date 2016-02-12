public class HelpRedirectorController extends BaseClass {
	
    public PageReference redirect() {
        Id articleId = new HelpServiceImpl().findArtileId(null, getParameter('section'), getParameter('target'));
        if (articleId == null) {
            return null;
        }
        
        return redirect('/apex/HelpViewer?id=' + articleId);
	}
}