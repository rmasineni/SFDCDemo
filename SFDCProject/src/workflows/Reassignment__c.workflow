<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_of_System_Removal_Status_ST</fullName>
        <description>Notification of System Removal Status_ST</description>
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
        <fullName>Send_welcome_email_to_reassignments</fullName>
        <description>Send welcome email to reassignments</description>
        <protected>false</protected>
        <recipients>
            <field>Assignee__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CC_Do_Not_Use_Templates/Reassignment_Welcome_Letter</template>
    </alerts>
    <fieldUpdates>
        <fullName>Accounting_Actions_Complete</fullName>
        <description>STATUS field changed to &quot;Accounting Actions Complete&quot;</description>
        <field>Status__c</field>
        <literalValue>Accounting Actions Complete</literalValue>
        <name>Accounting Actions Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Closed</fullName>
        <description>STATUS field changed to &quot;Closed&quot;</description>
        <field>Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Create_Customer_Contact_in_Oracle</fullName>
        <description>STATUS field changed to &quot;Create Customer Contact in Oracle&quot;</description>
        <field>Status__c</field>
        <literalValue>Create Customer Contact in Oracle</literalValue>
        <name>Create Customer Contact in Oracle</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Need_to_Force_Recon</fullName>
        <description>STATUS field changed to &quot;Need to Force Reconciliation&quot;</description>
        <field>Status__c</field>
        <literalValue>Need to Force Reconciliation</literalValue>
        <name>Need to Force Reconciliation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Negotiation_Sale_in_Progress</fullName>
        <description>Used to force Reassignment record back to Entry Point of Approval Process</description>
        <field>Status__c</field>
        <literalValue>Negotiation/Sale In Progress</literalValue>
        <name>Negotiation / Sale in Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Date_Agreed_Upon_Payment_Accep</fullName>
        <description>Workflow: Populate &quot;Date Agreed Upon Payment Accepted&quot; field when the &quot;Agreed Upon Payment&quot; field is filled in by a user</description>
        <field>Date_Agreed_Upon_Payment_Accepted__c</field>
        <formula>Today()</formula>
        <name>Populate &quot;Date Agreed Upon Payment Accep</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Date_Proposed_Payment_Offered</fullName>
        <description>Workflow: Populate &quot;Date Proposed Payment Offered&quot; field when the &quot;Proposed Payment&quot; field is filled in by a user</description>
        <field>Date_Proposed_Payment_Offered__c</field>
        <formula>Today()</formula>
        <name>Populate &quot;Date Proposed Payment Offered&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Push_through_Ops_Portal</fullName>
        <description>STATUS field changed to &quot;Push through Ops Portal&quot;</description>
        <field>Status__c</field>
        <literalValue>Push through Ops Portal</literalValue>
        <name>Push through Ops Portal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RA_Close_Date</fullName>
        <field>RA_Closed__c</field>
        <formula>today()</formula>
        <name>RA Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RA_Forms_Received</fullName>
        <description>STATUS field changed to &quot;RA Forms Received: Awaiting Internal Processing&quot;</description>
        <field>Status__c</field>
        <literalValue>RA Forms Received: Awaiting Internal Processing</literalValue>
        <name>RA Forms Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Verify_Amount_Due_for_Seller_Buyer</fullName>
        <description>STATUS field changed to &quot;Verify Amount Due for Seller/Buyer&quot;</description>
        <field>Status__c</field>
        <literalValue>Verify Amount Due for Seller/Buyer</literalValue>
        <name>Verify Amount Due for Seller Buyer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Verify_Credit</fullName>
        <description>Changes Status to &quot;Verify Credit&quot;</description>
        <field>Status__c</field>
        <literalValue>Verify Credit</literalValue>
        <name>Verify Credit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Verify_Customer_Contact_in_Oracle</fullName>
        <description>STATUS field changed to &quot;Verify Customer Contact in Oracle&quot;</description>
        <field>Status__c</field>
        <literalValue>Verify Customer Contact in Oracle</literalValue>
        <name>Verify Customer Contact in Oracle</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Verify_Invoice_Sent_to_New_Customer</fullName>
        <description>STATUS field changed to &quot;Verify Invoice Sent to New Customer&quot;</description>
        <field>Status__c</field>
        <literalValue>Verify Invoice Sent to New Customer</literalValue>
        <name>Verify Invoice Sent to New Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Verify_Reconciliation_Sent</fullName>
        <description>STATUS field changed to &quot;Verify Reconciliation Sent&quot;</description>
        <field>Status__c</field>
        <literalValue>Verify Reconciliation Sent</literalValue>
        <name>Verify Reconciliation Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Crediting New Customer</fullName>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Reassignment__c.Status__c</field>
            <operation>equals</operation>
            <value>Verify Customer Contact in Oracle</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Move to RA forms rec%27d</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Reassignment__c.Status__c</field>
            <operation>equals</operation>
            <value>Need to Force Reconciliation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reassignment__c.Billing_on_GA__c</field>
            <operation>notEqual</operation>
            <value>Balanced</value>
        </criteriaItems>
        <description>moves the status to RA forms rec&apos;d if the record has entered the submission flow and the billing type is generation</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate %22Date Agreed Upon Payment Accepted%22 field</fullName>
        <actions>
            <name>Populate_Date_Agreed_Upon_Payment_Accep</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reassignment__c.Agreed_Upon_Payment__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow: Populate &quot;Date Agreed Upon Payment Accepted&quot; field when the &quot;Agreed Upon Payment&quot; field is filled in by a user</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate %22Date Proposed Payment Offered%22 field</fullName>
        <actions>
            <name>Populate_Date_Proposed_Payment_Offered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reassignment__c.Proposed_Payment__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow: Populate &quot;Date Proposed Payment Offered&quot; field when the &quot;Proposed Payment&quot; field is filled in by a user</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RA Status Is Closed</fullName>
        <actions>
            <name>RA_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reassignment__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reassignment - Move to Closed</fullName>
        <actions>
            <name>Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reassignment__c.Status__c</field>
            <operation>equals</operation>
            <value>Accounting Actions Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reassignment__c.New_Title_Notice_Filed__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reassignment__c.Welcome_Call_Completed__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Changes Reassignment Status to &quot;Closed&quot; when criteria are met</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reassignment Welcome Email</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Reassignment__c.Billing_System_Switch_Complete__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sending welcome email to Reassignments after the System Switch Complete field is filled in.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Redeployment_ST</fullName>
        <actions>
            <name>Notification_of_System_Removal_Status_ST</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reassignment__c.Status__c</field>
            <operation>equals</operation>
            <value>System Relocated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>New_title_notice_req_d</fullName>
        <assignedTo>bshapiro@sunrunhome.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>New NOIEP Needed</description>
        <dueDateOffset>30</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>New title notice req&apos;d</subject>
    </tasks>
    <tasks>
        <fullName>Reassignment_Rejected_Please_Resubmit</fullName>
        <assignedToType>owner</assignedToType>
        <description>Reassignment Rejected Please Resubmit</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reassignment Rejected Please Resubmit</subject>
    </tasks>
    <tasks>
        <fullName>Reassignment_Welcome_Call</fullName>
        <assignedTo>nrosenbloom@sunrunhome.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Welcome Call Needed for Reassignment</description>
        <dueDateOffset>5</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Reassignment Welcome Call</subject>
    </tasks>
    <tasks>
        <fullName>Rejected_Reassignment1</fullName>
        <assignedTo>sunruncrm@sunrunhome.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Rejected Reassignment</subject>
    </tasks>
</Workflow>
