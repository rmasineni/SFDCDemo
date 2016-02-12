<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Brea_designers_lead_created_notification</fullName>
        <description>Brea designers lead created notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Brea_designers_lead_created_notification</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>partnerportal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Partner_Legacy_Lead</template>
    </alerts>
    <alerts>
        <fullName>Send_01_Missed_Call_1_Email</fullName>
        <description>Send 01 Missed Call#1 Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/X1st_Missed_Call</template>
    </alerts>
    <alerts>
        <fullName>Send_01_Missed_Call_1_Email_Online_Lead_Company</fullName>
        <description>Send 01 Missed Call #1 Email Online Lead Company</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/X01_Missed_Call_1_Online_Lead_Company</template>
    </alerts>
    <alerts>
        <fullName>Send_02_Missed_Call_2_Email</fullName>
        <description>Send 02 Missed Call#2 Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/X2nd_Missed_Call</template>
    </alerts>
    <alerts>
        <fullName>Send_03_Missed_Call_3_Final_email</fullName>
        <description>Send 03 Missed Call#3 - Final email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Missed_Call_Final_email</template>
    </alerts>
    <alerts>
        <fullName>Send_Susan_Kraemer_Leads</fullName>
        <description>Send Susan Kraemer Leads</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Susan_Kraemer_Leads</template>
    </alerts>
    <alerts>
        <fullName>Send_open_lead_alert_email</fullName>
        <description>Send open lead alert email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Open_lead_alert</template>
    </alerts>
    <alerts>
        <fullName>Sierra_Club_Welcome_email</fullName>
        <description>Sierra Club Welcome email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>insidesales@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Special_Lead_Source/Sierra_Club_Lead_form_qualified</template>
    </alerts>
    <alerts>
        <fullName>Sierra_club_low_bill_email</fullName>
        <description>Sierra club low bill email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>insidesales@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Special_Lead_Source/Sierra_Club_Lead_form_unqualified_LOW_BILLS</template>
    </alerts>
    <alerts>
        <fullName>Urgent_Open_Lead</fullName>
        <description>Urgent - Open Lead</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Urgent_Open_lead</template>
    </alerts>
    <alerts>
        <fullName>Web_Lead_Email_Alert</fullName>
        <description>Web Lead Email Alert RJ Fimbres</description>
        <protected>false</protected>
        <recipients>
            <recipient>mathias.wust@sunrun.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/New_Lead_Assigment_rule_for_Clean_Energy</template>
    </alerts>
    <alerts>
        <fullName>Web_Lead_Email_Alert_Karen_Cleland</fullName>
        <description>Web Lead Email Alert - Karen Cleland</description>
        <protected>false</protected>
        <recipients>
            <recipient>development@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/New_Lead_Assigment_rule_for_Clean_Energy</template>
    </alerts>
    <alerts>
        <fullName>template_test</fullName>
        <ccEmails>smirpuri@salesforce.com</ccEmails>
        <description>template test</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/New_Lead_Assigment_rule_for_Clean_Energy</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_to_RJ_Fimbres</fullName>
        <field>OwnerId</field>
        <lookupValue>development@sunrunhome.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to RJ Fimbres</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_populate_E_mail_field</fullName>
        <description>Copies data from &quot;Email&quot; into &quot;E-mail&quot; because Email maps to contact and E-mail maps to opportunity</description>
        <field>E_mail__c</field>
        <formula>Email</formula>
        <name>Auto-populate E-mail field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_populate_USA</fullName>
        <field>Country</field>
        <formula>&quot;USA&quot;</formula>
        <name>Auto-populate USA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Why_unqualified_to_low_bills</fullName>
        <description>Changes the &quot;why unqualified&quot; field to equal low bills</description>
        <field>Why_Unqualified__c</field>
        <literalValue>Low Bills</literalValue>
        <name>Change &quot;Why unqualified&quot; to low bills</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_lead_status_to_unqualified</fullName>
        <description>Sets lead status = unqualified</description>
        <field>Status</field>
        <literalValue>Unqualified</literalValue>
        <name>Change lead status to unqualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_box_for_Auto_Unqualified</fullName>
        <description>Populates the field &quot;Auto-Unqualified&quot;</description>
        <field>Auto_Unqualified__c</field>
        <literalValue>1</literalValue>
        <name>Check box for &quot;Auto-Unqualified&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Channel</fullName>
        <field>Contact_Channel__c</field>
        <formula>TEXT(Channel__c)</formula>
        <name>Contact Channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_Lead_Source</fullName>
        <field>Contact_Lead_Source__c</field>
        <formula>TEXT(Custom_Lead_Source__c)</formula>
        <name>Contact Lead Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Latitude_to_Geolocation_Field</fullName>
        <field>Address_Location__Latitude__s</field>
        <formula>Latitude__c</formula>
        <name>Copy Latitude to Geolocation Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Lead_Id</fullName>
        <field>Lead_Id__c</field>
        <formula>Id</formula>
        <name>Copy Lead Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Longitude_to_Geolocation_Field</fullName>
        <field>Address_Location__Longitude__s</field>
        <formula>Longitude__c</formula>
        <name>Copy Longitude to Geolocation Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Portal_Lead_Assignment_1</fullName>
        <field>OwnerId</field>
        <lookupValue>development@sunrunhome.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Customer Portal Lead Assignment 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Portal_Lead_Assignment_2</fullName>
        <field>OwnerId</field>
        <lookupValue>development@sunrunhome.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Customer Portal Lead Assignment 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Portal_Lead_Assignment_3</fullName>
        <field>OwnerId</field>
        <lookupValue>development@sunrunhome.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Customer Portal Lead Assignment 3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Portal_Lead_Assignment_4</fullName>
        <field>OwnerId</field>
        <lookupValue>development@sunrunhome.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Customer Portal Lead Assignment 4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Portal_Lead_Assignment_5</fullName>
        <field>OwnerId</field>
        <lookupValue>development@sunrunhome.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Customer Portal Lead Assignment 5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DO_NOT_CALL_BACK</fullName>
        <field>Callback_Disposition__c</field>
        <literalValue>DO NOT CALL BACK</literalValue>
        <name>DO NOT CALL BACK</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_kwh_Collected_Stamp_Lead</fullName>
        <field>Date_kWh_Collected__c</field>
        <formula>Now()</formula>
        <name>Date kwh Collected Stamp Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Do_not_share_with_Sunrun</fullName>
        <field>Share_w_Sunrun__c</field>
        <literalValue>0</literalValue>
        <name>Do not share with Sunrun</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Homeowner_First_Name</fullName>
        <description>Auto-populates homeowner name from lead name</description>
        <field>Homeowner_First_Name__c</field>
        <formula>FirstName</formula>
        <name>Homeowner First Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Homeowner_Last_Name</fullName>
        <description>Auto-populates homeowner&apos;s last name</description>
        <field>Homeowner_Last_Name__c</field>
        <formula>LastName</formula>
        <name>Homeowner Last Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Homeowner_Phone</fullName>
        <field>Homeowner_Phone__c</field>
        <formula>Phone</formula>
        <name>Homeowner Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Invoca_Channel_Update</fullName>
        <field>Channel_Last__c</field>
        <formula>Invoca_Channel_new__c</formula>
        <name>Invoca_Channel_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Invoca_Field_Update</fullName>
        <field>Lead_Source_Last__c</field>
        <formula>Invoca_Lead_Source_new__c</formula>
        <name>Invoca_LeadSource_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead</fullName>
        <description>Make Usage Option to NA if the Utility Company is not equal to PG&amp;E/SMUD/SCE/SDG&amp;E</description>
        <field>Usage_Option__c</field>
        <literalValue>NA</literalValue>
        <name>Lead_UsageOption=NA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Origin_SunRun</fullName>
        <description>Field update to set Lead Origin = SunRun</description>
        <field>Lead_Origin__c</field>
        <literalValue>SunRun</literalValue>
        <name>Lead Origin = SunRun</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_SquareFootage_0</fullName>
        <description>Default square footage = 0 when lead is created</description>
        <field>Square_footage__c</field>
        <formula>0</formula>
        <name>Lead_SquareFootage=0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Status_to_Converted</fullName>
        <field>Lead_Status__c</field>
        <literalValue>Converted</literalValue>
        <name>Lead Status to Converted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_UsageOption_Basic</fullName>
        <description>Field Update to set UsageOption = Basic</description>
        <field>Usage_Option__c</field>
        <literalValue>Basic</literalValue>
        <name>Lead_UsageOption=Basic</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Wait_to_1st_Attempt</fullName>
        <field>l_Lead_Wait_to_1st_Attempt__c</field>
        <formula>(NOW() - CreatedDate)*1440</formula>
        <name>Lead Wait to 1st Attempt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Master_Lead_Source_Organic_Search</fullName>
        <description>Groups all organic search lead sources (Google, Bing, etc.) into &quot;Organic Search&quot;</description>
        <field>Master_Lead_Source_TEST__c</field>
        <literalValue>Organic Search</literalValue>
        <name>Master Lead Source: Organic Search</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PopulateLeadCreatedDate</fullName>
        <field>Lead_Created_Date__c</field>
        <formula>datevalue(CreatedDate)</formula>
        <name>Populate Lead Created Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Select_Missed_Call_Email</fullName>
        <field>Select_Missed_Call_Email__c</field>
        <name>Reset Select Missed Call Email</name>
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
        <fullName>Set_Lead_Status_to_Open</fullName>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>Set Lead Status to Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Setting_to_Null</fullName>
        <field>Callback_Disposition__c</field>
        <name>Setting to Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Share_with_Sunrun</fullName>
        <field>Share_w_Sunrun__c</field>
        <literalValue>1</literalValue>
        <name>Share with Sunrun</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Channel</fullName>
        <field>Channel__c</field>
        <literalValue>Referral</literalValue>
        <name>Update Channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Install_Branch</fullName>
        <field>Install_Branch__c</field>
        <name>Update Install Branch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Source</fullName>
        <description>Referral: Customer Portal</description>
        <field>Custom_Lead_Source__c</field>
        <literalValue>Referral: Customer Portal</literalValue>
        <name>Update Lead Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Stage</fullName>
        <field>Status</field>
        <literalValue>Closed Lost</literalValue>
        <name>Update Lead Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Status</fullName>
        <field>Lead_Status__c</field>
        <literalValue>Bad Contact Info</literalValue>
        <name>Update Lead Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PP_Channel</fullName>
        <field>Channel__c</field>
        <literalValue>Partner</literalValue>
        <name>Update PP Channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_PP_Lead_Source</fullName>
        <field>Custom_Lead_Source__c</field>
        <literalValue>Sales Partner</literalValue>
        <name>Update PP Lead Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Rep_Email_Lead</fullName>
        <field>Sales_Rep_Email__c</field>
        <formula>SalesRep__r.Contact.Email</formula>
        <name>Update Sales Rep Email (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Rep_Phone_Lead</fullName>
        <field>SalesCellPhone__c</field>
        <formula>SalesRep__r.Contact.Phone</formula>
        <name>Update Sales Rep Phone (Lead)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sync_Status_Field</fullName>
        <field>External_Sync_Status__c</field>
        <literalValue>Sync Not Applicable</literalValue>
        <name>Update Sync Status Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto-populate E-mail field</fullName>
        <actions>
            <name>Auto_populate_E_mail_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Copies email address that is in the &quot;Email&quot; field to the &quot;E-mail&quot; field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Auto-populate homeowner first name</fullName>
        <actions>
            <name>Homeowner_First_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.FirstName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Auto-populate homeowner last name</fullName>
        <actions>
            <name>Homeowner_Last_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LastName</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Auto-populates the homeowner&apos;s last name</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Brea designers lead created notification</fullName>
        <actions>
            <name>Brea_designers_lead_created_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Channel__c</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Custom_Lead_Source__c</field>
            <operation>equals</operation>
            <value>Partner: Legacy</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Check box %22Auto-Unqualified%22</fullName>
        <actions>
            <name>Check_box_for_Auto_Unqualified</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Lead_Status__c</field>
            <operation>equals</operation>
            <value>Unqualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Why_Unqualified__c</field>
            <operation>notEqual</operation>
            <value>Duplicate lead - System Found Duplicate Lead,Duplicate lead - System Found Duplicate Oppty</value>
        </criteriaItems>
        <description>Populates the field &quot;Auto-Unqualified&quot; if a lead is created with lead status = unqualified</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Contact Channel</fullName>
        <actions>
            <name>Contact_Channel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Channel__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contact Lead Source</fullName>
        <actions>
            <name>Contact_Lead_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Custom_Lead_Source__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Copy Latitude%2FLongitude to Geolocation Field</fullName>
        <actions>
            <name>Copy_Latitude_to_Geolocation_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Longitude_to_Geolocation_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow rule is used to copy the current value of Latitude__c and Longitude__c to Address_Location__c GeoLocation field.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Copy Lead Id</fullName>
        <actions>
            <name>Copy_Lead_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LastName</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Customer Portal Lead Assignment 1</fullName>
        <actions>
            <name>Customer_Portal_Lead_Assignment_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>equals</operation>
            <value>SunRun CRM</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Customer Portal Lead Assignment 2</fullName>
        <actions>
            <name>Customer_Portal_Lead_Assignment_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>equals</operation>
            <value>SunRun CRM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Round_Robin_ID__c</field>
            <operation>equals</operation>
            <value>2</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Customer Portal Lead Assignment 3</fullName>
        <actions>
            <name>Customer_Portal_Lead_Assignment_3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>equals</operation>
            <value>SunRun CRM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Round_Robin_ID__c</field>
            <operation>equals</operation>
            <value>3</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Customer Portal Lead Assignment 4</fullName>
        <actions>
            <name>Customer_Portal_Lead_Assignment_4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>equals</operation>
            <value>SunRun CRM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Round_Robin_ID__c</field>
            <operation>equals</operation>
            <value>4</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Customer Portal Lead Assignment 5</fullName>
        <actions>
            <name>Customer_Portal_Lead_Assignment_5</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>equals</operation>
            <value>SunRun CRM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Round_Robin_ID__c</field>
            <operation>equals</operation>
            <value>5</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Date kWh Collected Lead</fullName>
        <actions>
            <name>Date_kwh_Collected_Stamp_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Jan_Usage__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>BSKY-4282</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Do not share with Sunrun</fullName>
        <actions>
            <name>Do_not_share_with_Sunrun</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( NOT(Sales_Partner__r.Name = &quot;Sunrun&quot;),NOT(Sales_Partner__r.Name = &quot;&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Homeowner Phone</fullName>
        <actions>
            <name>Homeowner_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Phone</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Invoca_Updated_Picklist</fullName>
        <actions>
            <name>Invoca_Channel_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Invoca_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>A workflow to trigger every time the Invoca fields are updated that pushes those values to our standard channel last, type last, and source last fields.</description>
        <formula>ISCHANGED(Invoca_Channel_new__c)  ||  ISCHANGED( Invoca_Lead_Source_new__c )  ||  ISCHANGED( Invoca_Lead_Type_new__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead Email - Missed Call %231 Online Lead Company</fullName>
        <actions>
            <name>Send_01_Missed_Call_1_Email_Online_Lead_Company</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Missed_Call_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_01_Missed_Call_1_Email_Online_Lead_Company</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send Missed Call #1 Email Online Lead Company</description>
        <formula>AND ( Send_Email_Notification__c = &quot;Missed Call Email&quot;, ISPICKVAL (  Select_Missed_Call_Email__c , &quot;01 Missed Call #1 Online Lead Company&quot; ),  Lead_Division_Custom__c !=  $Label.AEE_label  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Email - Missed Call%231</fullName>
        <actions>
            <name>Send_01_Missed_Call_1_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Missed_Call_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_01_Missed_Call_1_Email</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send Missed Call #1 Email</description>
        <formula>AND ( Send_Email_Notification__c = &quot;Missed Call Email&quot;, ISPICKVAL (  Select_Missed_Call_Email__c , &quot;01 Missed Call#1 Email&quot; ),  Lead_Division_Custom__c !=  $Label.AEE_label )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Email - Missed Call%232</fullName>
        <actions>
            <name>Send_02_Missed_Call_2_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Missed_Call_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_02_Missed_Call_2_Email</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send Missed Call #2 Email</description>
        <formula>AND ( Send_Email_Notification__c = &quot;Missed Call Email&quot;, ISPICKVAL (  Select_Missed_Call_Email__c , &quot;02 Missed Call#2 Email&quot; ), Lead_Division_Custom__c !=  $Label.AEE_label  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Email - Missed Call%233</fullName>
        <actions>
            <name>Send_03_Missed_Call_3_Final_email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Missed_Call_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_03_Missed_Call_3_Email</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Send Missed Call #3 Email</description>
        <formula>AND ( Send_Email_Notification__c = &quot;Missed Call Email&quot;, ISPICKVAL (  Select_Missed_Call_Email__c , &quot;03 Missed Call#3 - Final email&quot; ), Lead_Division_Custom__c !=  $Label.AEE_label  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Email - Susan Kraemer Leads</fullName>
        <actions>
            <name>Send_Susan_Kraemer_Leads</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Select_Missed_Call_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Send_Email_Notification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Sent_Susan_Kraemer_Leads</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <description>Send Susan Kraemer Leads Email</description>
        <formula>AND ( Send_Email_Notification__c = &quot;Missed Call Email&quot;, ISPICKVAL (  Select_Missed_Call_Email__c , &quot;Susan Kraemer Leads&quot; ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Origin %3D SunRun</fullName>
        <actions>
            <name>Lead_Origin_SunRun</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets &quot;Lead Origin = SunRun&quot; for any lead that is created</description>
        <formula>isblank( TEXT(Lead_Origin__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Status to Converted</fullName>
        <actions>
            <name>Lead_Status_to_Converted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead Wait to 1st Attempt</fullName>
        <actions>
            <name>Lead_Wait_to_1st_Attempt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>notEqual</operation>
            <value>Created,Open</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Lead_SquareFootage</fullName>
        <actions>
            <name>Lead_SquareFootage_0</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Square_footage__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Default Square Footage to 0</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead_UsageOption%3DBasic</fullName>
        <actions>
            <name>Lead_UsageOption_Basic</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3 OR 4) AND (5 OR 6)</booleanFilter>
        <criteriaItems>
            <field>Lead.Utility_Company__c</field>
            <operation>equals</operation>
            <value>PG&amp;E</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Utility_Company__c</field>
            <operation>equals</operation>
            <value>SMUD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Utility_Company__c</field>
            <operation>equals</operation>
            <value>SCE</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Utility_Company__c</field>
            <operation>equals</operation>
            <value>SDG&amp;E</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Usage_Option__c</field>
            <operation>equals</operation>
            <value>NA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Usage_Option__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sets Usageoption on Lead to &quot;Basic&quot; whenever Lead is Created</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Lead_UsageOption%3DNA</fullName>
        <actions>
            <name>Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND 3 AND 4)</booleanFilter>
        <criteriaItems>
            <field>Lead.Utility_Company__c</field>
            <operation>notEqual</operation>
            <value>PG&amp;E</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Utility_Company__c</field>
            <operation>notEqual</operation>
            <value>SMUD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Utility_Company__c</field>
            <operation>notEqual</operation>
            <value>SCE</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Utility_Company__c</field>
            <operation>notEqual</operation>
            <value>SDG&amp;E</value>
        </criteriaItems>
        <description>Default Usage Option To NA if utility company is not equal to PG&amp;E/SMUD/SCE/SDG&amp;E</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify lead owner of newly assigned lead</fullName>
        <actions>
            <name>Urgent_Open_Lead</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>(ISNEW()&amp;&amp; (CreatedById != OwnerId ) )  &amp;&amp;  NOT(  ISPICKVAL(Channel__c, &quot;Partner&quot;))  &amp;&amp;   NOT(  ISPICKVAL(Lead_Type__c,&quot;Partner&quot;)) ||  (ISCHANGED(OwnerId) &amp;&amp; ISPICKVAL( Status , &apos;Follow Up Needed&apos;) &amp;&amp; Future_Contact_Date__c &lt; Today() ) &amp;&amp;  NOT(  ISPICKVAL(Channel__c, &quot;Partner&quot;))   &amp;&amp;   NOT(  ISPICKVAL(Lead_Type__c,&quot;Partner&quot;)) ||  ((CreatedById = &apos;00560000001OMoo&apos;) &amp;&amp; (CreatedById = LastModifiedById)) &amp;&amp; NOT(ISPICKVAL( Channel__c ,&apos;Partner&apos;))&amp;&amp;(NOT(ISPICKVAL(Custom_Lead_Source__c,&apos;Partner: Legacy&apos;))&amp;&amp;  NOT( External_Source__c = &quot;SUNRUN SOUTH&quot;))  &amp;&amp;   NOT(  ISPICKVAL(Lead_Type__c,&quot;Partner&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Install Branch for Install Partner Sunrun</fullName>
        <actions>
            <name>Update_Install_Branch</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(Install_Partner__c  &lt;&gt;  null,      Install_Partner__c  &lt;&gt;  $Label.Sunrun_Inc_Id)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Lead Created Date</fullName>
        <actions>
            <name>PopulateLeadCreatedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Lead_Created_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Auto-populated &quot;lead created date&quot; from &quot;created by&quot; field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Master Lead Source%3A Organic Search</fullName>
        <actions>
            <name>Master_Lead_Source_Organic_Search</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>contains</operation>
            <value>Search Engine</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>notContain</operation>
            <value>Adwords</value>
        </criteriaItems>
        <description>Populates the field &quot;Master Lead Source&quot; with Organic Search</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Sales Rep email and Phone</fullName>
        <actions>
            <name>Update_Sales_Rep_Email_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sales_Rep_Phone_Lead</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISPICKVAL( SalesRep__r.UserType, &quot;PowerPartner&quot; ), NOT (ISNULL(SalesRep__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate channel %26 lead source for PP Leads</fullName>
        <actions>
            <name>Update_PP_Channel</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_PP_Lead_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL($User.UserType, &apos;PowerPartner&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Send Sierra Club Welcome Email</fullName>
        <actions>
            <name>Sierra_Club_Welcome_email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 or 4) AND 3</booleanFilter>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Partner: Sierra Club</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Monthly_Electricity_Bill__c</field>
            <operation>greaterOrEqual</operation>
            <value>85</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.State</field>
            <operation>equals</operation>
            <value>CA,AZ,MA,NJ,PA,CO,HI,OR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Monthly_Electricity_Bill__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sends a welcome email to each Sierra Club lead</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set Lead Status to Open</fullName>
        <actions>
            <name>Set_Lead_Status_to_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(ISPICKVAL(Lead_Status__c,&quot;&quot; ),  ISPICKVAL(Status, &quot;Created&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Share with Sunrun</fullName>
        <actions>
            <name>Share_with_Sunrun</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR (Sales_Partner__r.Name = &quot;Sunrun&quot;, Sales_Partner__r.Name = &quot;&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sierra Club Low Bill</fullName>
        <actions>
            <name>Sierra_club_low_bill_email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_Why_unqualified_to_low_bills</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Change_lead_status_to_unqualified</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Check_box_for_Auto_Unqualified</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Partner: Sierra Club</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Monthly_Electricity_Bill__c</field>
            <operation>lessThan</operation>
            <value>85</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Called_In__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>For Sierra Club leads, sends low bill email, changes status to unqualified, changes why unqualified to low bill</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Sunrun%2Ecom Leads Default</fullName>
        <actions>
            <name>Update_Channel</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Lead_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ($User.Username = &quot;sunruncrm@sunrunhome.com&quot;, ISPICKVAL ( LeadSource, &quot;Referral - Customer Portal 2.0&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Sync Callback Disposition for inContact trigger 1</fullName>
        <actions>
            <name>DO_NOT_CALL_BACK</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.DoNotCall</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sync Callback Disposition for inContact trigger 1</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sync Callback Disposition for inContact trigger 2</fullName>
        <actions>
            <name>Setting_to_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.DoNotCall</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Sync Callback Disposition for inContact trigger 2</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Lead status to Closed Lost</fullName>
        <actions>
            <name>Update_Lead_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Lead_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Email</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Phone</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Alternate_Phone__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.MobilePhone</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Lead to Invoke Lookup Callout</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.External_Sync_InProgress__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.External_Sync_System__c</field>
            <operation>equals</operation>
            <value>Home Depot</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.IsConverted</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This WF will update field Extenal Sync Status on Lead which will invoke the HD lookup callout using the trigger code</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Sync_Status_Field</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.Trigger_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Web Lead Round Robin 2 - Karen Cleland</fullName>
        <actions>
            <name>Web_Lead_Email_Alert_Karen_Cleland</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Referral - Customer Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>equals</operation>
            <value>developer account</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Round_Robin_ID__c</field>
            <operation>equals</operation>
            <value>2</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Web Lead Round Robin 3 - Ben Kaplan</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Referral - Customer Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>equals</operation>
            <value>developer account</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Round_Robin_ID__c</field>
            <operation>equals</operation>
            <value>3</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Sent_01_Missed_Call_1_Email</fullName>
        <assignedToType>owner</assignedToType>
        <description>01 Missed Call#1 Email was sent to this lead.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent 01 Missed Call#1 Email</subject>
    </tasks>
    <tasks>
        <fullName>Sent_01_Missed_Call_1_Email_Online_Lead_Company</fullName>
        <assignedToType>owner</assignedToType>
        <description>01 Missed Call#1 Email Online Lead Company was sent to this lead.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent 01 Missed Call #1 Email Online Lead Company</subject>
    </tasks>
    <tasks>
        <fullName>Sent_02_Missed_Call_2_Email</fullName>
        <assignedToType>owner</assignedToType>
        <description>02 Missed Call#2 Email was sent to this lead.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent 02 Missed Call#2 Email</subject>
    </tasks>
    <tasks>
        <fullName>Sent_03_Missed_Call_3_Email</fullName>
        <assignedToType>owner</assignedToType>
        <description>03 Missed Call#3 Email was sent to this lead.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent 03 Missed Call#3 Email</subject>
    </tasks>
    <tasks>
        <fullName>Sent_Susan_Kraemer_Leads</fullName>
        <assignedToType>owner</assignedToType>
        <description>Susan Kraemer Leads Email was sent to this lead.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Sent Susan Kraemer Leads</subject>
    </tasks>
</Workflow>
