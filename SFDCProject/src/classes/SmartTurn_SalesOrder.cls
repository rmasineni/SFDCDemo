//Generated by wsdl2apex

public class SmartTurn_SalesOrder {
    public class saveSalesOrderResponse_element {
        public SmartTurn_OccamTypes.UploadResponse[] uploadResponse;
        private String[] uploadResponse_type_info = new String[]{'uploadResponse','http://www.smartturn.com/services/occamtypes','UploadResponse','1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'uploadResponse'};
    }
/*    public class cancelSalesOrder_element {
        public SmartTurn_OccamTypes.OccamPasswordCredential inCredential;
        public String externalNumber;
        public String number_x;
        private String[] inCredential_type_info = new String[]{'inCredential','http://www.smartturn.com/services/occamtypes','OccamPasswordCredential','1','1','false'};
        private String[] externalNumber_type_info = new String[]{'externalNumber','http://www.smartturn.com/services/data-types','IdType','0','1','false'};
        private String[] number_x_type_info = new String[]{'number','http://www.smartturn.com/services/data-types','IdType','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'inCredential','externalNumber','number_x'};
    }
    public class cancelSalesOrderResponse_element {
        public SmartTurn_OccamTypes.UploadResponse uploadResponse;
        private String[] uploadResponse_type_info = new String[]{'uploadResponse','http://www.smartturn.com/services/occamtypes','UploadResponse','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'uploadResponse'};
    } */
/*    public class lookUpSalesOrder_element {
        public SmartTurn_OccamTypes.OccamPasswordCredential inCredential;
        public SmartTurn_OccamTypes.Criteria inCriteria;
        private String[] inCredential_type_info = new String[]{'inCredential','http://www.smartturn.com/services/occamtypes','OccamPasswordCredential','1','1','false'};
        private String[] inCriteria_type_info = new String[]{'inCriteria','http://www.smartturn.com/services/occamtypes','Criteria','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'inCredential','inCriteria'};
    }
    public class lookUpSalesOrderResponse_element {
        public SmartTurn_LookupTypes.WSSalesOrderLookupResult result;
        private String[] result_type_info = new String[]{'result','http://www.smartturn.com/services/lookup-types','WSSalesOrderLookupResult','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    } */
    public class saveSalesOrder_element {
        public SmartTurn_OccamTypes.OccamPasswordCredential inCredential;
        public SmartTurn_SalesOrderTypes.SalesOrder[] inSalesOrders;
        private String[] inCredential_type_info = new String[]{'inCredential','http://www.smartturn.com/services/occamtypes','OccamPasswordCredential','1','1','false'};
        private String[] inSalesOrders_type_info = new String[]{'inSalesOrders','http://www.smartturn.com/services/sales-order-types','SalesOrder','1','100','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'inCredential','inSalesOrders'};
    }
    public class overwriteSalesOrder_element {
        public SmartTurn_OccamTypes.OccamPasswordCredential inCredential;
        public SmartTurn_SalesOrderTypes.SalesOrder[] inSalesOrders;
        private String[] inCredential_type_info = new String[]{'inCredential','http://www.smartturn.com/services/occamtypes','OccamPasswordCredential','1','1','false'};
        private String[] inSalesOrders_type_info = new String[]{'inSalesOrders','http://www.smartturn.com/services/sales-order-types','SalesOrder','1','100','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'inCredential','inSalesOrders'};
    }

    public class overwriteSalesOrderResponse_element {
        public SmartTurn_OccamTypes.UploadResponse[] uploadResponse;
        private String[] uploadResponse_type_info = new String[]{'uploadResponse','http://www.smartturn.com/services/occamtypes','UploadResponse','1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'uploadResponse'};
    }
 
//the following workaround to return overwriteSalesOrderReturn is commented on 3/27...since SmartTurn started to send the uploadResponse element
/*   
    public class overwriteSalesOrderResponse_element {
        public SmartTurn_OccamTypes.UploadResponse[] overwriteSalesOrderReturn;
        private String[] overwriteSalesOrderReturn_type_info = new String[]{'overwriteSalesOrderReturn','http://www.smartturn.com/services/occamtypes','UploadResponse','1','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://www.smartturn.com/services/OccamService/sales-order','true','false'};
        private String[] field_order_type_info = new String[]{'overwriteSalesOrderReturn'};
    }
*/
}