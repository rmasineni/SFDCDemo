public class GuidedSalesController extends BaseClass {
    public Id questionId {get;set;}
    public String answer {get;set;}
    public Id sobjId {get;set;}
    public Guided_Sales_Question__c question {get;set;}
    public Guided_Sales_Response_Group__c responseGroup {get;set;}
    
    public GuidedSalesController(ApexPages.StandardController controller) {
        sobjId = controller.getRecord().id;
    }
    
    public PageReference submitPage() {
        try  {
            if (responseGroup == null) {
                responseGroup = new Guided_Sales_Response_Group__c(Lead__c=sobjId);
                insert responseGroup;
            }
            
            Guided_Sales_Question__c qes = queryQuestion(questionId);
            Guided_Sales_Response__c userResp = new Guided_Sales_Response__c(Response_Group__c=responseGroup.id, Question__c=questionId, Question_Text__c=getQuestionText(qes));
            userResp.Answer_Text__c = answer;
            userResp.Answer__c = getAnswerObj(qes, answer).id;
            insert userResp;
        } catch (Exception e) {
            addErrorMessage(e);
        }            
		
        return null;
    }
    
	public Component.Apex.OutputPanel getNextPage() {
        try {
            // This is the component to return
            Component.Apex.OutputPanel dynOutPanel= new Component.Apex.OutputPanel(styleClass='ds-page');
            dynOutPanel.layout = 'block';
            
            // Child component to hold the message text
            Guided_Sales_Question__c qes = questionId != null?getNextQuestion(questionId, answer):getFirstQuestion();
            System.debug('Next question need to be shown is ' + qes);
            
            answer = null;
            if (qes == null) {
                questionId = null;
                question = null;
                dynOutPanel.childComponents.add(createOutputText('Thank you for your answers.'));
            } else {
                questionId = qes.id;
                question = qes;
                dynOutPanel.childComponents.add(createPageBlock(createRadioQuestion(qes), 'submitPage'));
            }
            
            return dynOutPanel;
        } catch (Exception e) {
            addErrorMessage(e);
        }
        
        return null;
    }
 	
    public Component.Apex.OutputText createOutputText(String text) {
        return new Component.Apex.OutputText(value=text, styleClass='gs-output-text');
    }
    
    public Guided_Sales_Question__c getNextQuestion(String questionId, String answer) {
        System.debug('Getting next question for ' + questionId + ' answer ' + answer);
        
        Guided_Sales_Question__c qes = queryQuestion(questionId);
        
        for (Guided_Sales_Answer__c ans : qes.Answers__r) {
            if (getAnswerText(ans) == answer) {
                if (ans.Next_Question__c != null) {
	                return queryQuestion(ans.Next_Question__c);
                }
            }
       	}
        
        return null;
    }

    public Guided_Sales_Question__c getFirstQuestion() {
       	return queryQuestion('a8x550000004CBs');
    }

    public Component.Apex.PageBlock createPageBlock(Component.Apex.OutputPanel content, String buttonExpression) {
        Component.Apex.PageBlock pageBlock = new Component.Apex.PageBlock(mode='Edit');
        Component.Apex.PageBlockSection pageBlockSection = new Component.Apex.PageBlockSection();
        pageBlockSection.childComponents.add(content);
        pageBlock.childComponents.add(pageBlockSection);
        
        if (buttonExpression != null) {
            Component.Apex.PageBlockButtons buttons = new Component.Apex.PageBlockButtons(location='bottom');
            Component.Apex.CommandButton button = new Component.Apex.CommandButton(Value='Submit');
            button.expressions.action = '{!' + buttonExpression +  '}';
            buttons.childComponents.add(button);
            pageBlock.childComponents.add(buttons);
        }
        
        return pageBlock;
    }
    
    public Component.Apex.OutputPanel createRadioQuestion(Guided_Sales_Question__c qes) {
        Component.Apex.SelectRadio radio = new Component.Apex.SelectRadio(label=getQuestionText(qes));
        radio.expressions.value = '{!answer}';
        radio.layout = 'pageDirection';
        
        for (Guided_Sales_Answer__c ans : qes.Answers__r) {
	        radio.childComponents.add(new Component.Apex.selectOption(itemLabel=getAnswerText(ans), itemValue=getAnswerText(ans)));
       	}
        
        Component.Apex.OutputPanel dynOutPanel = new Component.Apex.OutputPanel(layout = 'block');
		dynOutPanel.childComponents.add(new Component.Apex.OutputLabel(Value=getQuestionText(qes)));
        dynOutPanel.childComponents.add(radio);
        return dynOutPanel;
    }

    public Guided_Sales_Question__c queryQuestion(Id qesId) {
        return [
            select
            	id, Name, Question_Text__c, (select id, Name, Answer_Text__c, Next_Question__c from Answers__r order by Order__c, CreatedDate)
            from Guided_Sales_Question__c
            where id = :qesId
        ];
    }
 	
    public String getQuestionText(Guided_Sales_Question__c qes) {
        return qes.Question_Text__c == null?qes.Name:qes.Question_Text__c;
    }
    
    public String getAnswerText(Guided_Sales_Answer__c answer) {
        return answer.Answer_Text__c == null?answer.Name:answer.Answer_Text__c;
    }

    public Guided_Sales_Answer__c getAnswerObj(Guided_Sales_Question__c qes, String answer) {
        for (Guided_Sales_Answer__c ans : qes.Answers__r) {
            if (answer == getAnswerText(ans)) {
                return ans;
            }
        }
        
        return null;
    }
    
    public String getDynamicContent() {
        if (question != null) {
	        return 'Dynamic content for question for ' + question.name;
        }
        
        return '';
    }
}