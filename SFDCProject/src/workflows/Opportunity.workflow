<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Fluent_Home_Email_to_Sales_Rep</fullName>
        <description>Fluent Home Email to Sales Rep</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Partner_Legacy_Proposal_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Indicates_when_a_lead_with_Partner_in_lead_source_closes</fullName>
        <ccEmails>keally@sunrun.com</ccEmails>
        <description>Indicates when a lead with &quot;Partner:&quot; in lead source closes</description>
        <protected>false</protected>
        <recipients>
            <recipient>mnelson@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Partner_close</template>
    </alerts>
    <alerts>
        <fullName>Proposal_Revision_Sales_Rep_Email</fullName>
        <description>Proposal Revision Sales Rep Email</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>proposal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Partner_Legacy_Proposal_Revision_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Confirm_Site_Visit_CONFERENCE</fullName>
        <description>Send Confirm Site Visit CONFERENCE</description>
        <protected>false</protected>
        <recipients>
            <field>Homeowner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Confirm_Site_Visit_CONFERENCE</template>
    </alerts>
    <alerts>
        <fullName>Send_Confirm_Site_Visit_One_Partner</fullName>
        <description>Send Confirm Site Visit One Partner</description>
        <protected>false</protected>
        <recipients>
            <field>Homeowner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Confirm_Site_Visit_One_Partner</template>
    </alerts>
    <alerts>
        <fullName>Send_Confirm_Site_Visit_Verengo_Acro</fullName>
        <description>Send Confirm Site Visit Verengo/Acro</description>
        <protected>false</protected>
        <recipients>
            <field>Homeowner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Confirm_Site_Visit_SCHEDULED</template>
    </alerts>
    <alerts>
        <fullName>Send_Converted_Site_Visit_Follow_Up</fullName>
        <description>Send Converted/Site Visit Follow Up</description>
        <protected>false</protected>
        <recipients>
            <field>Homeowner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Converted_Site_Visit_FUP</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Notification_to_Sales_Rep_when_Ready_For_is_Sales</fullName>
        <description>Send Email Notification to Sales Rep when Ready For is Sales</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>proposal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Partner_Legacy_Proposal_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Notification_to_Sales_Rep_when_Ready_For_is_Sales_Unable_to_Design</fullName>
        <description>Send Email Notification to Sales Rep when Ready For is Sales(Unable to Design)</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>proposal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Partner_Legacy_Proposal_Reject_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Notification_to_Sales_Rep_when_Site_Design_Status_is_Complete</fullName>
        <description>Send Email Notification to Sales Rep when Site Design Status is Complete</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Instant_Design_Complete</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Notification_to_Sales_Rep_when_Site_Design_Status_is_In_Progress</fullName>
        <description>Send Email Notification to Sales Rep when Site Design Status is In Progress</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Instant_Design_In_Progress</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Notification_to_Sales_Rep_when_Site_Design_Status_is_Open</fullName>
        <description>Send Email Notification to Sales Rep when Site Design Status is Open</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Instant_Design_In_Progress_to_Open</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_Notification_to_Sales_Rep_when_Site_Design_Status_is_System_Declined</fullName>
        <description>Send Email Notification to Sales Rep when Site Design Status is System Declined</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Instant_Design_System_Declined</template>
    </alerts>
    <alerts>
        <fullName>Send_Pass_To_Partner_Email</fullName>
        <description>Send Pass To Partner Email</description>
        <protected>false</protected>
        <recipients>
            <field>WF_P2P_Acct_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>WF_P2P_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Pass_to_Partner_Email</template>
    </alerts>
    <alerts>
        <fullName>Send_Site_Eval_FUP_Email_1</fullName>
        <description>Send Site Eval FUP Email 1</description>
        <protected>false</protected>
        <recipients>
            <field>Homeowner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Site_Eval_FUP_Email_1</template>
    </alerts>
    <alerts>
        <fullName>Sends_email_to_opps_for_whom_we_ve_set_site_visit_date_and_time</fullName>
        <description>Sends email to opps for whom we&apos;ve set site visit date and time</description>
        <protected>false</protected>
        <recipients>
            <field>Homeowner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Site_vist_set_auto_email</template>
    </alerts>
    <alerts>
        <fullName>Sends_email_to_opps_without_a_site_visit_date_time</fullName>
        <description>Sends email to opps without a site visit date/time</description>
        <protected>false</protected>
        <recipients>
            <field>Homeowner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Site_visit_not_set_auto_email</template>
    </alerts>
    <alerts>
        <fullName>Unable_to_create_proposal</fullName>
        <description>Unable to create proposal</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>proposal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Partner_Legacy_Proposal_Reject_Email_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Auto_populate_homeowner_s_full_name</fullName>
        <description>Combines Homeowner First Name and Homeowner Last Name</description>
        <field>Homeowner_Full_Name__c</field>
        <formula>Homeowner_First_Name__c&amp;&quot; &quot;&amp; Homeowner_Last_Name__c</formula>
        <name>Auto-populate homeowner&apos;s full name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_lead_origin</fullName>
        <description>Changes lead origin from SunRun to Partner</description>
        <field>Lead_Orgin__c</field>
        <literalValue>Partner</literalValue>
        <name>Change lead origin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Out_Designer_Field</fullName>
        <field>Designer__c</field>
        <name>Clear Out Designer Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_kwh_Collected_Stamp</fullName>
        <field>Date_kWh_Collected__c</field>
        <formula>Now()</formula>
        <name>Date kwh Collected Stamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Days_to_Closed_Won</fullName>
        <description>Days between when Lead is created and when Opportunity is marked &quot;7. Closed Won.&quot;</description>
        <field>Days_to_Closed_Won__c</field>
        <formula>TODAY() - Lead_Created_Date__c</formula>
        <name>Days to Closed Won</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deal_Desk_Response_Date</fullName>
        <field>Deal_Desk_Response__c</field>
        <formula>NOW()</formula>
        <name>Deal Desk Response Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>In_Progress_To_Open2</fullName>
        <field>Site_Design_Status__c</field>
        <literalValue>Open</literalValue>
        <name>In Progress To Open2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Square_Footage_0</fullName>
        <description>Default Square Footage to 0 when opportunity is created</description>
        <field>Square_footage__c</field>
        <formula>0</formula>
        <name>Opportunity_Square Footage=0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_First_Proposal_Created_Date</fullName>
        <description>Populates the opportunity field &quot;First Proposal Created Date&quot; with a date &amp; time that the first proposal was run</description>
        <field>First_Proposal_Created_Date__c</field>
        <formula>now()</formula>
        <name>Populate First Proposal Created Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proposal_Created_Stage</fullName>
        <field>StageName</field>
        <literalValue>Created</literalValue>
        <name>Proposal Created Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Proposal_Ready</fullName>
        <field>Opportunity_Status__c</field>
        <literalValue>Proposal Ready</literalValue>
        <name>Proposal Ready</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ReadyForUpdate</fullName>
        <description>when iKnock leads convert automatically, ReadyFor field is updated to Design</description>
        <field>Ready_for__c</field>
        <literalValue>Design</literalValue>
        <name>ReadyForUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Select_Confirm_Site_Visit_Email</fullName>
        <field>Select_Confirm_Site_Visit_Email__c</field>
        <name>Reset Select Confirm Site Visit Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Select_Pass_To_Partner_Email</fullName>
        <field>Select_Pass_To_Partner_Email__c</field>
        <name>Reset Select Pass To Partner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Send_Email_Notification</fullName>
        <field>Send_Email_Notification__c</field>
        <name>Reset Send Email Notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_WF_P2P_Acct_Email</fullName>
        <field>WF_P2P_Acct_Email__c</field>
        <name>Reset WF P2P Acct Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_WF_P2P_Rep_Email</fullName>
        <field>WF_P2P_Rep_Email__c</field>
        <name>Reset WF P2P Rep Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Site_Design_Requested_Date_Time</fullName>
        <field>Site_Design_Requested__c</field>
        <formula>Now()</formula>
        <name>Site Design Requested Date &amp;Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Void_Proposals</fullName>
        <field>Void_Proposals__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Void Proposals</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Rep_Division</fullName>
        <field>Sales_Rep_Division__c</field>
        <formula>TEXT(Sales_Representative__r.Division__c)</formula>
        <name>Update Sales Rep Division</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Rep_email</fullName>
        <field>Sales_Rep_Email__c</field>
        <formula>Sales_Representative__r.Email</formula>
        <name>Update Sales Rep email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>qualtrics__Qualtrics_Example_Outbound_Message</fullName>
        <apiVersion>19.0</apiVersion>
        <description>An example of how to setup an outbound message. 
The endpoint url is not valid and needs to be updated to a real out endpoint url.</description>
        <endpointUrl>http://survey.qualtrics.com/WRQualtricsServer/sfApi.php?r=outboundMessage&amp;u=UR_123456789&amp;s=SV_123456789&amp;t=TR_123456789</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>rcapatosto@sunrunhome.com</integrationUser>
        <name>Qualtrics Example Outbound Message</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Auto-populate homeowner%27s full name</fullName>
        <actions>
            <name>Auto_populate_homeowner_s_full_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Homeowner_First_Name__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Combination of homeowner&apos;s first name and last name</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear Out Designer Field</fullName>
        <actions>
            <name>Clear_Out_Designer_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( (ISPICKVAL(PRIORVALUE(Ready_for__c),&apos;Sales&apos;)), OR(ISPICKVAL(Ready_for__c,&apos;Design (Sunrun)&apos;) , ISPICKVAL(Ready_for__c,&apos;Design (Sunrun Proposal Tool)&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date kwh Collected - Oppty</fullName>
        <actions>
            <name>Date_kwh_Collected_Stamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Jan_Usage__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Days to Closed Won</fullName>
        <actions>
            <name>Days_to_Closed_Won</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>7. Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Created_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Days between when Lead is created and when Opportunity is marked &quot;7. Closed Won.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Deal Desk Response Date</fullName>
        <actions>
            <name>Deal_Desk_Response_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Deal_Desk_Notes__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email SalesRep for Site Design Status Complete</fullName>
        <actions>
            <name>Send_Email_Notification_to_Sales_Rep_when_Site_Design_Status_is_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send Email to Sales Rep When Site Design Status is &quot;Complete&quot;</description>
        <formula>AND(ISPICKVAL(Site_Design_Status__c,&quot;Complete&quot;), Opportunity_Division_Custom__c !=  $Label.AEE_label )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email SalesRep for Site Design Status In Progress</fullName>
        <actions>
            <name>Send_Email_Notification_to_Sales_Rep_when_Site_Design_Status_is_In_Progress</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email notification to Salesrep when Site Designer Status is In Progress</description>
        <formula>AND(ISPICKVAL( Site_Design_Status__c ,&quot;In Progress&quot;), Opportunity_Division_Custom__c !=  $Label.AEE_label )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email SalesRep for Site Design Status is Open</fullName>
        <actions>
            <name>Send_Email_Notification_to_Sales_Rep_when_Site_Design_Status_is_Open</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Site_Design_Status__c</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <description>Send email notification to salesrep when site design status is &quot;Open&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email SalesRep for Site Design Status is System Declined</fullName>
        <actions>
            <name>Send_Email_Notification_to_Sales_Rep_when_Site_Design_Status_is_System_Declined</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email to salesrep when site design status is &quot;System Declined&quot;</description>
        <formula>AND( ISPICKVAL(Site_Design_Status__c,&quot;System Declined&quot;), Opportunity_Division_Custom__c !=  $Label.AEE_label  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fluent Home Partner</fullName>
        <actions>
            <name>Fluent_Home_Email_to_Sales_Rep</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(Ready_for__c, &quot;Sales&quot;), ISPICKVAL(Channel_2__c, &quot;Partner&quot;), Sales_Representative__r.Pricing_Only__c = true)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification of Proposal Created</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Partners__c</field>
            <operation>equals</operation>
            <value>Greenspring Energy</value>
        </criteriaItems>
        <description>Email an AM when one of his/her partners has created a proposal</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity_Square Footage</fullName>
        <actions>
            <name>Opportunity_Square_Footage_0</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Square_footage__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Default Square Footage = 0</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Pass To Partner Notification</fullName>
        <actions>
            <name>Send_Pass_To_Partner_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Pass_To_Partner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_Pass_To_Partner_Email</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Notify partner account and/or sales rep when passing an opportunity to them</description>
        <formula>Send_Email_Notification__c = &quot;Pass To Partner&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate First Proposal Created Date</fullName>
        <actions>
            <name>Populate_First_Proposal_Created_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Number_of_Proposals__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.First_Proposal_Created_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Triggers a field update of the field &quot;First Proposal Created Date&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Sales Email%2Fdiv for PT</fullName>
        <actions>
            <name>Update_Sales_Rep_Division</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sales_Rep_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Sales_Representative_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Created Stage</fullName>
        <actions>
            <name>Proposal_Created_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Proposal_Ready</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Proposal Created</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Revision</fullName>
        <actions>
            <name>Proposal_Revision_Sales_Rep_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Ready_for__c</field>
            <operation>equals</operation>
            <value>Sales (revision)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Channel_2__c</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Source_2__c</field>
            <operation>equals</operation>
            <value>Partner: Legacy</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal created reminder</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Proposal Created</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Inside sales team members will receive an email 48 hours after a proposal has been created for an opportunity that they created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SRPP Close email alert</fullName>
        <actions>
            <name>Indicates_when_a_lead_with_Partner_in_lead_source_closes</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.LeadSource</field>
            <operation>contains</operation>
            <value>SRPP,Partner:</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>7. Closed Won</value>
        </criteriaItems>
        <description>Indicates when a lead from the SRPP program closes so that payment can be made</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Email Notification to Sales Rep</fullName>
        <actions>
            <name>Send_Email_Notification_to_Sales_Rep_when_Ready_For_is_Sales</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Ready_for__c</field>
            <operation>equals</operation>
            <value>Sales</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Channel_2__c</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Source_2__c</field>
            <operation>equals</operation>
            <value>Partner: Legacy</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Email Notification to Sales Rep Email</fullName>
        <actions>
            <name>Send_Email_Notification_to_Sales_Rep_when_Ready_For_is_Sales_Unable_to_Design</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Ready_for__c</field>
            <operation>equals</operation>
            <value>Sales (unable to design)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Channel_2__c</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Lead_Source_2__c</field>
            <operation>equals</operation>
            <value>Partner: Legacy</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Design Requested Date%2FTime</fullName>
        <actions>
            <name>Site_Design_Requested_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED( Site_Design_Priority__c ), NOT(ISPICKVAL(Site_Design_Priority__c, &apos;&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Site Design Status Update To Open</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Site_Design_Status__c</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>In_Progress_To_Open2</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.Trigger_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Site Visit Confirmation - Conference</fullName>
        <actions>
            <name>Send_Confirm_Site_Visit_CONFERENCE</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Confirm_Site_Visit_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_Site_Visit_Confirmation_Conference</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Confirm site visit with homeowner using Confirm Site Visit CONFERENCE template</description>
        <formula>AND ( Send_Email_Notification__c  = &quot;Confirm Site Visit&quot;,  ISPICKVAL ( Select_Confirm_Site_Visit_Email__c, &quot;Confirm Site Visit CONFERENCE&quot; ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Visit Confirmation - Eval FUP</fullName>
        <actions>
            <name>Send_Site_Eval_FUP_Email_1</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Confirm_Site_Visit_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_Site_Visit_Confirmation_Eval_FUP</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Confirm site visit with homeowner using Site Eval FUP Email 1 template</description>
        <formula>AND ( Send_Email_Notification__c  = &quot;Confirm Site Visit&quot;,  ISPICKVAL ( Select_Confirm_Site_Visit_Email__c, &quot;Site Eval FUP Email 1&quot; ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Visit Confirmation - Follow Up</fullName>
        <actions>
            <name>Send_Converted_Site_Visit_Follow_Up</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Confirm_Site_Visit_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_Site_Visit_Confirmation_Follow_Up</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Confirm site visit with homeowner using Converted/Site Visit Follow Up template</description>
        <formula>AND ( Send_Email_Notification__c  = &quot;Confirm Site Visit&quot;,  ISPICKVAL ( Select_Confirm_Site_Visit_Email__c, &quot;Converted/Site Visit Follow Up&quot; ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Visit Confirmation - One Partner</fullName>
        <actions>
            <name>Send_Confirm_Site_Visit_One_Partner</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Confirm_Site_Visit_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_Site_Visit_Confirmation_One_Partner</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Confirm site visit with homeowner using Confirm Site Visit One Partner template</description>
        <formula>AND ( Send_Email_Notification__c  = &quot;Confirm Site Visit&quot;,  ISPICKVAL ( Select_Confirm_Site_Visit_Email__c, &quot;Confirm Site Visit One Partner&quot; ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Site Visit Confirmation - Verengo%2FAcro</fullName>
        <actions>
            <name>Send_Confirm_Site_Visit_Verengo_Acro</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Confirm_Site_Visit_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_Site_Visit_Confirmation_Verengo_Acro</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Confirm site visit with homeowner using Confirm Site Visit Verengo/Acro template</description>
        <formula>AND ( Send_Email_Notification__c  = &quot;Confirm Site Visit&quot;,  ISPICKVAL ( Select_Confirm_Site_Visit_Email__c, &quot;Confirm Site Visit Verengo/Acro&quot; ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sun Chariot auto-email for Site Audit Scheduled</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Site_Audit_Date_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends the email &quot;Sun Chariot Site Audit Scheduled&quot; to Lucie Poulicakos at Sun Chariot when the opportunity field &quot;Site Audit Date/Time&quot; is populated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Unable to create proposal</fullName>
        <actions>
            <name>Unable_to_create_proposal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ISPICKVAL(Lead_Source_2__c , &apos;Partner: Legacy&apos;),ISPICKVAL( Channel_2__c ,&apos;Partner&apos;) ,OR( Unable_to_create_proposal__c , NOT(ISBLANK(Reason_for_not_generating_proposal__c)) , NOT(ISBLANK(Date_and_time_request__c ))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Uncheck Void Proposals</fullName>
        <actions>
            <name>Uncheck_Void_Proposals</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Void_Proposals__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>iKnockReadyfor</fullName>
        <actions>
            <name>ReadyForUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ready for field is assigned = Design for iKnock leads</description>
        <formula>AND(Sales_Partner__c =&apos;00160000012yDNR&apos;,NOT(ISPICKVAL(Ready_for__c, &apos;Design&apos;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>iPad2 Close email alert</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.LeadSource</field>
            <operation>contains</operation>
            <value>iPad2,Grand</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <description>Indicates when a lead from the iPad2 program closes so that payment can be made</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>qualtrics__Qualtrics Example Survey Rule</fullName>
        <actions>
            <name>qualtrics__Qualtrics_Example_Outbound_Message</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>An example of how to setup a rule to trigger a survey using an outbound message.  
In this example when an opportunity is closed we want to email the opportunity and see how their interaction with the sales representative went.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Sent_Pass_To_Partner_Email</fullName>
        <assignedToType>owner</assignedToType>
        <description>Pass To Partner email was sent.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent Pass To Partner Email</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Site_Visit_Confirmation_Conference</fullName>
        <assignedToType>owner</assignedToType>
        <description>Site Visit Confirmation - Conference email was sent to the homeowner</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent Site Visit Confirmation - Conference</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Site_Visit_Confirmation_Eval_FUP</fullName>
        <assignedToType>owner</assignedToType>
        <description>Site Visit Confirmation - Eval FUP email was sent to the homeowner</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent Site Visit Confirmation - Eval FUP</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Site_Visit_Confirmation_Follow_Up</fullName>
        <assignedToType>owner</assignedToType>
        <description>Site Visit Confirmation - Follow Up email was sent to the homeowner</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent Site Visit Confirmation - Follow Up</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Site_Visit_Confirmation_One_Partner</fullName>
        <assignedToType>owner</assignedToType>
        <description>Site Visit Confirmation - One Partner email was sent to the homeowner</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent Site Visit Confirmation - One Partner</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Site_Visit_Confirmation_Verengo_Acro</fullName>
        <assignedToType>owner</assignedToType>
        <description>Site Visit Confirmation - Verengo/Acro email was sent to the homeowner</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent Site Visit Confirmation - Verengo/Acro</subject>
    </tasks>
</Workflow>
