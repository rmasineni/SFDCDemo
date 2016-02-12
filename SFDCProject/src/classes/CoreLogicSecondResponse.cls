public class CoreLogicSecondResponse {
     
        public cls_pageInfo pageInfo;
        public cls_parcels[] parcels;
 
    public class cls_pageInfo {
        public Integer actualPageSize;  
        public Integer length;  
        public Integer maxPageSize; 
        public Integer page;    
        public Integer pageSize;    
    }
    public class cls_parcels {
        public String STATE_CODE;   
        public String CNTY_CODE;    
        public String APN;  
        public String APN2; 
        public String ADDR; 
        public String CITY; 
        public String STATE;    
        public String ZIP;  
        public String STD_ADDR; 
        public String STD_CITY; 
        public String STD_STATE;    
        public String STD_ZIP;  
        public String STD_PLUS; 
        public String GEOM; 
        public String FIPS_CODE;    
        public String UNFRM_APN;    
        public Integer APN_SEQ_NO;  
        public String FRM_APN;  
        public String ORIG_APN; 
        public String ACCT_NO;  
        public String MAP_REF1; 
        public String MAP_REF2; 
        public String CENSUS_TR;    
        public String LOT_NBR;  
        public String LAND_USE; 
        public String PROP_IND; 
        public String SUB_NAME; 
        public String OWN_CP_IND;   
        public String OWN1_LAST;    
        public String OWN1_FRST;
        public String OWN2_LAST;    
        public String OWN2_FRST;
        public String MAIL_NBR; 
        public String MAIL_STR; 
        public String MAIL_MODE;    
        public String MAIL_CITY;    
        public String MAIL_STATE;   
        public String MAIL_ZIP; 
        public String MAIL_CC;  
        public Integer TOT_VAL; 
        public Integer LAN_VAL; 
        public Integer IMP_VAL; 
        public String TOT_VAL_CD;   
        public String LAN_VAL_CD;   
        public Integer ASSD_VAL;    
        public Integer ASSD_LAN;    
        public Integer ASSD_IMP;    
        public Integer MKT_VAL; 
        public Integer MKT_LAN; 
        public Integer MKT_IMP; 
        public Integer APPR_VAL;    
        public Integer APPR_LAN;    
        public Integer APPR_IMP;    
        public Double TAX_AMT;  
        public Integer TAX_YR;  
        public Integer ASSD_YR; 
        public String TAX_AREA; 
        public String DOC_NBR;  
        public Double LAND_ACRES;   
        public Integer LAND_SQ_FT;  
        public String LOT_AREA; 
        public Integer UBLD_SQ_FT;  
        public String BLD_SQ_IND;   
        public Integer BLD_SQ_FT;   
        public Integer LIV_SQ_FT;   
        public Integer GF_SQ_FT;    
        public Integer GR_SQ_FT;    
        public Integer YR_BLT;  
        public Integer EFF_YR_BLT; 
        public Integer BEDROOMS; 
        public Integer ROOMS;
        public Integer BATHS_CAL; 
        public Double BATHS; 
        public String GARAGE; 
        public Integer PKG_SPACES; 
        public String PKG_TYP; 
        public String QUALITY;
        public String BLD_CODE; 
        public String CONSTR_TYP;   
        public String FOUNDATION;   
        public String ROOF_COVER;   
        public String ROOF_TYP; 
        public String STORY_CD; 
        public Double STORY_NBR;
        public Integer BLD_UNITS;   
        public Integer UNITS_NBR;   
        public String LEGAL1;   
    }
  

}