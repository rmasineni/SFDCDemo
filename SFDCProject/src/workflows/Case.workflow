<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Email_to_Ops_that_MP_Needs_Approval</fullName>
        <description>Alert Email to Ops that MP Needs Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>dsg@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Needs_Approval</template>
    </alerts>
    <alerts>
        <fullName>Alert_Email_to_Ops_that_MP_Needs_Approval2</fullName>
        <description>Ops Email Alert for Milestone Proofs Needing Approval - HelioPower</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Needs_Approval</template>
    </alerts>
    <alerts>
        <fullName>Alert_HelioPower_AR_that_Milestone_Proof_Approval_Request_has_been_Denied</fullName>
        <ccEmails>dkraack@heliopower.com</ccEmails>
        <description>Alert HelioPower AR that Milestone Proof Approval Request has been Denied</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Denied</template>
    </alerts>
    <alerts>
        <fullName>Alert_User_that_Milestone_Proof_Approval_Request_has_been_Denied</fullName>
        <description>Alert User that Milestone Proof Approval Request has been Denied</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Denied</template>
    </alerts>
    <alerts>
        <fullName>Alert_Verengo_Rebates_that_Milestone_Proof_Approval_Request_has_been_Denied</fullName>
        <ccEmails>rebates@goverengo.com</ccEmails>
        <description>Alert Verengo Rebates that Milestone Proof Approval Request has been Denied</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Denied</template>
    </alerts>
    <alerts>
        <fullName>Customer_Care_Escalation_Notification</fullName>
        <description>Customer Care Escalation Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>jtalcott@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Care_Templates/New_Email_in_Escalation_Queue</template>
    </alerts>
    <alerts>
        <fullName>Email_Account_Manager_when_Case_for_Partner_Created</fullName>
        <description>Email Account Manager when Case for Partner Created</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address_of_Account_Manager__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Partner_Concierge_New_Case_for_your_Partner</template>
    </alerts>
    <alerts>
        <fullName>Email_Account_Manager_when_Case_for_their_Partner_is_Closed</fullName>
        <description>Email Account Manager when Case for their Partner is Closed</description>
        <protected>false</protected>
        <recipients>
            <field>Email_Address_of_Account_Manager__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Partner_Concierge_Case_for_your_Partner_has_been_Closed</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_to_HelioPower_AR_and_Partner_User_Notifying_that_Milestone_Proof_has</fullName>
        <ccEmails>dkraack@heliopower.com</ccEmails>
        <description>Email Alert to HelioPower AR and User Notifying that Milestone Proof has been Approved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_to_Partner_User_Notifying_that_Milestone_Proof_has_been_Approved</fullName>
        <description>Email Alert to Partner User Notifying that Milestone Proof has been Approved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_to_Verengo_Rebates_and_Partner_User_Notifying_that_Milestone_Proof_h</fullName>
        <ccEmails>rebates@goverengo.com</ccEmails>
        <description>Email Alert to Verengo Rebates and User Notifying that Milestone Proof has been Approved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Approved</template>
    </alerts>
    <alerts>
        <fullName>Email_Case_Contact_when_Partner_Case_Created</fullName>
        <description>Email Case Contact when Partner Case Created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>partnerportal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/Partner_Help_New_Case_Response_to_Contact</template>
    </alerts>
    <alerts>
        <fullName>Email_Case_Contact_when_Partner_Concierge_Case_Created</fullName>
        <description>Email Case Contact when Partner Concierge Case Created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Email_Address_of_Account_Manager__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Partner_Concierge_New_Case_Response_to_Contact</template>
    </alerts>
    <alerts>
        <fullName>Email_Verengo_Account_Manager_when_Case_for_Partner_Created</fullName>
        <description>Email Verengo Account Manager when Case for Partner Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>jamesond@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jasonl@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Partner_Concierge_New_Case_for_your_Partner</template>
    </alerts>
    <alerts>
        <fullName>FS_Email_Creator_of_Case_Closure</fullName>
        <description>Email Creator of Case Closure</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CC_Do_Not_Use_Templates/FS_Ticket_Case_Was_Closed</template>
    </alerts>
    <alerts>
        <fullName>Milestone_Proof_Denied_Email_Alert</fullName>
        <description>Milestone Proof Denied Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Denied</template>
    </alerts>
    <alerts>
        <fullName>Notification_of_System_Removal_Status_FS</fullName>
        <description>Notification of System Removal Status_FS</description>
        <protected>false</protected>
        <recipients>
            <recipient>helen.wang@sunrun.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>customercare@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Customer_Care_Templates/New_Redeployment</template>
    </alerts>
    <alerts>
        <fullName>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_Arco_Energy</fullName>
        <description>Ops Email Alert for Milestone Proofs Needing Approval - Arco Energy</description>
        <protected>false</protected>
        <recipients>
            <recipient>rfederico@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Needs_Approval</template>
    </alerts>
    <alerts>
        <fullName>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_PetersenDean</fullName>
        <description>Ops Email Alert for Milestone Proofs Needing Approval - PetersenDean</description>
        <protected>false</protected>
        <recipients>
            <recipient>rfederico@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Needs_Approval</template>
    </alerts>
    <alerts>
        <fullName>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_Roof_Diagnostics</fullName>
        <description>Ops Email Alert for Milestone Proofs Needing Approval - Roof Diagnostics</description>
        <protected>false</protected>
        <recipients>
            <recipient>jmartyn@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Needs_Approval</template>
    </alerts>
    <alerts>
        <fullName>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_Trinity_Solar</fullName>
        <description>Ops Email Alert for Milestone Proofs Needing Approval - Trinity Solar</description>
        <protected>false</protected>
        <recipients>
            <recipient>egabriel@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Needs_Approval</template>
    </alerts>
    <alerts>
        <fullName>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_Verengo</fullName>
        <description>Ops Email Alert for Milestone Proofs Needing Approval - Verengo</description>
        <protected>false</protected>
        <recipients>
            <recipient>rfederico@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Milestone_Proofs/Milestone_Proof_Needs_Approval</template>
    </alerts>
    <alerts>
        <fullName>Partner_Concierge_Non_Urgent_Case_Heads_Up_to_Case_Contact</fullName>
        <description>Partner Concierge: Non-Urgent Case Heads Up to Case Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>sunrunhelp@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Partner_Concierge/Partner_Concierge_Non_urgent_Case_Heads_Up</template>
    </alerts>
    <alerts>
        <fullName>Partner_Help_Email_Case_Owner_when_Partner_Case_is_Created</fullName>
        <description>Partner Help Email Case Owner when Partner Case is Created</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partnerportal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/Partner_Help_New_Case_response_to_Case_Owner</template>
    </alerts>
    <alerts>
        <fullName>Partner_Help_Email_Case_Owner_when_case_is_closed_by_Partner</fullName>
        <description>Partner Help: Email Case Owner when case is closed by Partner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>partnerportal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/Partner_Help_Case_Closed_by_partner_user</template>
    </alerts>
    <alerts>
        <fullName>Partner_Help_Email_Creator_of_Case_Closure</fullName>
        <description>Partner Help: Email Creator of Case Closure</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>partnerportal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Case_Templates/Partner_Help_Case_Was_Closed</template>
    </alerts>
    <alerts>
        <fullName>You_Have_A_New_Message_from_Sunrun_Customer_Care</fullName>
        <description>You Have A New Message from Sunrun Customer Care</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Customer_Care_Templates/You_Have_a_New_Message_from_Customer_Care</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_Case_to_Partner_help_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Partner_Help</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Case to Partner help queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Close</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Case Close</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compensated_Modified_By</fullName>
        <field>Compensated_Modified_By__c</field>
        <formula>$User.FirstName + &apos; &apos; +  $User.LastName</formula>
        <name>Compensated Modified By</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Customer_Care_Escalations</fullName>
        <field>OwnerId</field>
        <lookupValue>Customer_Care_Escalations</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Customer Care Escalations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Documents_Emails</fullName>
        <field>OwnerId</field>
        <lookupValue>CustomerCareCases</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Documents Emails</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Escalation_Status</fullName>
        <field>Status</field>
        <literalValue>Escalated</literalValue>
        <name>Escalation Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Partner_Concierge</fullName>
        <description>Automatically Changes the Case Record Type to &quot;Partner Help&quot; when a Case record is moved into the Partner Concierge queue</description>
        <field>RecordTypeId</field>
        <lookupValue>Partner_Help</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Field Update - Partner Help</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Field_Update_Standard</fullName>
        <description>Updates the &quot;Case Record Type&quot; field to &quot;Standard&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>Standard</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Field Update - Standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Help_Desk_Partner_Portal</fullName>
        <description>Update Owner to Partner Help Queue when Case Origin=Partner Portal.</description>
        <field>OwnerId</field>
        <lookupValue>Partner_Help</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Help Desk - Partner Portal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Phone_Tag_Case_Origin</fullName>
        <description>Automatically changes Case Origin for Phone Tag cases to &quot;Call Inbound.</description>
        <field>Origin</field>
        <literalValue>Customer Call</literalValue>
        <name>Phone Tag Case Origin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Service_Request_Initiated</fullName>
        <description>Changes FS ticket case status to &quot;service request initiated&quot; when a related FS Dispatch has been sent</description>
        <field>Status</field>
        <literalValue>Service Request Initiated</literalValue>
        <name>Service Request Initiated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sungevity_Cases</fullName>
        <field>OwnerId</field>
        <lookupValue>Sungevity_serviced_by_Sunrun</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Sungevity Cases</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Origin_for_Internal_Transfer</fullName>
        <description>for use with workflow: Help Desk - Transfers from SR</description>
        <field>Origin</field>
        <literalValue>Transfer from Internal</literalValue>
        <name>Update Case Origin for Internal Transfer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Origin_for_Voicemail</fullName>
        <field>Origin</field>
        <literalValue>Call</literalValue>
        <name>Update Case Origin for Voicemail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>45 Day Autoclose</fullName>
        <actions>
            <name>Case_Close</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.FS_Days_in_Current_Status__c</field>
            <operation>greaterThan</operation>
            <value>45</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert HelioPower AR and Partner User that Milestone Proof has been Approved</fullName>
        <actions>
            <name>Email_Alert_to_HelioPower_AR_and_Partner_User_Notifying_that_Milestone_Proof_has</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>M1 Proof Approved,M2 Proof Approved (non meter test),M3 PTO Approved,M2 Meter Test Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>HelioPower</value>
        </criteriaItems>
        <description>Alerts HelioPower AR and Partner User that Milestone Proof has been Approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert HelioPower_AR_and_User_ that Milestone Proof has been Denied</fullName>
        <actions>
            <name>Alert_HelioPower_AR_that_Milestone_Proof_Approval_Request_has_been_Denied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>M2 Meter Test Denied,M3 PTO Denied,M2 Proof Denied (non meter test),M1 Proof Denied</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>HelioPower</value>
        </criteriaItems>
        <description>Alerts HelioPower AR and Partner User that Milestone Proof has been Denied</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert User that Milestone Proof has been Approved</fullName>
        <actions>
            <name>Email_Alert_to_Partner_User_Notifying_that_Milestone_Proof_has_been_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>M1 Proof Approved,M2 Proof Approved (non meter test),M3 PTO Approved,M2 Meter Test Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>notContain</operation>
            <value>HelioPower</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>notContain</operation>
            <value>Verengo</value>
        </criteriaItems>
        <description>Alerts Partners that Milestone Proof has been Approved except for the following partners: HelioPower, Verengo</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert User that Milestone Proof has been Denied</fullName>
        <actions>
            <name>Milestone_Proof_Denied_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>M2 Meter Test Denied,M3 PTO Denied,M2 Proof Denied (non meter test),M1 Proof Denied</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>notContain</operation>
            <value>HelioPower</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>notContain</operation>
            <value>Verengo</value>
        </criteriaItems>
        <description>Alerts Partners that Milestone Proof has been Denied except for the following partners:  HelioPower, Verengo</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Verengo Rebates and Partner User that Milestone Proof has been Approved</fullName>
        <actions>
            <name>Email_Alert_to_Verengo_Rebates_and_Partner_User_Notifying_that_Milestone_Proof_h</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>M1 Proof Approved,M2 Proof Approved (non meter test),M3 PTO Approved,M2 Meter Test Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>Verengo</value>
        </criteriaItems>
        <description>Alerts Verengo Rebates and Partner User that Milestone Proof has been Approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alert Verengo Rebates_and_User_ that Milestone Proof has been Denied</fullName>
        <actions>
            <name>Alert_Verengo_Rebates_that_Milestone_Proof_Approval_Request_has_been_Denied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>M2 Meter Test Denied,M3 PTO Denied,M2 Proof Denied (non meter test),M1 Proof Denied</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>Verengo</value>
        </criteriaItems>
        <description>Alerts Verengo Rebates and Partner User that Milestone Proof has been Denied</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Case to Partner help queue</fullName>
        <actions>
            <name>Assign_Case_to_Partner_help_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Call</value>
        </criteriaItems>
        <description>Assign the case created by partner users to &quot;partner help&quot; queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Auto Assign Case Record Type %28Customer Care%29</fullName>
        <actions>
            <name>Field_Update_Standard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Customer Care Cases</value>
        </criteriaItems>
        <description>Automatically Changes the Case Record Type to &quot;Standard Case&quot; when a Case record is moved into the Customer Care queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto Assign Case Record Type %28Partner Help%29</fullName>
        <actions>
            <name>Field_Update_Partner_Concierge</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <description>Automatically Changes the Case Record Type to &quot;Partner Help&quot; when a Case record is moved into the Partner Help Queue</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CCNOTIFICATIONDELETE</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>has been transferred to you,Priority Level: Normal</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Response Notifier</fullName>
        <actions>
            <name>New_Case_Activity00</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting CC Associate Response</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Public__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>SunRun CRM</value>
        </criteriaItems>
        <description>The case number below has a new customer response. Please reply accordingly.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Compensated Modified By</fullName>
        <actions>
            <name>Compensated_Modified_By</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR
(
ISCHANGED( Compensated__c ),
AND(ISNEW(), NOT (ISBLANK(Compensated__c))) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Customer Care Escalations</fullName>
        <actions>
            <name>Customer_Care_Escalation_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Customer_Care_Escalations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Internal Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>has been transferred to you</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Documents Emails</fullName>
        <actions>
            <name>Documents_Emails</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Documents</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Account Manager</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Concierge</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>High,Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status_Updated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Email Account Manager when case status changes</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Account Manager when Case for Partner created</fullName>
        <actions>
            <name>Email_Account_Manager_when_Case_for_Partner_Created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Concierge</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Address_of_Account_Manager__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Email Account Manager when Case for Partner created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email Account Manager when Case for their Partner is closed</fullName>
        <actions>
            <name>Email_Account_Manager_when_Case_for_their_Partner_is_Closed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Concierge</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Email_Address_of_Account_Manager__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Email Account Manager when Case for their Partner is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Milestone Proofs Needing Approval - Arco Energy</fullName>
        <actions>
            <name>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_Arco_Energy</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Request Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>Arco Energy</value>
        </criteriaItems>
        <description>Email Alert for Milestone Proofs Needing Approval - Specific to Arco Energy</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Milestone Proofs Needing Approval - HelioPower</fullName>
        <actions>
            <name>Alert_Email_to_Ops_that_MP_Needs_Approval2</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Request Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>HelioPower</value>
        </criteriaItems>
        <description>Email Alert for Milestone Proofs Needing Approval - Specific to HelioPower</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Milestone Proofs Needing Approval - Katy partners</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Request Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>equals</operation>
            <value>Sunlight Solar Energy,RS,Imagine Energy</value>
        </criteriaItems>
        <description>Email Alert for Milestone Proofs Needing Approval - Specific to Katy</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Milestone Proofs Needing Approval - PetersenDean</fullName>
        <actions>
            <name>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_PetersenDean</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Request Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>PetersenDean</value>
        </criteriaItems>
        <description>Email Alert for Milestone Proofs Needing Approval - Specific to PetersenDean</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Milestone Proofs Needing Approval - Roof Diagnostics</fullName>
        <actions>
            <name>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_Roof_Diagnostics</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Request Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>Roof Diagnostics</value>
        </criteriaItems>
        <description>Email Alert for Milestone Proofs Needing Approval - Specific to Roof Diagnostics</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Milestone Proofs Needing Approval - Trinity Solar</fullName>
        <actions>
            <name>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_Trinity_Solar</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Request Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>Trinity Solar</value>
        </criteriaItems>
        <description>Email Alert for Milestone Proofs Needing Approval - Specific to Trinity Solar</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Milestone Proofs Needing Approval - Verengo</fullName>
        <actions>
            <name>Ops_Email_Alert_for_Milestone_Proofs_Needing_Approval_Verengo</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Milestone Proof</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Request Approval</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Install_Partner__c</field>
            <operation>contains</operation>
            <value>Verengo</value>
        </criteriaItems>
        <description>Email Alert for Milestone Proofs Needing Approval - Specific to Verengo</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Email Verengo Account Manager when Case for Partner Created</fullName>
        <actions>
            <name>Email_Verengo_Account_Manager_when_Case_for_Partner_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Concierge</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>equals</operation>
            <value>Verengo</value>
        </criteriaItems>
        <description>When a Partner Concierge case is created for Verengo an email will be sent out to the Account Manager (Jameson Dequinia AND Jason 
Lehman)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FS Notify Creator FS Ticket Closed</fullName>
        <actions>
            <name>FS_Email_Creator_of_Case_Closure</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FS Ticket</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Duplicate,Closed</value>
        </criteriaItems>
        <description>Email the creator of an FS Ticket case that the case was closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Help Desk - Call</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Call</value>
        </criteriaItems>
        <description>When help desk members create case to log call, assign the user as the owner, rather than the queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Help Desk - Partner Portal Origin</fullName>
        <actions>
            <name>Help_Desk_Partner_Portal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Partner Portal</value>
        </criteriaItems>
        <description>Assign cases that come through Partner Portal to the Partner Help Queue, rather than having the creator be the owner.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Help Desk - Transfers from SR</fullName>
        <actions>
            <name>Update_Case_Origin_for_Internal_Transfer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@sunrun</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>Fwd: ShoreTel voice message from</value>
        </criteriaItems>
        <description>When case is created and has Record Type=Partner Help, and the web email is a Sunrun email address, we mark it as a transfer in order to distinguish it from other emails we receive through email-to-case.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Help Desk - Voicemail</fullName>
        <actions>
            <name>Update_Case_Origin_for_Voicemail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>startsWith</operation>
            <value>justin.hustrulid</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>Fwd: ShoreTel voice message from</value>
        </criteriaItems>
        <description>When voicemail is forwarded from the Help Desk phone workgroup to SFDC, mark it as a Call</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner Concierge%3A Case Created Email</fullName>
        <actions>
            <name>Email_Case_Contact_when_Partner_Concierge_Case_Created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Concierge</value>
        </criteriaItems>
        <description>Email Case Contact when new Partner Concierge Case is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner Concierge%3A Non-Urgent Case Heads Up to Case Contact</fullName>
        <actions>
            <name>Partner_Concierge_Non_Urgent_Case_Heads_Up_to_Case_Contact</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Concierge</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Low</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Closed - Duplicate,Closed</value>
        </criteriaItems>
        <description>When a Partner Concierge Case Priority is changed to LOW this emails the Case Contact Email


Old formula:

$RecordType.Name  = &quot;Partner Concierge&quot;  &amp;&amp;  (ISPICKVAL(Priority, &quot;Low&quot;))</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Partner Help%3A Case Created Email</fullName>
        <actions>
            <name>Email_Case_Contact_when_Partner_Case_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Call</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Partner Help%3A Notify Case owner when Case is closed by Partner</fullName>
        <actions>
            <name>Partner_Help_Email_Case_Owner_when_case_is_closed_by_Partner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <description>Notify case owner when case is closed by Partner</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Partner Help%3ANotify Creator When Case is Closed</fullName>
        <actions>
            <name>Partner_Help_Email_Creator_of_Case_Closure</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Partner Help</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Duplicate,Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>notEqual</operation>
            <value>Partner</value>
        </criteriaItems>
        <description>Email Creator of the case when it is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Phone Tag Case Origin</fullName>
        <actions>
            <name>Phone_Tag_Case_Origin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>PhoneTag</value>
        </criteriaItems>
        <description>Automatically changes the case origin of Phone Tag cases to &quot;Call Inbound.&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Rate Mod Test</fullName>
        <actions>
            <name>Rate_Sent_to_Queue</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Rate modification</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Redeployment_FS</fullName>
        <actions>
            <name>Notification_of_System_Removal_Status_FS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subset_Reasons__c</field>
            <operation>equals</operation>
            <value>Removal and Re-installation</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sungevity Cases</fullName>
        <actions>
            <name>Sungevity_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Sungevity</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>You Have a New Message from Customer Care</fullName>
        <actions>
            <name>You_Have_A_New_Message_from_Sunrun_Customer_Care</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Public__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Awaiting Response from Portal</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>New_Case_Activity</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>New Case Activity</subject>
    </tasks>
    <tasks>
        <fullName>New_Case_Activity00</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>New Case Activity</subject>
    </tasks>
    <tasks>
        <fullName>Rate_Sent_to_Queue</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>Case Sent to RM Queue</subject>
    </tasks>
</Workflow>
