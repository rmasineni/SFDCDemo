<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CSLB_Application_Received</fullName>
        <description>CSLB Application Received</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Special_Lead_Source/CSLBApplicationReceived</template>
    </alerts>
    <alerts>
        <fullName>Cancel_CSLB_Application</fullName>
        <ccEmails>SunRunHelp@sunrun.com</ccEmails>
        <description>Cancel CSLB Application</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Cancel_CSLB_Application</template>
    </alerts>
    <alerts>
        <fullName>Deactivate_Not_Accredited_Contact</fullName>
        <description>Deactivate Not Accredited Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Salesman_Certification_Account_De_activated</template>
    </alerts>
    <alerts>
        <fullName>Deactive_Contact_Email_V2</fullName>
        <description>Deactive Contact Email V2</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Salesman_Certification_Account_De_activated</template>
    </alerts>
    <alerts>
        <fullName>Design_tool_access_requested</fullName>
        <ccEmails>sunrunhelp@sunrun.com</ccEmails>
        <description>Design tool access requested</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Sales_Partner_Concierge/Design_Tool_Access_Requested</template>
    </alerts>
    <alerts>
        <fullName>How_to_Sell_Sunrun_email_to_Sales_Rep_on_getting_access_to_Proposal_Tool</fullName>
        <description>How to Sell Sunrun email to Sales Rep on getting access to Proposal Tool</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/How_to_Start_Selling_Sunrun</template>
    </alerts>
    <alerts>
        <fullName>New_Contact_Webinar_and_ID</fullName>
        <description>New Contact - Webinar and ID</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Webinar_and_ID</template>
    </alerts>
    <alerts>
        <fullName>Proposal_Tool_access_requested</fullName>
        <ccEmails>sunrunhelp@sunrun.com</ccEmails>
        <description>Proposal Tool access requested</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Sales_Partner_Concierge/Prop_Tool_Access_Requested</template>
    </alerts>
    <alerts>
        <fullName>Reactivate_Contact_Email_V2</fullName>
        <description>Reactivate Contact Email V2</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Salesman_Certification_Account_Activated</template>
    </alerts>
    <alerts>
        <fullName>Reactivate_Not_Accredited_Contact</fullName>
        <description>Reactivate Not Accredited Contact</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Salesman_Certification_Account_Activated</template>
    </alerts>
    <alerts>
        <fullName>Retaining_deactivating_Sunrun_HIS_License_for_when_partner_contact_becomes_inact</fullName>
        <description>Retaining/deactivating Sunrun HIS License for when partner contact becomes inactive partner employee</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Special_Lead_Source/Contact_deactivation_email</template>
    </alerts>
    <alerts>
        <fullName>SendAppointmentEmail</fullName>
        <description>SendAppointmentEmail</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Appointment_Scheduled</template>
    </alerts>
    <fieldUpdates>
        <fullName>Accreditation_Period_End_Date</fullName>
        <field>Accreditation_period_end_date__c</field>
        <formula>TODAY() + 14</formula>
        <name>Accreditation Period End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Accreditation_Period_End_Date_Blank</fullName>
        <field>Accreditation_period_end_date__c</field>
        <name>Accreditation Period End Date Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Accreditation_Period_Start_Date</fullName>
        <field>Accreditation_period_start_date__c</field>
        <formula>TODAY()</formula>
        <name>Accreditation Period Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Accreditation_Period_Start_Date_Blank</fullName>
        <field>Accreditation_period_start_date__c</field>
        <name>Accreditation Period Start Date Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contact_status_update_1</fullName>
        <description>update contact status based on whether they have seen a proposal</description>
        <field>Contact_Status__c</field>
        <literalValue>Has Proposal</literalValue>
        <name>Contact status update 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_EDP_Go_live_date</fullName>
        <field>EDP_Go_Live_Date__c</field>
        <formula>Account.EDP_Go_Live_Date__c</formula>
        <name>Populate EDP Go-live date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_registration_type_when_sells_in_home</fullName>
        <field>Sales_Registration_Type__c</field>
        <literalValue>CA HIS</literalValue>
        <name>Set registration type when sells in home</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <flowActions>
        <fullName>Contact_Updates</fullName>
        <description>When a new User record is created, a trigger automatically creates a Contact record. This Flow updates the new Contact record with additional details and permissions for BrightPath.</description>
        <flow>Contact_Update</flow>
        <flowInputs>
            <name>ContactId</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>UserDivision</name>
            <value>{!Sunrun_User__r.Division}</value>
        </flowInputs>
        <flowInputs>
            <name>UserProfileName</name>
            <value>{!Sunrun_User__r.Profile.Name}</value>
        </flowInputs>
        <flowInputs>
            <name>UserTitle</name>
            <value>{!Sunrun_User__r.Title}</value>
        </flowInputs>
        <label>Contact Updates</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>CSLB Application Received Email</fullName>
        <actions>
            <name>CSLB_Application_Received</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Application_Status__c</field>
            <operation>equals</operation>
            <value>Received</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cancel CSLB Application %28Careful%3A Cases Created in Prod%29</fullName>
        <actions>
            <name>Cancel_CSLB_Application</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>(  ISPICKVAL(Application_Status__c, &quot;Submitted&quot;)  ||  ISPICKVAL(Application_Status__c, &quot;Resubmitted&quot;)  ||  ISPICKVAL( Application_Status__c , &quot;Approved&quot;)  )   &amp;&amp;   (  PRIORVALUE( active__c ) = True  &amp;&amp;  active__c = False  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deactive Contact Email</fullName>
        <actions>
            <name>Deactivate_Not_Accredited_Contact</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>PRIORVALUE( Proposal_Tool_Access__c )!=null&amp;&amp; ISPICKVAL(Proposal_Tool_Access__c,&apos;&apos;)&amp;&amp;
 NOT(ISPICKVAL(Accreditation_Status__c, &apos;Accredited&apos;))&amp;&amp;NOT(ISPICKVAL(Accreditation_Status__c, &apos;Not a salesperson - accreditation not needed&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deactive Contact Email V2</fullName>
        <actions>
            <name>Deactive_Contact_Email_V2</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>PRIORVALUE( Proposal_Tool_Access__c )!=null&amp;&amp; ISPICKVAL(Sells_Sunrun__c ,&apos;Yes&apos;)&amp;&amp;ISPICKVAL(Proposal_Tool_Access__c,&apos;&apos;)&amp;&amp;  NOT(ISPICKVAL(Professional_Certification__c, &apos;Yes&apos;))&amp;&amp;NOT(ISPICKVAL(Professional_Certification__c, &apos;NA&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Design Tool Access Requested</fullName>
        <actions>
            <name>Design_tool_access_requested</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Design_Tool_Access__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Proposal_Tool_Access__c</field>
            <operation>equals</operation>
            <value>Granted</value>
        </criteriaItems>
        <description>Email Partner Concierge to let them know design tool access has been requested</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email to deactivated contact and task to Partner Concierge</fullName>
        <actions>
            <name>Retaining_deactivating_Sunrun_HIS_License_for_when_partner_contact_becomes_inact</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Application_Status__c</field>
            <operation>equals</operation>
            <value>Submitted,Resubmitted,Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Initiate_cancellation_process</name>
                <type>Task</type>
            </actions>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Execute Contact Flow</fullName>
        <actions>
            <name>Contact_Updates</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Sunrun_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>Employee</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.EDP_Go_Live_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.AccountName</field>
            <operation>equals</operation>
            <value>Sunrun</value>
        </criteriaItems>
        <description>When a new User record is created, a trigger automatically creates a Contact record. This Flow updates the new Contact record with additional details and permissions for BrightPath.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>How to Sell Sunrun email to Sales Rep</fullName>
        <actions>
            <name>How_to_Sell_Sunrun_email_to_Sales_Rep_on_getting_access_to_Proposal_Tool</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>How_to_sell_Sunrun_email_sent_to_partner_contact</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Proposal_Tool_Access__c</field>
            <operation>equals</operation>
            <value>Granted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Sells_Sunrun__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Contacts - How to Sell Sunrun</fullName>
        <actions>
            <name>New_Contact_Webinar_and_ID</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>8/6/2012</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Sells_Sunrun__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>[SFDC-394] - Partner Concierge - All new contacts created &gt; 2012.08.06 will receive the &quot;How to Sell Sunrun&quot; email template</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate EDP Go-live date</fullName>
        <actions>
            <name>Populate_EDP_Go_live_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.EDP_Go_Live_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Prop Tool Access Requested</fullName>
        <actions>
            <name>Proposal_Tool_access_requested</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Proposal_Tool_Access__c</field>
            <operation>equals</operation>
            <value>Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Sells_in_CA__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Notifies Partner Concierge when prop tool access is requested for reps who sell in home in CA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reactive Contact Email</fullName>
        <actions>
            <name>Reactivate_Not_Accredited_Contact</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND( 
NOT(ISPICKVAL(PRIORVALUE(Accreditation_Status__c),&quot;Accredited&quot;)), ISPICKVAL(Accreditation_Status__c,&quot;Accredited&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reactive Contact Email V2</fullName>
        <actions>
            <name>Reactivate_Contact_Email_V2</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(  NOT(ISPICKVAL(PRIORVALUE(Professional_Certification__c),&quot;Yes&quot;)), ISPICKVAL(Professional_Certification__c,&quot;Yes&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Remove accreditation dates when Sells SR %3D No</fullName>
        <actions>
            <name>Accreditation_Period_End_Date_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Accreditation_Period_Start_Date_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR (2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Contact.Sells_Sunrun__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Sells_Sunrun__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Application_Status__c</field>
            <operation>equals</operation>
            <value>Not Received</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SendAppointmentEmail</fullName>
        <active>true</active>
        <formula>Appointment_Date_Time__c - NOW() &gt; 1</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SendAppointmentEmail</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Contact.Appointment_Date_Time__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Up Accreditation Dates when Sells SR %3D Yes</fullName>
        <actions>
            <name>Accreditation_Period_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Accreditation_Period_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND 5 AND 6 AND 7) OR (1 AND 3 AND 4 AND 5 AND 6 AND 7)</booleanFilter>
        <criteriaItems>
            <field>Contact.Sells_Sunrun__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Sells_in_CA__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Sells_in_CA__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Application_Status__c</field>
            <operation>equals</operation>
            <value>Received</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Accreditation_Status__c</field>
            <operation>equals</operation>
            <value>Accreditation Pending</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Accreditation_period_start_date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Accreditation_period_end_date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set registration type when sells in home in ca %3D yes</fullName>
        <actions>
            <name>Set_registration_type_when_sells_in_home</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Sells_in_CA__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>How_to_sell_Sunrun_email_sent_to_partner_contact</fullName>
        <assignedTo>rmasineni@sunrunhome.com.prod</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Email &quot;How to sell Sunrun&quot; is sent to partner contact</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>How to sell Sunrun email sent to partner contact</subject>
    </tasks>
    <tasks>
        <fullName>Initiate_cancellation_process</fullName>
        <assignedTo>dlindsley@sunrunhome.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>On partner contact, if Application Status = Submitted or Resubmitted or Approved and if Active Employee is changed from True to False then set up a task to partner concierge (Sarah Grace) to initiate cancellation process 30 days after &quot;Active Employee&quot; is</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Initiate cancellation process</subject>
    </tasks>
</Workflow>
