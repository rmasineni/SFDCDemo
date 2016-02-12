<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FS_Customer_Survey_when_Dispatch_Findings_Approved</fullName>
        <description>FS Customer Survey when Dispatch Findings Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Customer_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>customercare@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CC_Do_Not_Use_Templates/FS_Customer_Survey</template>
    </alerts>
    <alerts>
        <fullName>FS_Dispatch_Cancel_Email</fullName>
        <description>FS Dispatch Cancel Email</description>
        <protected>false</protected>
        <recipients>
            <field>FS_Dispatch_To__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FS_Tickets/FS_Cancelled_Dispatch</template>
    </alerts>
    <alerts>
        <fullName>FS_Dispatch_Findings_Submitted</fullName>
        <description>FS Dispatch Findings Submitted</description>
        <protected>false</protected>
        <recipients>
            <field>FS_Dispatched_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>service@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CC_Do_Not_Use_Templates/FS_Dispatch_Findings_Submitted</template>
    </alerts>
    <alerts>
        <fullName>FS_Notify_Dispatch_Partner_about_a_new_FS_Dispatch</fullName>
        <description>FS Notify Dispatch Partner about a new FS Dispatch</description>
        <protected>false</protected>
        <recipients>
            <field>FS_Dispatch_To__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>service@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>FS_Tickets/FS_New_Dispatch_Notification</template>
    </alerts>
    <alerts>
        <fullName>FS_Notify_Dispatch_Rejected</fullName>
        <description>FS Notify Dispatch Partner about Rejected Findings</description>
        <protected>false</protected>
        <recipients>
            <field>FS_Dispatch_To__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>service@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CC_Do_Not_Use_Templates/FS_Findings_Rejected</template>
    </alerts>
    <alerts>
        <fullName>FS_Notify_Dispatched_By_that_the_FS_Dispatch_was_Accepted</fullName>
        <description>Notify Dispatched By that the FS Dispatch was Accepted</description>
        <protected>false</protected>
        <recipients>
            <field>FS_Dispatched_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>service@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CC_Do_Not_Use_Templates/FS_Dispatch_Accepted_by_Partner</template>
    </alerts>
    <alerts>
        <fullName>FS_Notify_Dispatched_By_that_the_FS_Dispatch_was_Declined</fullName>
        <description>Notify Dispatched By that the FS Dispatch was Declined</description>
        <protected>false</protected>
        <recipients>
            <field>FS_Dispatched_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>service@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CC_Do_Not_Use_Templates/FS_Dispatch_Declined_by_Partner</template>
    </alerts>
    <alerts>
        <fullName>X7DaysNoAction</fullName>
        <description>7DaysNoAction</description>
        <protected>false</protected>
        <recipients>
            <field>FS_Dispatch_To__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>FS_Tickets/FS_Response_Needed</template>
    </alerts>
    <fieldUpdates>
        <fullName>FS_Clear_Accept_Dispatch</fullName>
        <description>Clears the FS Accept Dispatch checkbox</description>
        <field>FS_Accept_Dispatch__c</field>
        <literalValue>0</literalValue>
        <name>FS Clear Accept Dispatch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Clear_All_FS_Ckboxes</fullName>
        <description>Clears the FS Decline Dispatch checkbox</description>
        <field>FS_Decline_Dispatch__c</field>
        <literalValue>0</literalValue>
        <name>FS Clear Decline Dispatch</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Clear_Reject_Findings</fullName>
        <description>Clears FS Reject Findings</description>
        <field>FS_Reject_Findings__c</field>
        <literalValue>0</literalValue>
        <name>FS Clear Reject Findings</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Clear_Submit_Findings</fullName>
        <description>Clears the FS Submit Findings checkbox</description>
        <field>FS_Submit_Findings__c</field>
        <literalValue>0</literalValue>
        <name>FS Clear Submit Findings</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Dispatch_State_to_Dispatch_Accepted</fullName>
        <description>Set value of FS Dispatch State to Dispatch Accepted</description>
        <field>FS_Dispatch_State__c</field>
        <literalValue>Dispatch Accepted</literalValue>
        <name>FS Dispatch State to Dispatch Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Dispatch_State_to_Dispatch_Declined</fullName>
        <description>Set value of FS Dispatch State to Dispatch Declined</description>
        <field>FS_Dispatch_State__c</field>
        <literalValue>Dispatch Declined</literalValue>
        <name>FS Dispatch State to Dispatch Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Dispatch_State_to_Dispatched</fullName>
        <description>Set value of FS Dispatch State to Dispatched</description>
        <field>FS_Dispatch_State__c</field>
        <literalValue>Dispatched</literalValue>
        <name>FS Dispatch State to Dispatched</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Dispatch_State_to_Findings_Approved</fullName>
        <description>Set value of FS Dispatch State to Dispatch Findings Approved</description>
        <field>FS_Dispatch_State__c</field>
        <literalValue>Dispatch Findings Approved</literalValue>
        <name>FS Dispatch State to Findings Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Dispatch_State_to_Findings_Rejected</fullName>
        <description>Set value of FS Dispatch State to Dispatch Findings Rejected</description>
        <field>FS_Dispatch_State__c</field>
        <literalValue>Dispatch Findings Rejected</literalValue>
        <name>FS Dispatch State to Findings Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Dispatch_State_to_Findings_Reported</fullName>
        <description>Set value of FS Dispatch State to Dispatch Findings Reported</description>
        <field>FS_Dispatch_State__c</field>
        <literalValue>Dispatch Findings Reported</literalValue>
        <name>FS Dispatch State to Findings Reported</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Populate_Access_Info</fullName>
        <description>Updates FS Access instructions with the address of the Gen Asset, plus whateever was typed in by the user.</description>
        <field>FS_Access_Info__c</field>
        <formula>&quot;CUSTOMER: &quot; &amp;  TRIM( FS_Generation_Asset__r.Customer_Contact__r.FirstName &amp; &quot; &quot; &amp; FS_Generation_Asset__r.Customer_Contact__r.LastName ) &amp; 
&quot;    PHONE: &quot; &amp;  FS_Generation_Asset__r.Customer_Contact__r.Phone  &amp; 
&quot;    EMAIL: &quot; &amp;   BLANKVALUE(FS_Generation_Asset__r.Customer_Contact__r.Email, &quot;** none **&quot;)  &amp; 
&quot;    ADDRESS: &quot; &amp;  FS_Generation_Asset__r.Home_Address__c &amp; &quot;, &quot; &amp; FS_Generation_Asset__r.City__c &amp; &quot;, &quot; &amp;  FS_Generation_Asset__r.State__c &amp; 
IF( LEN( FS_Access_Info__c )&gt;0 , &quot; ** ADDN&apos;L ACCESS INFO: &quot; &amp;  FS_Access_Info__c , &quot;&quot;)</formula>
        <name>FS Populate Access Info</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Populate_Access_Info_on_SC</fullName>
        <field>FS_Access_Info__c</field>
        <formula>&quot;CUSTOMER: &quot; &amp; TRIM(  FS_Service_Contract__r.Contact.FirstName  &amp; &quot; &quot; &amp; FS_Service_Contract__r.Contact.LastName ) &amp; 
&quot; PHONE: &quot; &amp;  FS_Service_Contract__r.Contact.Phone   &amp; 
&quot; EMAIL: &quot; &amp; BLANKVALUE(FS_Service_Contract__r.Customer_Email__c, &quot;** none **&quot;) &amp; 
&quot; ADDRESS: &quot; &amp;  FS_Service_Contract__r.Home_Address__c  &amp; &quot;, &quot; &amp;  FS_Service_Contract__r.City__c  &amp; &quot;, &quot; &amp;  FS_Service_Contract__r.State__c  &amp; 
IF( LEN( FS_Access_Info__c )&gt;0 , &quot; ** ADDN&apos;L ACCESS INFO: &quot; &amp; FS_Access_Info__c , &quot;&quot;)</formula>
        <name>FS Populate Access Info on SC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Set_Selected_Partner_Name</fullName>
        <description>Sets the value of FS Selected Partner Name to the Account Name of FS Dispatch Partner</description>
        <field>FS_Selected_Partner_Name__c</field>
        <formula>FS_Dispatch_Partner__r.Name</formula>
        <name>FS Set Selected Partner Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Stamp_Dispatched_Date</fullName>
        <description>Update value of FS Time Dispatched</description>
        <field>FS_Time_Dispatched__c</field>
        <formula>NOW()</formula>
        <name>FS Stamp Time Dispatched</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Stamp_Findings_Approved</fullName>
        <description>Updates FS Time Approved with current date and time</description>
        <field>FS_Time_Approved__c</field>
        <formula>NOW()</formula>
        <name>FS Stamp Findings Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Stamp_Findings_Rejected</fullName>
        <description>Updates FS Time Rejected with current date and time</description>
        <field>FS_Time_Rejected__c</field>
        <formula>NOW()</formula>
        <name>FS Stamp Findings Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Stamp_Findings_Reported</fullName>
        <description>Update FS Time Submitted to current date and time</description>
        <field>FS_Time_Submitted__c</field>
        <formula>NOW()</formula>
        <name>FS Stamp Findings Reported</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Stamp_First_Submit</fullName>
        <description>Stamps the time when the Submit Findings checkbox is checked the first time.</description>
        <field>FS_First_Submit_Time__c</field>
        <formula>IF(ISNULL(PRIORVALUE(  FS_First_Submit_Time__c )),NOW(),PRIORVALUE( FS_First_Submit_Time__c  ) )</formula>
        <name>FS Stamp First Submit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Stamp_Time_Accepted</fullName>
        <description>Update FS Time Accepted with current time</description>
        <field>FS_Time_Accepted__c</field>
        <formula>NOW()</formula>
        <name>FS Stamp Time Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FS_Stamp_Time_Declined</fullName>
        <description>Update FS Time Declined with current date/time</description>
        <field>FS_Time_Declined__c</field>
        <formula>NOW()</formula>
        <name>FS Stamp Time Declined</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Customer_Contact_Email_field</fullName>
        <field>Customer_Contact_Email__c</field>
        <formula>FS_Generation_Asset__r.Customer_Contact__r.Email</formula>
        <name>Populate &quot;Customer Contact: Email&quot; field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Customer_Contact_Email_on_SC</fullName>
        <field>Customer_Contact_Email__c</field>
        <formula>FS_Service_Contract__r.Contact.Email</formula>
        <name>Populate &quot;Customer Contact: Email&quot; on SC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Selected_Partner_Name_update</fullName>
        <field>FS_Selected_Partner_Name__c</field>
        <formula>FS_Dispatch_Partner__r.Name</formula>
        <name>Selected Partner Name update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EmailPartner7Days</fullName>
        <active>true</active>
        <criteriaItems>
            <field>FS_Dispatch__c.FS_Accept_Dispatch__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>FS_Dispatch__c.FS_Decline_Dispatch__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>FS_Dispatch__c.CreatedDate</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>FS Accept the Dispatch</fullName>
        <actions>
            <name>FS_Clear_All_FS_Ckboxes</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Dispatch_State_to_Dispatch_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Stamp_Time_Accepted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sends out notification and updates State when the partner accepts the Dispatch</description>
        <formula>PRIORVALUE( FS_Accept_Dispatch__c ) = FALSE &amp;&amp; FS_Accept_Dispatch__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FS Approve Findings</fullName>
        <actions>
            <name>FS_Dispatch_State_to_Findings_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Stamp_Findings_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When the Findings for a Dispatch is approved</description>
        <formula>PRIORVALUE( FS_Approve_Findings__c ) = FALSE &amp;&amp; FS_Approve_Findings__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FS Customer Survey when Dispatch Findings Approved</fullName>
        <actions>
            <name>FS_Customer_Survey_when_Dispatch_Findings_Approved</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>BSKY-2252 - Email template FS Customer Survey V2, to be sent to the Customer when the dispatch state goes from Dispatch Findings Reported to Dispatch Findings Approved.</description>
        <formula>AND(  ISPICKVAL(PRIORVALUE(FS_Dispatch_State__c),&quot;Dispatch Findings Reported&quot;),  ISPICKVAL(FS_Dispatch_State__c,&quot;Dispatch Findings Approved&quot;),  Do_Not_Send_Survey__c = FALSE,  NOT(ISBLANK(Customer_Contact_Email__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FS Decline the Dispatch</fullName>
        <actions>
            <name>FS_Notify_Dispatched_By_that_the_FS_Dispatch_was_Declined</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FS_Clear_Accept_Dispatch</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Dispatch_State_to_Dispatch_Declined</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Stamp_Time_Declined</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Partner declines the dispatch: update Dispatch State, send notification, update time stamp</description>
        <formula>PRIORVALUE( FS_Decline_Dispatch__c ) = FALSE &amp;&amp; FS_Decline_Dispatch__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FS Dispatch Cancel Email</fullName>
        <actions>
            <name>FS_Dispatch_Cancel_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FS_Dispatch__c.FS_Dispatch_State__c</field>
            <operation>equals</operation>
            <value>Dispatch Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FS Dispatch Initial Values</fullName>
        <actions>
            <name>FS_Populate_Access_Info</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates various FS Dispatch values when a new record is created for certain fields, if they are left blank</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FS Dispatch Initial Values on SC</fullName>
        <actions>
            <name>FS_Populate_Access_Info_on_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates various FS Dispatch values when a new record is created for certain fields, if they are left blank</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FS Dispatch to Partner</fullName>
        <actions>
            <name>FS_Notify_Dispatch_Partner_about_a_new_FS_Dispatch</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FS_Clear_Accept_Dispatch</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Clear_All_FS_Ckboxes</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Clear_Reject_Findings</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Clear_Submit_Findings</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Dispatch_State_to_Dispatched</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Stamp_Dispatched_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When this goes from unchecked to checked, change the Dispatch State to &quot;Dispatched&quot; and send a notification email to Dispatch partner</description>
        <formula>PRIORVALUE( FS_Dispatch_To_Partner__c ) = FALSE  &amp;&amp;  FS_Dispatch_To_Partner__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FS Reject Findings</fullName>
        <actions>
            <name>FS_Notify_Dispatch_Rejected</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FS_Clear_Submit_Findings</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Dispatch_State_to_Findings_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Stamp_Findings_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When FS Reject Findings goes from unchecked to checked</description>
        <formula>PRIORVALUE( FS_Reject_Findings__c ) = FALSE &amp;&amp;  FS_Reject_Findings__c  = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FS Set Selected Partner Name</fullName>
        <actions>
            <name>FS_Set_Selected_Partner_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the field FS Selected Partner so that the record can be shared using the sharing formula</description>
        <formula>AND(Install_Partner__c != &apos;Roof Diagnostics&apos;, Install_Partner__c != &apos;Akeena Solar&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>FS Submit Findings</fullName>
        <actions>
            <name>FS_Dispatch_State_to_Findings_Reported</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Stamp_Findings_Reported</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FS_Stamp_First_Submit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When FS Submit Findings goes from checked to unchecked</description>
        <formula>PRIORVALUE( FS_Submit_Findings__c ) = FALSE &amp;&amp; FS_Submit_Findings__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate %22Customer Contact%3A Email%22 field</fullName>
        <actions>
            <name>Populate_Customer_Contact_Email_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( ISCHANGED( FS_Generation_Asset__c ), ISBLANK ( Customer_Contact_Email__c), AND(ISCHANGED(  FS_Dispatch_State__c  ), ISBLANK ( Customer_Contact_Email__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate %22Customer Contact%3A Email%22 field on SC</fullName>
        <actions>
            <name>Populate_Customer_Contact_Email_on_SC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(Customer_Contact_Email__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Selected Partner Name</fullName>
        <actions>
            <name>Selected_Partner_Name_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( Install_Partner__c = &apos;Roof Diagnostics&apos;, Install_Partner__c = &apos;Akeena Solar&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
