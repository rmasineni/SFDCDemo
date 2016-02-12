<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASE_Cancellation_Notification_Service_Contract</fullName>
        <ccEmails>dora.weeks@americanpv.com</ccEmails>
        <description>ASE - Cancellation Notification (Service Contract)</description>
        <protected>false</protected>
        <recipients>
            <recipient>kara@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Agreement_Cancellation_American_Electric_Service_Contract</fullName>
        <ccEmails>mamory@american-electric.cc</ccEmails>
        <ccEmails>clandford@american-electric.cc</ccEmails>
        <ccEmails>sahwah@american-electric.cc</ccEmails>
        <description>Agreement Cancellation - American Electric (Service Contract)</description>
        <protected>false</protected>
        <recipients>
            <recipient>kara@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_Email_Deal_Pending_Cancelled</fullName>
        <description>Auto Email Deal Pending Cancelled</description>
        <protected>false</protected>
        <recipients>
            <field>Original_Proposal_Submitted_By_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_HelioPower_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>contracts@heliopower.com</ccEmails>
        <description>Auto-email to HelioPower when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Horizon_when_status_is_Deal_Cancelled_Service_Contract</fullName>
        <ccEmails>mayra@horizonsolarpower.com</ccEmails>
        <description>Auto-email to Horizon when status is &quot;Deal Cancelled&quot; (Service Contract)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Next_Step_Living_NSL_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>Wissem.taboubi@nextsteplivinginc.com</ccEmails>
        <description>Auto-email to Next Step Living (NSL) when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_OnForce_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>Ops@onforcesolar.com</ccEmails>
        <description>Auto-email to OnForce when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Rising_Sun_Solar_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>mitch@risingsunsolar.com</ccEmails>
        <description>Auto-email to Rising Sun Solar when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Solar_Alliance_of_America_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>accounting@solarallianceofamerica.com</ccEmails>
        <ccEmails>artie@solarallianceofamerica.com</ccEmails>
        <ccEmails>kristin@solarallianceofamerica.com</ccEmails>
        <description>Auto-email to Solar Alliance of America when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC_Sales_Partner</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Solar_Energy_World_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>SEW-leases@solareworld.com</ccEmails>
        <description>Auto-email to Solar Energy World when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Solar_Universe_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>ops_sfs@solaruniverse.com</ccEmails>
        <description>Auto-email to Solar Universe when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Sunlight_Solar_Energy_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>Alicia.sherman@sunlightsolar.com</ccEmails>
        <ccEmails>Elizabeth.george@sunlightsolar.com</ccEmails>
        <description>Auto-email to Sunlight Solar Energy when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Trinity_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>billie.klecko@trinitysolarsystems.com</ccEmails>
        <ccEmails>lauren.english@trinity-solar.com</ccEmails>
        <description>Auto-email to Trinity when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>egabriel@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Auto_email_to_Verengo_when_status_is_Deal_Cancelled_SC</fullName>
        <ccEmails>Khinds@goverengo.com</ccEmails>
        <ccEmails>checkin@verengosolar.com</ccEmails>
        <description>Auto-email to Verengo when status is &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>ContactID_changed_on_this_Service_Contract</fullName>
        <description>ContactID changed on this Service Contract</description>
        <protected>false</protected>
        <recipients>
            <recipient>celiaw@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rmasineni@sunrunhome.com.prod</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>skapadi@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>skapadi@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ContactID_changed_on_this_Service_Contract</template>
    </alerts>
    <alerts>
        <fullName>Cost_stack_changed</fullName>
        <description>Cost stack changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>djohnson@sunrun.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dlamin@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jennifer.klein@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>skapadi@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Cost_Stack_Changed</template>
    </alerts>
    <alerts>
        <fullName>Customer_Email_After_Target_Install_Date_Is_Set_for_Sales_EPC_Deals_SC</fullName>
        <description>Customer Email After Target Install Date Is Set (for Sales/EPC Deals) (SC)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Customer_Email_After_Target_Install_Date_Is_Set_for_Sales_EPC_Deals_SC</template>
    </alerts>
    <alerts>
        <fullName>Deal_Not_Signed_Awaiting_Credit_Approval_to_Deal_Cancelled_SC</fullName>
        <ccEmails>credit@yopmail.com</ccEmails>
        <description>&quot;Deal Not Signed, Awaiting Credit Approval&quot; to &quot;Deal Cancelled&quot; (SC)</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Deal_Not_Signed_Awaiting_Credit_Approval_to_Deal_Cancelled_SC</template>
    </alerts>
    <alerts>
        <fullName>REC_Cancellation_Notification_SC</fullName>
        <description>REC - Cancellation Notification (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>kara@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>melissa.haupt@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>billing@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>RevoluSun_Cancellation_Notification_SC</fullName>
        <ccEmails>lorry@revolusun.com</ccEmails>
        <ccEmails>aline@revolusun.com</ccEmails>
        <description>RevoluSun - Cancellation Notification (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>kara@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Roof_Diagnostics_Auto_cancellation_notification_SC</fullName>
        <ccEmails>kelcy@roofdiagnostics.com</ccEmails>
        <ccEmails>mike@roofdiagnostics.com</ccEmails>
        <ccEmails>eva@roofdiagnostics.com</ccEmails>
        <ccEmails>sam@roofdiagnostics.com</ccEmails>
        <ccEmails>dan@roofdiagnostics.com</ccEmails>
        <description>Roof Diagnostics Auto cancellation notification (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>egabriel@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <alerts>
        <fullName>Send_Cust_Ref_Num_to_Trinity_SC</fullName>
        <ccEmails>Ed.Merrick@trinitysolarsystems.com</ccEmails>
        <ccEmails>andrea.kelly@trinitysolarsystems.com</ccEmails>
        <description>Send Cust Ref Num to Trinity (SC)</description>
        <protected>false</protected>
        <senderAddress>operations@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Send_Cust_Ref_Num_to_Trinity_SC</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_when_Status_is_Deal_Cancelled</fullName>
        <ccEmails>cancel@sungevity.com</ccEmails>
        <description>Send Email when Status is Deal Cancelled</description>
        <protected>false</protected>
        <senderAddress>customercare@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Agreement_Cancellation_Partner_Notification_SC</template>
    </alerts>
    <fieldUpdates>
        <fullName>COBF_TE_Fund_Name</fullName>
        <field>TE_Fund_Name__c</field>
        <literalValue>Customer Owned - Bank Financed</literalValue>
        <name>COBF TE Fund Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>COS_Billing_Method</fullName>
        <field>Billing_Method__c</field>
        <literalValue>Customer Owned - Full Upfront</literalValue>
        <name>COS Billing Method</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>COS_In_TE_Fund_Date</fullName>
        <field>In_TE_Fund__c</field>
        <formula>DATEVALUE(LastModifiedDate)</formula>
        <name>COS In TE Fund Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>COS_TE_Fund_Name</fullName>
        <field>TE_Fund_Name__c</field>
        <literalValue>Customer Owned CASH</literalValue>
        <name>COS TE Fund Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Cost_Stack_to_Integrated</fullName>
        <field>Cost_Stack__c</field>
        <formula>&quot;INTEGRATED_SUNRUN_SELLS&quot;</formula>
        <name>Cost Stack to Integrated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Est_GAAP_Cost_Update</fullName>
        <description>Updates the Est GAAP Cost to equal EPC Price</description>
        <field>Estimated_GAAP_Cost__c</field>
        <formula>EPC_Price__c</formula>
        <name>Est GAAP Cost Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Full_Upfront_if_TS_SC</fullName>
        <field>Billing_Method__c</field>
        <literalValue>Full Upfront</literalValue>
        <name>Full Upfront if TS (SC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>M1_Terms_SC</fullName>
        <field>M1_Terms__c</field>
        <formula>Case( Install_Partner__c , 
&quot;1st Light Energy&quot;, IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,07,01),0.80,0.5), 
&quot;Acro Energy&quot;, 0.5,
&quot;Apex Solar Power LLC&quot;,0.8,
&quot;Acos Energy LLC&quot;,0.8, 
&quot;Akeena Solar&quot;, 0.6, 
&quot;Alteris Renewables&quot;, 0.5,
&quot;American Renewable Energy Inc.&quot;,0.6,
&quot;American Solar&quot;,2000, 
&quot;American Solar - New Homes&quot;,2000,
&quot;Arcadia Solar&quot;,0.8,
&quot;Clear Solar Co.&quot;,IF (DATEVALUE (Service_Contract_Event__r.SR_Signoff__c )  &gt;= DATE(2016,08,01),0.8,
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,05,01),  DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,07,31)),0.75,
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,02,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,04,30)),0.7,0.6))),
&quot;ClearSolar, CA, Inc.&quot;,IF (DATEVALUE (Service_Contract_Event__r.SR_Signoff__c )  &gt;= DATE(2016,08,01),0.8,
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,05,01),  DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,07,31)),0.75,
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,02,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,04,30)),0.7,0.6))),
&quot;Florenton River LLC&quot;,0.6,
&quot;Garcia &amp; Garcia Affordable Roofing, Incorporated&quot;,0.6,
&quot;Green Home Designs of California DBA Green Homes of California&quot;,0.8,
&quot;GoSolarPros&quot;,0.8, 
&quot;Horizon Solar Power&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,01),0.9,0.8), 
&quot;Imagine Energy&quot;,0.5, 
&quot;Islandwide&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,01),0.80,0.55),
&quot;IES&quot;,0.8,
&quot;Kopp Electric Company&quot;,0.8, 
&quot;Munro Distributing&quot;,0.5, 
&quot;Volt Solar LLC&quot;,0.8,
&quot;Onforce Solar&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,07,01),0.80,0.5),
&quot;Precis Development Inc.&quot;,0.6,
&quot;PetersenDean&quot;,0.6, 
&quot;PetersenDean - New Home&quot;, 0.6, 
&quot;Real Goods&quot;,0.5, 
&quot;REC Solar&quot;, 0.6, 
&quot;Sky High Energy LLC&quot;,0.8,
&quot;Slingshot Power, PBC&quot;,0.8,
&quot;Standard Energy Solutions&quot;,0.8,
&quot;SolarFlair Energy, Inc.&quot;,0.6,
&quot;Solarfirst Inc&quot;,0.8,
&quot;Solarmax Renewable Energy Provider, Inc.&quot;,0.8,
&quot;Sunrun&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,07,01),0.8,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,02,19),0.45,0.6)),
&quot;Streamline Solar Power Systems LLC&quot;,0.8,
&quot;RCL Enterprises, Inc.&quot;, IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,01),0.60,0.80),
&quot;Responsible Solar, Inc.&quot;, 0.6,
&quot;Reliable Power Services, Inc.&quot;,0.6, 
&quot;Rising Sun Solar&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,15),0.9,0.55), 
&quot;Roof Diagnostics&quot;, 0.6, 
&quot;Solar Universe&quot;,0.80, 
&quot;Sunlight Solar Energy&quot;, 0.8, 
&quot;Sunrun Installation Services&quot;, 0.45,
&quot;SunWize Home&quot;, 0.8, 
&quot;Verengo&quot;, 0.5,  
&quot;Smart Energy USA&quot;, IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,05,01),0.8,0.6), 
0.6)</formula>
        <name>M1 Terms (SC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>M2_Terms_SC</fullName>
        <field>M2_Terms__c</field>
        <formula>Case( Install_Partner__c , 
&quot;1st Light Energy&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,07,01),0, 0.3),
&quot;Acro Energy&quot;, 0.4, 
&quot;Apex Solar Power LLC&quot;,0.0,
&quot;Acos Energy LLC&quot;,0, 
&quot;Akeena Solar&quot;, 0.3, 
&quot;Alteris Renewables&quot;, 0.3,
&quot;American Renewable Energy Inc.&quot;,0,
&quot;American Solar&quot;,0.8, 
&quot;American Solar - New Homes&quot;,0.95,
&quot;Arcadia Solar&quot;,0,
&quot;Clear Solar Co.&quot;,IF (DATEVALUE (Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,08,01),0, 
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,05,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,07,31)),0, IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,02,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,04,30)),0,0))), 
&quot;ClearSolar, CA, Inc.&quot;,IF (DATEVALUE (Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,08,01),0, 
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,05,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,07,31)),0, IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,02,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,04,30)),0,0))),
&quot;Florenton River LLC&quot;,0.2,
&quot;Garcia &amp; Garcia Affordable Roofing, Incorporated&quot;, 0.2,
&quot;Green Home Designs of California DBA Green Homes of California&quot;,0.1,
&quot;GoSolarPros&quot;,0.0, 
&quot;Horizon Solar Power&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,01),0,0.1), 
&quot;Imagine Energy&quot;,0.3, 
&quot;Islandwide&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,01),0,0.35), 
&quot;IES&quot;,0.0,
&quot;Kopp Electric Company&quot;,0,
&quot;Munro Distributing&quot;,0.3, 
&quot;Onforce Solar&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,07,01),0,0.3), 
&quot;PetersenDean&quot;,0.3, 
&quot;PetersenDean - New Home&quot;, 0.2,
&quot;Precis Development Inc.&quot;, 0.2,
&quot;RCL Enterprises, Inc.&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,01),0.20,0),
&quot;Real Goods&quot;,0.3, 
&quot;Volt Solar LLC&quot;,0,
&quot;REC Solar&quot;, 0.3,
&quot;Reliable Power Services, Inc.&quot;,0.2,
&quot;Responsible Solar, Inc.&quot;,0.2,
&quot;Standard Energy Solutions&quot;,0.0,
&quot;SolarFlair Energy, Inc.&quot;,0.2,
&quot;Solarfirst Inc&quot;,0.0,
&quot;Solarmax Renewable Energy Provider, Inc.&quot;,0.0,
&quot;Sky High Energy LLC&quot;,0,
&quot;Sunrun&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,07,01),0,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,02,19),0.45, 0.3)),
&quot;Streamline Solar Power Systems LLC&quot;,0.0,
&quot;Slingshot Power, PBC&quot;,0.0,
&quot;Rising Sun Solar&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,15),0,0.35), 
&quot;Roof Diagnostics&quot;, 0.3,  
&quot;Solar Universe&quot;,0.00,
&quot;Sunlight Solar Energy&quot;, 0.0,
&quot;Sunrun Installation Services&quot;, 0.45,
&quot;SunWize Home&quot;, 0.0,
&quot;Verengo&quot;, 0.3, 
&quot;Smart Energy USA&quot;, IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,05,01),0,0.2), 
0.2)</formula>
        <name>M2 Terms (SC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>M3_Terms_SC</fullName>
        <field>M3_Terms__c</field>
        <formula>Case( Install_Partner__c , 
&quot;1st Light Energy&quot;, 0.2,
&quot;Acro Energy&quot;, 0.1, 
&quot;Apex Solar Power LLC&quot;,0.2,
&quot;Acos Energy LLC&quot;,0.2, 
&quot;Akeena Solar&quot;, 0.1, 
&quot;Alteris Renewables&quot;, 0.2,
&quot;American Renewable Energy Inc.&quot;,0.2,
&quot;American Solar&quot;,0.2, 
&quot;American Solar - New Homes&quot;,0.05,
&quot;Arcadia Solar&quot;,0.2,
&quot;Clear Solar Co.&quot;,IF (DATEVALUE (Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,08,01),0.2, 
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,05,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,07,31)),0.2, 
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,02,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,04,30)),0.2,0.2))), 
&quot;ClearSolar, CA, Inc.&quot;,IF (DATEVALUE (Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,08,01),0.2, 
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,05,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,07,31)),0.2, 
IF (AND(DATEVALUE(Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2016,02,01), DATEVALUE(Service_Contract_Event__r.SR_Signoff__c )&lt;= DATE(2016,04,30)),0.2,0.2))),
&quot;Florenton River LLC&quot;,0.2,
&quot;Garcia &amp; Garcia Affordable Roofing, Incorporated&quot;, 0.2,
&quot;Green Home Designs of California DBA Green Homes of California&quot;,0.1,
&quot;GoSolarPros&quot;,0.2, 
&quot;Horizon Solar Power&quot;,0.1, 
&quot;Imagine Energy&quot;,0.2, 
&quot;Volt Solar LLC&quot;,0.2,
&quot;Islandwide&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,06,01),0.20,0.1), 
&quot;IES&quot;,0.2,
&quot;Kopp Electric Company&quot;,0.2,
&quot;Munro Distributing&quot;,0.2, 
&quot;Onforce Solar&quot;,0.2, 
&quot;PetersenDean&quot;,0.1, 
&quot;PetersenDean - New Home&quot;, 0.2,
&quot;Precis Development Inc.&quot;, 0.2, 
&quot;Real Goods&quot;,0.2, 
&quot;REC Solar&quot;, 0.1,
&quot;Reliable Power Services, Inc.&quot;,0.2,
&quot;Responsible Solar, Inc.&quot;,0.2,
&quot;SolarFlair Energy, Inc.&quot;,0.2,
&quot;Standard Energy Solutions&quot;,0.2,
&quot;Solarmax Renewable Energy Provider, Inc.&quot;,0.2, 
&quot;Solarfirst Inc&quot;,0.2,
&quot;Sky High Energy LLC&quot;,0.2,
&quot;Sunrun&quot;,IF( DATEVALUE( Service_Contract_Event__r.SR_Signoff__c ) &gt;= DATE(2015,07,01),0.2,0.1),
&quot;RCL Enterprises, Inc.&quot;,0.2, 
&quot;Rising Sun Solar&quot;,0.1, 
&quot;Roof Diagnostics&quot;, 0.1,
&quot;Streamline Solar Power Systems LLC&quot;,0.2, 
&quot;Slingshot Power, PBC&quot;,0.2, 
&quot;Solar Universe&quot;,0.20,
&quot;Sunlight Solar Energy&quot;,0.2,
&quot;Sunrun Installation Services&quot;, 0.1,
&quot;SunWize Home&quot;, 0.2,
&quot;Verengo&quot;, 0.2, 
&quot;Smart Energy USA&quot;, 0.2, 
0.2)</formula>
        <name>M3 Terms (SC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Mandatory_ACH_SC</fullName>
        <field>Billing_Method__c</field>
        <literalValue>Recurring</literalValue>
        <name>Mandatory ACH (SC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_M1_Terms_SC</fullName>
        <field>SO_M1_terms__c</field>
        <formula>Case
( Sales_Organization__c ,
&quot;Gen110&quot;, 0,
&quot;Solmentum&quot;,0,
&quot;Pinnacle&quot;, 0.75,
&quot;Go Solar LLC&quot;, 0.2,
&quot;Invictus&quot;, 0.8,
&quot;Next Step Living&quot;,0.7,
&quot;Green Home Solutions&quot;,0.5,
&quot;1BOG&quot;,0.7,
&quot;Island Sun Solar&quot;,0.6,
&quot;Sales Focus&quot;,0.6,
&quot;LGCY Power, LLC&quot;,0.6,
&quot;Fluent Home&quot;,0.6,
&quot;Red Ventures&quot;,0,
&quot;Generation Sun, LLC&quot;,0.35,
&quot;US Utilities LLC&quot;,0.2,
&quot;Clear Link Technologies, LLC&quot;,0,
&quot;Power Home Remodeling Group, LLC&quot;,0,
&quot;BrightCurrent&quot;,0.2,
&quot;Palmetto Solar LLC&quot;, 0,
&quot;AGR Group Nevada, LLC&quot;,0,
0.7)</formula>
        <name>SO M1 Terms (SC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_M2_Terms_SC</fullName>
        <field>SO_M2_terms__c</field>
        <formula>Case
( Sales_Organization__c ,
&quot;Gen110&quot;,0,
&quot;Solmentum&quot;, 0,
&quot;Pinnacle&quot;, 0.25,
&quot;Go Solar LLC&quot;, 0.8,
&quot;Invictus&quot;,0.2,
&quot;Next Step Living&quot;,0.2,
&quot;Green Home Solutions&quot;,0.3,
&quot;1BOG&quot;,0.2,
&quot;Island Sun Solar&quot;,0.2,
&quot;Sales Focus&quot;,0.2,
&quot;LGCY Power, LLC&quot;,0.2,
&quot;Fluent Home&quot;,0.3,
&quot;Red Ventures&quot;,0,
&quot;Generation Sun, LLC&quot;,0.65,
&quot;US Utilities LLC&quot;,0.8,
&quot;Clear Link Technologies, LLC&quot;,0,
&quot;Power Home Remodeling Group, LLC&quot;,1,
&quot;BrightCurrent&quot;,0.8,
&quot;Palmetto Solar LLC&quot;, 1,
&quot;AGR Group Nevada, LLC&quot;,1,
0.2)</formula>
        <name>SO M2 Terms (SC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_M3_Terms_SC</fullName>
        <field>SO_M3_terms__c</field>
        <formula>Case
( Sales_Organization__c ,
&quot;Gen110&quot;,0,
&quot;Solmentum&quot;, 0,
&quot;Pinnacle&quot;, 0,
&quot;Go Solar LLC&quot;, 0,
&quot;Invictus&quot;,0,
&quot;Next Step Living&quot;,0.1,
&quot;Green Home Solutions&quot;,0.2,
&quot;1BOG&quot;,0.1,
&quot;Island Sun Solar&quot;,0.2,
&quot;Sales Focus&quot;,0.2,
&quot;LGCY Power, LLC&quot;,0.2,
&quot;Fluent Home&quot;,0.1,
&quot;Red Ventures&quot;,1,
&quot;Generation Sun, LLC&quot;,0,
&quot;US Utilities LLC&quot;,0,
&quot;Clear Link Technologies, LLC&quot;,1,
&quot;Power Home Remodeling Group, LLC&quot;,0,
&quot;BrightCurrent&quot;,0,
&quot;Palmetto Solar LLC&quot;, 0,
&quot;AGR Group Nevada, LLC&quot;,0,
0.1)</formula>
        <name>SO M3 Terms (SC)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Deal_Cancelled</fullName>
        <description>If SC status = &quot;&quot;Cancellation in Progress&quot;&quot; for 48 hours, automatically switch the status to &quot;&quot;Deal Cancelled&quot;</description>
        <field>Status__c</field>
        <literalValue>Deal Cancelled</literalValue>
        <name>Status to Deal Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_to_Deal_Cancelled2</fullName>
        <field>Status__c</field>
        <literalValue>Deal Cancelled</literalValue>
        <name>Status to Deal Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Related_Timestamp</fullName>
        <field>RelatedObjects_Last_Modified_Date__c</field>
        <formula>NOW()</formula>
        <name>Update Related Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_South_ERP</fullName>
        <field>Processed_By_South_ERP__c</field>
        <literalValue>1</literalValue>
        <name>Update South ERP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Transfer_Price_SC_ONLY</fullName>
        <description>IF( TEXT(Grant_Application_Date__c)  = &quot;&quot;, (Transfer_Watt__c * 1000 * System_Size_DC__c),   NOW() - CreatedDate )</description>
        <field>Transfer_Price__c</field>
        <formula>System_Size_DC__c * Transfer_Watt__c * 1000</formula>
        <name>Update Transfer Price (SC ONLY)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>White_Lable_Flag</fullName>
        <field>Contract_Sold_Type__c</field>
        <literalValue>White Label</literalValue>
        <name>White Lable Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ASE - Cancellation Notification</fullName>
        <actions>
            <name>ASE_Cancellation_Notification_Service_Contract</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>American Solar</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Agreement Cancellation - American Electric</fullName>
        <actions>
            <name>Agreement_Cancellation_American_Electric_Service_Contract</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>American Electric</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to HelioPower when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_HelioPower_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>HelioPower</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Horizon when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Horizon_when_status_is_Deal_Cancelled_Service_Contract</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Sales_Organization__c</field>
            <operation>equals</operation>
            <value>Horizon Solar Power</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <description>Sends an automatic email to Helio when asset status is changed to &quot;deal cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Next Step Living %28NSL%29 when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Next_Step_Living_NSL_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Next Step Living</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Sales_Organization__c</field>
            <operation>equals</operation>
            <value>Next Step Living</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <description>Sends an automatic email to Next Step Living (NSL) when asset status is changed to &quot;deal cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to OnForce when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_OnForce_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>OnForce</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <description>Sends an automatic email to OnForce when asset status is changed to &quot;deal cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Rising Sun Solar when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Rising_Sun_Solar_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Rising Sun Solar</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Solar Alliance of America when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Solar_Alliance_of_America_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Sales_Organization__c</field>
            <operation>equals</operation>
            <value>Solar Alliance of America</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Solar Energy World when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Solar_Energy_World_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>contains</operation>
            <value>Solar Energy World</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <description>Sends an automatic email to Solar Energy World when asset status is changed to &quot;deal cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Solar Universe when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Solar_Universe_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Sales_Organization__c</field>
            <operation>equals</operation>
            <value>Solar Universe</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <description>Sends an automatic email to Solar Universe when asset status is changed to &quot;deal cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Sunlight Solar Energy when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Sunlight_Solar_Energy_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Sunlight Solar Energy</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <description>Sends an automatic email to Sunlight Solar Energy when asset status is changed to &quot;deal cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Trinity when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Trinity_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Trinity Solar</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <description>Sends an automatic email to Trinity when asset status is changed to &quot;deal cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto-email to Verengo when status is %22Deal Cancelled%22</fullName>
        <actions>
            <name>Auto_email_to_Verengo_when_status_is_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Verengo</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <description>Sends an automatic email to Verengo when asset status is changed to &quot;deal cancelled&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>COBF TE Fund Name</fullName>
        <actions>
            <name>COBF_TE_Fund_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>COS_In_TE_Fund_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND  ( ISPICKVAL(Agreement_Type__c, &quot;Customer Owned - Bank Financed&quot;),  ISPICKVAL(TE_Fund_Name__c, &quot;&quot;), OR( ISPICKVAL(Status__c, &quot;08. M1 received, Awaiting M2&quot;), ISPICKVAL(Status__c, &quot;09. M2 received, Awaiting PTO&quot;), ISPICKVAL(Status__c, &quot;10. PTO Granted, Facility Active&quot;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>COS Billing Method</fullName>
        <actions>
            <name>COS_Billing_Method</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Agreement_Type__c, &quot;Customer Owned - Full Upfront&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>COS TE Fund Name</fullName>
        <actions>
            <name>COS_In_TE_Fund_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>COS_TE_Fund_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND  ( ISPICKVAL(Agreement_Type__c, &quot;Customer Owned - Full Upfront&quot;),  ISPICKVAL(TE_Fund_Name__c, &quot;&quot;), OR( ISPICKVAL(Status__c, &quot;08. M1 received, Awaiting M2&quot;), ISPICKVAL(Status__c, &quot;09. M2 received, Awaiting PTO&quot;), ISPICKVAL(Status__c, &quot;10. PTO Granted, Facility Active&quot;) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cost Stack Changed</fullName>
        <actions>
            <name>Cost_stack_changed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>PRIORVALUE(Cost_Stack__c) &lt;&gt; Cost_Stack__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cost Stack for AZ Inside Sales</fullName>
        <actions>
            <name>Cost_Stack_to_Integrated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( (ISCHANGED( Cost_Stack__c )) , Sold_By__c = &apos;0016000000HhqcQ&apos;,  Installed_By__c = &apos;0016000000HhqcQ&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ERP Contact Changed</fullName>
        <actions>
            <name>ContactID_changed_on_this_Service_Contract</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND 
(
ISCHANGED(ContactId),
NOT(ISNEW())
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Est GAAP Cost Null</fullName>
        <actions>
            <name>Est_GAAP_Cost_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Estimated_GAAP_Cost__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.EPC_Price__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Runs if the Estimated GAAP Cost is Null and EPC Price is not Null</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Full Upfront if TS</fullName>
        <actions>
            <name>Full_Upfront_if_TS_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Agreement_Type__c</field>
            <operation>equals</operation>
            <value>SunRun Total Solar Prepaid Lease</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inactive_Update Related Timestamp</fullName>
        <actions>
            <name>Update_Related_Timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>ServiceContract.AccountId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Inactive_Update South ERP</fullName>
        <actions>
            <name>Update_South_ERP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Opportunity__r.Processed_By_South_ERP__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Mandatory ACH</fullName>
        <actions>
            <name>Mandatory_ACH_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.ACH_Required__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification when Customer Care cancels SC</fullName>
        <actions>
            <name>Send_Email_when_Status_is_Deal_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Sungevity</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Payment Terms</fullName>
        <actions>
            <name>M1_Terms_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>M2_Terms_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>M3_Terms_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SO_M1_Terms_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SO_M2_Terms_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SO_M3_Terms_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>ServiceContract.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Sales_Organization__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>REC - Cancellation Notification</fullName>
        <actions>
            <name>REC_Cancellation_Notification_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>REC Solar,Sunrun</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RevoluSun - Cancellation Notification</fullName>
        <actions>
            <name>RevoluSun_Cancellation_Notification_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>RevoluSun</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Roof Diagnostics Auto cancellation notification</fullName>
        <actions>
            <name>Roof_Diagnostics_Auto_cancellation_notification_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Roof Diagnostics</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Deal Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Cust Ref Num to Trinity</fullName>
        <actions>
            <name>Send_Cust_Ref_Num_to_Trinity_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Trinity Solar</value>
        </criteriaItems>
        <criteriaItems>
            <field>ServiceContract.Contract_Sold_Type__c</field>
            <operation>notEqual</operation>
            <value>White Label</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status Cancellation in Progress</fullName>
        <actions>
            <name>Auto_Email_Deal_Pending_Cancelled</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ServiceContract.Status__c</field>
            <operation>equals</operation>
            <value>Cancellation in Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Status_to_Deal_Cancelled2</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>72</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Status Change from %22Deal Not Signed%2C Awaiting Credit Approval%22 to %22Deal Cancelled%22</fullName>
        <actions>
            <name>Deal_Not_Signed_Awaiting_Credit_Approval_to_Deal_Cancelled_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Status__c)  &amp;&amp;  (ISPICKVAL(Status__c, &quot;Deal Cancelled&quot;))  &amp;&amp;  (ISPICKVAL( PRIORVALUE(Status__c) , &quot;Deal Not Signed, Awaiting Credit Approval&quot;)) &amp;&amp; NOT(ISPICKVAL(Contract_Sold_Type__c, &quot;White Label&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Transfer Price %28SC ONLY%29</fullName>
        <actions>
            <name>Update_Transfer_Price_SC_ONLY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(Grant_Application_Date__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>White Lable Flag</fullName>
        <actions>
            <name>White_Lable_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR ( Proposal__r.Sales_Partner__r.Name = &apos;Sungevity&apos;, Proposal__r.Install_Partner__r.Name = &apos;Sungevity&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
