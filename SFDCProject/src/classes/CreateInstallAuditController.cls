public class CreateInstallAuditController {
    
    public Generation_Assets__c ga{get;set;}
    public InstallAuditService installAuditService = new InstallAuditService();    
    
    public CreateInstallAuditController(ApexPages.StandardController sc){
        this.ga = (Generation_Assets__c)sc.getRecord();
    }

    public PageReference create(){

        Install_Audit__c ia = new Install_Audit__c(Generation_Asset__c=ga.Id);
        insert ia;
        //AuditFeedback
        List<Audit_Feedback__c> listAF = new List<Audit_Feedback__c>();
        Audit_Feedback__c feedback;
        RecordType rtSimple =  [select Id from RecordType where sObjectType = 'Audit_Feedback__c' and name = 'Simple' limit 1];
        RecordType rtComplex = [select Id from RecordType where sObjectType = 'Audit_Feedback__c' and name = 'Complex' limit 1];        
        for(Audit_Criteria__c ac:installAuditService.getActiveAuditCriteria())
        {
            if(ac.Criteria_QA_Score_Type__c == 'Complex')
                listAf.add(new Audit_Feedback__c(Audit_Criteria__c = ac.Id, Install_Audit__c = ia.Id, RecordTypeId = rtComplex.Id, 
                           Point_Value__c = ac.Point_Value__c));
            else
                listAf.add(new Audit_Feedback__c(Audit_Criteria__c = ac.Id, Install_Audit__c = ia.Id, RecordTypeId = rtSimple.Id, 
                           Point_Value__c = ac.Point_Value__c));

        }
        if(!listAF.isEmpty())
        {
            insert listAF;
        }     
        //Site Char
        List<Site_Characteristic__c> listSC = new List<Site_Characteristic__c>();
        List<ArrayInformation> arrays = getArrayInformation();
        for(ArrayInformation arrayInformation: arrays)
        {
            listSC.add(new Site_Characteristic__c(Install_Audit__c = ia.Id, Panel_Manufacturer__c = arrayInformation.PanelManufacturer, Panel_Count__c = arrayInformation.PanelCount,
                                                  Inverter_Manufacturer__c = arrayInformation.InverterManufacturer, Inverter_Count__c = arrayInformation.InverterCount,
                                                  EPC_Tilt__c = arrayInformation.EPCTilt, EPC_Azimuth__c = arrayInformation.EPCAzimuth,
                                                  EPC_Average_Annual_Shading__c = arrayInformation.EPCAnnualShading, Proposal_Name__c = arrayInformation.ProposalName));
        }
        if(!listSC.isEmpty())
        {
            insert listSC;
        }
        //
        PageReference pr = new PageReference('/apex/InstallAudit?id=' + ia.Id);
        pr.SetRedirect(true);
        return pr;
    }
    
    private List<ArrayInformation> getArrayInformation(){
            
        String propId;
        Integer iCount = 0;
        List<ArrayInformation> arrays = new List<ArrayInformation>();
        
        for(Generation_Assets__c ga:[select id, Proposal_Unique_ID__c from Generation_Assets__c where id = :ga.Id])
        {
            propId = ga.Proposal_Unique_ID__c;
        }
        
        List<Proposal__c> proposalSiteCharacteristics = installAuditService.getProposalSiteCharacteristics(propId);
        for(Proposal__c p:proposalSiteCharacteristics)
        {
            if(p.Array_1_Panel_Type__c != '' && p.Array_1_Panel_Type__c != null && p.Array_1_No_of_Panels__c != null && p.Array_1_No_of_Panels__c > 0)
            {
               arrays.add(new ArrayInformation(p.Array_1_Panel_Type__c, p.Array_1_Inverter_Type__c, p.Array_1_No_of_Panels__c, p.Array_1_No_of_Inverters__c,
                                               p.Array_1_Pitch__c, p.Array_1_Azimuth__c, p.Array_1_January_Shade__c, p.Array_1_February_Shade__c, p.Array_1_March_Shade__c, 
                                               p.Array_1_April_Shade__c, p.Array_1_May_Shade__c, p.Array_1_June_Shade__c, p.Array_1_July_Shade__c,
                                               p.Array_1_August_Shade__c, p.Array_1_September_Shade__c, p.Array_1_October_Shade__c, p.Array_1_November_Shade__c, 
                                               p.Array_1_December_Shade__c, p.Name));
            }
            if(p.Array_2_Panel_Type__c != '' && p.Array_2_Panel_Type__c != null && p.Array_2_No_of_Panels__c != null && p.Array_2_No_of_Panels__c > 0)
            {
               arrays.add(new ArrayInformation(p.Array_2_Panel_Type__c, p.Array_2_Inverter_Type__c, p.Array_2_No_of_Panels__c, p.Array_2_No_of_Inverters__c,
                                               p.Array_2_Pitch__c, p.Array_2_Azimuth__c, p.Array_2_January_Shade__c, p.Array_2_February_Shade__c, p.Array_2_March_Shade__c, 
                                               p.Array_2_April_Shade__c, p.Array_2_May_Shade__c, p.Array_2_June_Shade__c, p.Array_2_July_Shade__c,
                                               p.Array_2_August_Shade__c, p.Array_2_September_Shade__c, p.Array_2_October_Shade__c, p.Array_2_November_Shade__c, 
                                               p.Array_2_December_Shade__c, p.Name));

            }
            if(p.Array_3_Panel_Type__c != '' && p.Array_3_Panel_Type__c != null && p.Array_3_No_of_Panels__c != null && p.Array_3_No_of_Panels__c > 0)
            {
               arrays.add(new ArrayInformation(p.Array_3_Panel_Type__c, p.Array_3_Inverter_Type__c, p.Array_3_No_of_Panels__c, p.Array_3_No_of_Inverters__c,
                                               p.Array_3_Pitch__c, p.Array_3_Azimuth__c, p.Array_3_January_Shade__c, p.Array_3_February_Shade__c, p.Array_3_March_Shade__c, 
                                               p.Array_3_April_Shade__c, p.Array_3_May_Shade__c, p.Array_3_June_Shade__c, p.Array_3_July_Shade__c,
                                               p.Array_3_August_Shade__c, p.Array_3_September_Shade__c, p.Array_3_October_Shade__c, p.Array_3_November_Shade__c, 
                                               p.Array_3_December_Shade__c, p.Name));
            }
            if(p.Array_4_Panel_Type__c != '' && p.Array_4_Panel_Type__c != null && p.Array_4_No_of_Panels__c != null && p.Array_4_No_of_Panels__c > 0)
            {
               arrays.add(new ArrayInformation(p.Array_4_Panel_Type__c, p.Array_4_Inverter_Type__c, p.Array_4_No_of_Panels__c, p.Array_4_No_of_Inverters__c,
                                               p.Array_4_Pitch__c, p.Array_4_Azimuth__c, p.Array_4_January_Shade__c, p.Array_4_February_Shade__c, p.Array_4_March_Shade__c, 
                                               p.Array_4_April_Shade__c, p.Array_4_May_Shade__c, p.Array_4_June_Shade__c, p.Array_4_July_Shade__c,
                                               p.Array_4_August_Shade__c, p.Array_4_September_Shade__c, p.Array_4_October_Shade__c, p.Array_4_November_Shade__c, 
                                               p.Array_4_December_Shade__c, p.Name));
            }
            if(p.Array_5_Panel_Type__c != '' && p.Array_5_Panel_Type__c != null && p.Array_5_No_of_Panels__c != null && p.Array_5_No_of_Panels__c > 0)
            {
               arrays.add(new ArrayInformation(p.Array_5_Panel_Type__c, p.Array_5_Inverter_Type__c, p.Array_5_No_of_Panels__c, p.Array_5_No_of_Inverters__c,
                                               p.Array_5_Pitch__c, p.Array_5_Azimuth__c, p.Array_5_January_Shade__c, p.Array_5_February_Shade__c, p.Array_5_March_Shade__c, 
                                               p.Array_5_April_Shade__c, p.Array_5_May_Shade__c, p.Array_5_June_Shade__c, p.Array_5_July_Shade__c,
                                               p.Array_5_August_Shade__c, p.Array_5_September_Shade__c, p.Array_5_October_Shade__c, p.Array_5_November_Shade__c, 
                                               p.Array_5_December_Shade__c, p.Name));
            }
            if(p.Array_6_Panel_Type__c != '' && p.Array_6_Panel_Type__c != null && p.Array_6_No_of_Panels__c != null && p.Array_6_No_of_Panels__c > 0)
            {
               arrays.add(new ArrayInformation(p.Array_6_Panel_Type__c, p.Array_6_Inverter_Type__c, p.Array_6_No_of_Panels__c, p.Array_6_No_of_Inverters__c,
                                               p.Array_6_Pitch__c, p.Array_6_Azimuth__c, p.Array_6_January_Shade__c, p.Array_6_February_Shade__c, p.Array_6_March_Shade__c, 
                                               p.Array_6_April_Shade__c, p.Array_6_May_Shade__c, p.Array_6_June_Shade__c, p.Array_6_July_Shade__c,
                                               p.Array_6_August_Shade__c, p.Array_6_September_Shade__c, p.Array_6_October_Shade__c, p.Array_6_November_Shade__c, 
                                               p.Array_6_December_Shade__c, p.Name));
            }                                                           
        }
        return arrays;              
    }
    
    public class ArrayInformation
    {
        public String PanelManufacturer {get;set;}
        public String InverterManufacturer {get;set;}
        public Decimal PanelCount {get;set;}
        public Decimal InverterCount {get;set;}
        public Decimal EPCTilt {get;set;}
        public Decimal EPCAzimuth {get;set;}
        public Decimal EPCAnnualShading {get;set;}
        public String ProposalName {get;set;}
        
        public ArrayInformation(String panelManufacturer, String inverterManufacturer, Decimal panelCount, Decimal inverterCount, String epcTilt, 
                                Decimal epcAzimuth, Decimal JanShade, Decimal FebShade, Decimal MarShade, Decimal AprShade, Decimal MayShade, 
                                Decimal JunShade, Decimal JulShade, Decimal AugShade, Decimal SepShade, Decimal OctShade, Decimal NovShade, 
                                Decimal DecShade, String proposalName )
        {
            this.ProposalName = proposalName;
            this.PanelManufacturer = panelManufacturer;
            this.InverterManufacturer = inverterManufacturer;
            this.PanelCount = panelCount;
            this.InverterCount = inverterCount;
            if(epcTilt != null)
                this.EPCTilt = Decimal.valueOf(epcTilt);
            this.EPCAzimuth = epcAzimuth;
            this.EPCAnnualShading = calculateAverageShade(JanShade, FebShade, MarShade, AprShade, MayShade, JunShade, JulShade, AugShade, SepShade,
                                                            OctShade, NovShade, DecShade);
                    
        }
                
        private Decimal calculateAverageShade(Decimal s1, Decimal s2, Decimal s3, Decimal s4, Decimal s5, Decimal s6, Decimal s7, Decimal s8, Decimal s9, Decimal s10, Decimal s11, Decimal s12)
        {
            Decimal totalShade = 0;
            Decimal averageShade = 0;
            if(s1 == null)
                s1 = 0;
            if(s2 == null)
                s2 = 0;
            if(s3 == null)
                s3 = 0;
            if(s4 == null)
                s4 = 0;
            if(s5 == null)
                s5 = 0;
            if(s6 == null)
                s6 = 0;
            if(s7 == null)
                s7 = 0;
            if(s8 == null)
                s8 = 0;
            if(s9 == null)
                s9 = 0;
            if(s10 == null)
                s10 = 0;
            if(s11 == null)
                s11 = 0;
            if(s12 == null)
                s12 = 0;
            totalShade = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10 + s11 + s12; 
            averageShade = totalShade/12;                     
            return averageShade.SetScale(0);
        }        
    }

}