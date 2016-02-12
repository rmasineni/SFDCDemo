public class HomeDepotErrorLookupDto{

 public Map<String, String> ErrorDTOMap{get;set;}
 public Map<String, String> ErrorLookUpDTOMap{get;set;}
 public string code{get;set;}
 public string message{get;set;}
 public string childObject{get;set;}
 public string IntgrStatus{get;set;}
 public string IntgrDesc{get;set;}
 
 
 public HomeDepotErrorLookupDto(){
  ErrorDTOMap = new Map<String,String>();
 
 }
 
 public HomeDepotErrorLookupDto(JSONReader readerObj){
     initializeResponse(readerObj);
 }

 public void initializeResponse(JSONReader readerObj){
  
  if(readerObj != null){
     code = readerObj.getString('SFISPERRORLOGWS_Output.Code');
     message = readerObj.getString('SFISPERRORLOGWS_Output.Message');
     string test='';
     String PONum='';
     String ErrStatus='';
     String ErrDescription='';
     String ErrMessage='';
     ErrorLookUpDTOMap = new Map<String, String>();
     test = readerObj.getString('SFISPERRORLOGWS_Output.Errormessage');
   
     system.debug('-->test'+test);
   
                
    if(code == '200' && message == 'Success'){
         
      Dom.Document Doc = new Dom.Document();
      Doc.load(test);
     
      Dom.XMLNode ermsg = Doc.getRootElement();
      system.debug('-->ermsg'+ermsg);
     
    
      Dom.XMLNode [] children = ermsg.getChildElements();
      system.debug('-->children'+children);  
        for(Dom.XMLNode child : children){
          Dom.XMLNode [] child1 = child.getChildren();
          system.debug('-->child1'+child1);
         
           for(DOM.XMLNode child2 : child1){
            system.debug('-->IntgrStatus'+IntgrStatus);
            for(dom.xmlnode child3:child2.getchildren()){
             system.debug('Printing success'+child3.getname());
             if(child3.getname() == 'MMSVCSServiceProviderOrderNumber'){
               PONum = child3.gettext();
               system.debug('--->child3'+child3.gettext());
             }
             system.debug('-->Provider Num'+PONum);
             if(child3.getname() == 'MMSVIntegrationStatus'){
               ErrStatus = child3.getText();
               system.debug('--->child3IntStat'+ErrStatus);
             }
             if(child3.getname() == 'MMSVIntegrationDescription'){
               ErrDescription = child3.getText();
             }
             ErrMessage = 'Error Status : '+ErrStatus +'\n'+ 'Error Description : '+ErrDescription; 
             if(PONum!=null&&ErrMessage!=null&&PONum!=''&&ErrMessage!=''){
               ErrorLookUpDTOMap .put(PONum,ErrMessage);
               system.debug('--->map'+ErrorLookUpDTOMap);
             }  
            }
            
           }
         } 
         
      }
   }
 
 }
 
}