global class CDYNEStandardButtonCall {
 webservice static string callCDYNE(Id leadid)
    { 
                String statusMessage;
                system.debug('leadid : ' +leadid);
                Lead l=[select id,square_footage__c,Field_Marketing_Branch__c,county__c,Home_Type__c,Sales_Rep_Division__c,territory__c,Channel__c,Zip_6__c,custom_Lead_source__c,Jan_Usage__c,Feb_Usage__c,Mar_Usage__c,Apr_Usage__c,May_Usage__c,Jun_Usage__c,Jul_Usage__c,Aug_Usage__c,Sep_Usage__c,Oct_Usage__c,Nov_Usage__c,Dec_Usage__c,Average_Monthly_Electric_Bill__c,Calculate_Usage__c,phone,Lead_Qualifier__c,SalesRep__c,Sales_Rep_Email__c,Sales_Partner__c
                        ,Install_Partner__c,Sunrun_South__c,Market_Assignment_Sales__c,Market_Assignment_Install__c,Firstname,street,state,city,CDYNE_Status__c,Utility_Company__c,dt_Annual_Kwh_Usage__c,Email,Usage_Option__c from lead where id=:leadid];             
                if((l.CDYNE_status__c!='Success'||l.Zip_6__c==null)&&l.channel__c=='Partner') {
                        Set<String> leadSet=new Set<String>();
                        leadSet.add(leadid);
                        CDYNEService cdyne=new CDYNEService();
                        cdyne.processZipPlusSixForLeadsImmediate(leadSet); 
                } 
                if(l.Sunrun_South__c){
                    return 'Sunrun South Leads cannot be routed to Design Tool';
                }
                else if(l.Street==null||l.City==null||l.state==null){
                    return 'A valid address is required to create design';
                }                               
                else if(l.Utility_Company__c==null||l.Utility_Company__c==''){
                return 'Utility Company is required to create design';
                }
                else if(l.channel__c!=null&&(l.channel__c=='Retail'||l.channel__c=='Canvassing'||l.channel__c=='Event')&&l.Field_Marketing_Branch__c==null){
                return 'Field Marketing Branch required for the channel selected';
                } 
                else if(l.Jan_Usage__c==0&&l.Feb_Usage__c==0&&l.Mar_Usage__c==0
                &&l.Apr_Usage__c==0&&l.Mar_Usage__c==0&&l.May_Usage__c==0&&l.Jun_Usage__c==0&&l.Jul_Usage__c==0&&l.Aug_Usage__c==0
                &&l.Sep_Usage__c==0&&l.Oct_Usage__c==0&&l.Oct_Usage__c==0&&l.Nov_Usage__c==0&&l.Dec_Usage__c==0){
                return 'All monthly usage cannot be zero';
                }                              
                else if((l.Square_footage__c==null||l.Square_footage__c==0)
                &&((l.dt_Annual_Kwh_Usage__c==null||l.dt_Annual_Kwh_Usage__c==0)||(l.dt_Annual_Kwh_Usage__c>0&&(l.Jan_Usage__c==null||l.Feb_Usage__c==null||l.Mar_Usage__c==null
                ||l.Apr_Usage__c==null||l.Mar_Usage__c==null||l.May_Usage__c==null||l.Jun_Usage__c==null||l.Jul_Usage__c==null||l.Aug_Usage__c==null
                ||l.Sep_Usage__c==null||l.Oct_Usage__c==null||l.Oct_Usage__c==null||l.Nov_Usage__c==null||l.Dec_Usage__c==null)))){
                return 'Monthly Usage or Square Footage is required to create design'; 
                }                                           
                /*
                else if(l.dt_Annual_Kwh_Usage__c<2000||l.dt_Annual_Kwh_Usage__c>45000){
                return 'Annual kWh use should be inbetween 2000kWh and 45,000kWh when transferring to Design';
                }
                */
                else if(l.channel__c==null||l.Custom_Lead_Source__c==null){
                return 'Channel & Lead Source is required to create design';    
                }
                else if(l.FirstName==null||l.FirstName==''){
                return 'First Name is required to create design';
                }
                else if((l.Email==null||l.Email=='')&&(l.Phone==null||l.phone=='')){
                return 'Email or Phone is required to create design';
                }
                else if((l.Utility_Company__c=='Pacific Gas & Electric (PG&E)'||l.Utility_Company__c=='PG&E'||l.Utility_Company__c=='SMUD'||l.Utility_Company__c=='Southern California Edison (SCE)'||l.Utility_Company__c=='San Diego Gas & Electric (SDG&E)'||l.Utility_Company__c=='SCE'||l.Utility_Company__c=='SDG&E')&&(l.Usage_Option__c==null||l.Usage_Option__c==''||l.Usage_Option__c=='NA')){
                return 'Usage Option is required for this Utility to navigate into Design Tool';
                } 
                else if(l.Lead_Qualifier__c==null&&Userinfo.getUserType()!='PowerPartner'&&!(l.channel__c=='Partner')){
                return 'Lead Qualifier is required to create design';   
                }                 
                else if(l.Territory__c==null){
                return 'Territory is required to create design';    
                }
                else if(l.home_type__c==null){
                return 'Home type is required to create design';    
                }                
                /*
                else if(l.Average_Monthly_Electric_Bill__c<50){
                return 'Please enter Monthly Electricity Bill >= $50';  
                } 
                */    
                /*                                      
                else if(l.CDYNE_status__c!='Success'&&!(l.channel__c=='Partner'&&(l.custom_lead_source__c=='Partner: Legacy' || l.custom_lead_source__c=='Partner: Fluent'))){
                ApexClass aclass=[SELECT id,Name FROM ApexClass where name='CDYNEService' limit 1];
                    if(aclass!=null){
                    AsyncApexJob a;
                    try{
                    a=[SELECT ApexClassId,CreatedById,Id,MethodName,Status FROM AsyncApexJob where apexclassid=:aclass.id and createdbyid=:userinfo.getUserId() and status in ('Queued','Preparing','Processing') limit 1];
                    }
                    catch(exception e){
                        system.debug(e);
                    }                   
                        if(a!=null){                             
                        Set<String> leadSet=new Set<String>();
                        leadSet.add(leadid);
                        CDYNEService cdyne=new CDYNEService();
                        cdyne.processZipPlusSixForLeadsImmediate(leadSet);  
                        system.abortJob(a.id);  
                        Lead l1=[select CDYNE_Status__c from lead where id=:leadid];
                        if(l1.CDYNE_Status__c!='Success')                                   
                        return 'A valid address is required to create design';
                        }
                        else{               
                        return 'A valid address is required to create design';
                        }
                    }                
                }
                */
                else if(l.Market_Assignment_Sales__c==null||l.Market_Assignment_Install__c==null){
                ApexClass aclass=[SELECT id,Name FROM ApexClass where name='Lead_Assignment' limit 1];
                if(aclass!=null){
                AsyncApexJob a;
                try{
                a=[SELECT ApexClassId,CreatedById,Id,MethodName,Status FROM AsyncApexJob where apexclassid=:aclass.id and createdbyid=:userinfo.getUserId() and status in ('Queued','Preparing','Processing') limit 1];
                }
                catch(exception e){
                    system.debug(e);
                }
                    if(a!=null){                        
                        Set<Id> leadSet=new Set<Id>();
                        leadSet.add(leadid);
                        checkRecursive.leadsetIds.add(l.id);
                        Lead_Assignment.Lead_Assignment_Immediate(leadSet);
                        system.abortJob(a.id);
                        Lead l1=[select Market_Assignment_Sales__c,Market_Assignment_Install__c from lead where id=:l.id];
                        if(l1.Market_Assignment_Sales__c==null||l1.Market_Assignment_Install__c==null){
                         return 'Sales Partner & Install Partner Adders are required to create design';
                        }                   
                    }
                    else{
                        return 'Sales Partner & Install Partner Adders are required to create design';
                    }
                }                                                           
                }                                                
                else if(l.Sales_Partner__c==null||l.Install_Partner__c==null){
                    return 'Sales Partner & Install Partner are required to create design';
                }
                else if(l.SalesRep__c==null||l.Sales_Rep_Email__c==null){
                    return 'Sales Rep Message';
                }
                else if(Userinfo.getUserType()!='PowerPartner'&&l.SalesRep__c!=null&&l.Sales_Rep_Division__c==null&&!(l.channel__c=='Partner')){
                return 'Sales Rep Division Message';    
                }
                else if((l.county__c==null||l.County__c==''||l.County__c=='NA')&&(l.State.equalsIgnorecase('NY')||l.State.equalsIgnorecase('New York'))){
                return 'County Message';    
                }
                return 'Success';    
    }
    webservice static string callOpportunity(Id opptyId){               
                Opportunity o=[select id,Account.Latitude__c,Account.Longitude__c,Account.BillingState,Account.County__c,Square_footage__c,channel_2__c,Lead_Source_2__c,Home_Type__c,Jan_Usage__c,Feb_Usage__c,Mar_Usage__c,Apr_Usage__c,May_Usage__c,Jun_Usage__c,Jul_Usage__c,Aug_Usage__c,Sep_Usage__c,Oct_Usage__c,Nov_Usage__c,Dec_Usage__c,Average_Monthly_Electric_Bill__c,Number_of_Proposals__c,Sales_Partner__c,Install_Partner__c,Market_Assignment_Sales__c,Market_Assignment_Install__c,Address_Validation_Status__c,SalesRep__c,Annual_kWh_usage__c,Utility_Company__c,Territory__c,Opportunity_Source_Type__c,Usage_Option__c,Purchased_Thru__c,Opportunity_Division_Custom__c,Design_Only__c from opportunity where id=:opptyId];
                OpportunityContactRole ocr;
                Contact con;        
                Partner_Role__c prSales;
                Partner_Role__c prInstall;
                try{
                ocr=[select id , contactId from opportunitycontactrole where opportunityid=:o.id and isprimary=true limit 1];
                con = [select id, Member_ID__c from contact where id = : ocr.ContactId];    
                //pr=[select Sales_Rep_Email__c,Sales_Rep_Phone__c,Sales_Rep_Division__c from Partner_Role__c where opportunity__c=:o.id and role__c='Sales' order by partner_name__c nulls last limit 1];                
                for(Partner_Role__c pr:[select Sales_Rep_Email__c,Sales_Rep_Phone__c,Sales_Rep_Division__c,Partner_Name__c, Role__c
                                          from Partner_Role__c 
                                         where opportunity__c=:o.id 
                                           and role__c in ('Sales', 'Install')
                                           and partner_name__c != null]){
                        if(pr.Role__c == 'Sales'){
                           prSales = pr;
                        }else if(pr.Role__c == 'Install'){
                           prInstall = pr;
                        }
                }
                }
                catch(exception e){
                    system.debug(e);
                }
                /*
                if(o.Address_Validation_Status__c!='Success'){
                    return 'A valid address is required to create design';
                }
                */
                
                if(o.Opportunity_Division_Custom__c != label.AEE_label){
                if(o.Opportunity_Source_Type__c!='BB' && o.Number_of_Proposals__c>0){
                    return 'Opportunities created by Proposal Tool are not eligible for design in BrightPath.';
                }                
                
               /* else if(!o.Design_Only__c && ((o.Square_footage__c==null||o.Square_footage__c==0)
                &&((o.Annual_kWh_usage__c==null||o.Annual_kWh_usage__c==0)||(o.Annual_kWh_usage__c>0&&(o.Jan_Usage__c==null||o.Feb_Usage__c==null||o.Mar_Usage__c==null
                ||o.Apr_Usage__c==null||o.Mar_Usage__c==null||o.May_Usage__c==null||o.Jun_Usage__c==null||o.Jul_Usage__c==null||o.Aug_Usage__c==null
                ||o.Sep_Usage__c==null||o.Oct_Usage__c==null||o.Oct_Usage__c==null||o.Nov_Usage__c==null||o.Dec_Usage__c==null))))){
                return 'Monthly Usage or Square Footage is required to create design'; 
                } 
                
                else if(!o.Design_Only__c && (o.Jan_Usage__c==0&&o.Feb_Usage__c==0&&o.Mar_Usage__c==0
                &&o.Apr_Usage__c==0&&o.Mar_Usage__c==0&&o.May_Usage__c==0&&o.Jun_Usage__c==0&&o.Jul_Usage__c==0&&o.Aug_Usage__c==0
                &&o.Sep_Usage__c==0&&o.Oct_Usage__c==0&&o.Oct_Usage__c==0&&o.Nov_Usage__c==0&&o.Dec_Usage__c==0)){
                return 'All monthly usage cannot be zero';
                } */
                              
                else if(o.channel_2__c==null||o.Lead_Source_2__c==null){
                return 'Channel & Lead Source is required to create design';    
                }
                else if(ocr==null){
                return 'Primary contact is required to create design';  
                }
                
                /*else if(!o.Design_Only__c && (Userinfo.getUserType()!='PowerPartner' && o.Sales_Partner__c==System.label.Sunrun_Inc_Id && (o.Purchased_Thru__c == ' ' || o.Purchased_Thru__c == null))){
                return 'Purchased Thru is required to create design';       
                }
                else if(!o.Design_Only__c && (o.Purchased_Thru__c == 'Costco' && (con.Member_ID__c == null || con.Member_ID__c == ''))){
                return 'Costco Member Id is required on primary contact';
                }*/
                /*
                else if(o.Annual_kWh_usage__c==null||o.Annual_kWh_usage__c==0){
                    return 'Annual kWh use is required to continue to system design';
                }
                */
                /*
                else if(o.Opportunity_Source_Type__c!='BB' && o.Number_of_Proposals__c>0){
                    return 'Opportunities created by Proposal Tool are not eligible for design in BrightPath.';
                }*/                
                else if(o.Utility_Company__c==null||o.Utility_Company__c==''){
                     return 'Utility Company is required to continue to system design';
                }
                else if((o.Utility_Company__c=='Pacific Gas & Electric (PG&E)'||o.Utility_Company__c=='PG&E'||o.Utility_Company__c=='SDG&E'||o.Utility_Company__c=='SCE'||o.Utility_Company__c=='SMUD'||o.Utility_Company__c=='Southern California Edison (SCE)'||o.Utility_Company__c=='San Diego Gas & Electric (SDG&E)')&&(o.Usage_Option__c==null||o.Usage_Option__c==''||o.Usage_Option__c=='NA')){
                return 'Usage Option is required for this Utility to navigate into Design Tool';
                }
                else if(o.territory__c==null){
                return 'Territory is required to navigate into Design Tool';
                }
                else if(o.home_type__c==null){
                return 'Home type is required to create design';    
                }            
                else if((o.Account.Latitude__c==null||o.Account.Longitude__c==null)||(o.Account.Latitude__c==0.000000000000000&&o.Account.Longitude__c==0.000000000000000)){
                    return 'This opportunity does not have a lat/long. Please move the pin on the google map to ensure a lat/long is created.';
                }                
                /*
                else if(o.Average_Monthly_Electric_Bill__c<50){
                return 'Please enter Monthly Electricity Bill >= $50';  
                }
                */
                else if(o.Market_Assignment_Sales__c==null||o.Market_Assignment_Install__c==null){
                    return 'Sales Partner & Install Partner Adders are required to create design';
                }
                else if(o.Purchased_Thru__c == 'Costco' && prSales.Partner_Name__c != System.label.sunrun_inc_Id){
                    return 'Sales Partner should be Sunrun for Costco deal'; 
                }                       
                else if(o.Purchased_Thru__c == 'Costco' && prInstall.Partner_Name__c != System.label.sunrun_inc_Id){
                    return 'Install Partner should be Sunrun for Costco deal'; 
                }                                     
                else if(o.Sales_Partner__c==null||o.Install_Partner__c==null){
                    return 'Sales Partner & Install Partner are required to create design';
                }  
                /*else if(!o.Design_Only__c && (prSales==null||(prSales!=null&&(prSales.Sales_Rep_Email__c==null&&prSales.Sales_Rep_Phone__c==null)))){
                    return 'Sales Rep Message';
                }
                else if(!o.Design_Only__c && (Userinfo.getUserType()!='PowerPartner'&&prSales!=null&&prSales.Sales_Rep_Division__c==null&&!(o.channel_2__c=='Partner'))){
                    return 'Sales Rep Division Message';
                }  */                               
                else if((o.Account.County__c==null||o.Account.County__c==''||o.Account.County__c=='NA')&&(o.account.billingstate!=null&&(o.account.billingstate.equalsIgnoreCase('NY')||o.account.billingstate.equalsIgnoreCase('New York')))){
                    return 'County Message';
                }
                
                //BSKY-7265
                else if(o.Design_Only__c){
                    System.debug('Design_Only__c = true');
                    return 'Design Only Message'; 
                } 
                }
                return 'Success';
    }
}