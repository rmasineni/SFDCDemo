<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_10_days_prior_to_Proposal_Expiration</fullName>
        <description>Email Alert 10 days prior to Proposal Expiration</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Operations/Proposal_Expiration_10_days</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_1_day_prior_to_Proposal_Expiration</fullName>
        <description>Email Alert 1 day prior to Proposal Expiration</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Operations/Proposal_Expiration_1_day</template>
    </alerts>
    <alerts>
        <fullName>SR_Declined_Email_Notification</fullName>
        <description>SR Declined Email Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Submitted_By__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SR_Declined_Email_Notification_v1</template>
    </alerts>
    <alerts>
        <fullName>Sales_Rep_Email</fullName>
        <description>Sales Rep Email</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Brea_designers_lead_created_notification</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>proposal@sunrun.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Partner_Legacy_Proposal_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Solar_Universe_Ready_for_Submission_email</fullName>
        <ccEmails>Ops_sfs@solaruniverse.com</ccEmails>
        <description>Solar Universe Ready for Submission email</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Special_Lead_Source/Solar_Universe_Ready_for_Submission_email</template>
    </alerts>
    <fieldUpdates>
        <fullName>ACH_Fee_Eligible_Update</fullName>
        <field>ACH_Fee_Eligible__c</field>
        <literalValue>$15</literalValue>
        <name>ACH Fee Eligible Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>April_kWh</fullName>
        <field>Apr_Usage__c</field>
        <formula>April_kWh__c</formula>
        <name>April kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>August_kWh</fullName>
        <field>Aug_Usage__c</field>
        <formula>August_kWh__c</formula>
        <name>August kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_date_on_Oppty</fullName>
        <field>CloseDate</field>
        <formula>DATEVALUE( SR_Signoff__c )</formula>
        <name>Close date on Oppty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Costco_Program_type1_field_upd</fullName>
        <field>Program_Type__c</field>
        <literalValue>Program 1</literalValue>
        <name>Costco Program type1 field upd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Costco_Program_type2_field_upd</fullName>
        <field>Program_Type__c</field>
        <literalValue>Program 2</literalValue>
        <name>Costco Program type2 field upd</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Submitted</fullName>
        <field>Date_Submitted__c</field>
        <formula>DATEVALUE(LastModifiedDate)</formula>
        <name>Date Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Finance_Received_Proposal</fullName>
        <field>Date_Time_Finance_Received_Proposal__c</field>
        <formula>LastModifiedDate</formula>
        <name>Date/Time Finance Received Proposal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Ops_Received_Proposal_back</fullName>
        <field>Date_Time_Ops_Received_Proposal_back__c</field>
        <formula>LastModifiedDate</formula>
        <name>Date/Time Ops Received Proposal back</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Pending_Task_Resolved</fullName>
        <field>Date_Time_Pending_Task_Resolved__c</field>
        <formula>LastModifiedDate</formula>
        <name>Date/Time Pending Task Resolved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Pending_Task_Resolved_NULL</fullName>
        <field>Date_Time_Pending_Task_Resolved__c</field>
        <name>Date/Time Pending Task Resolved (NULL)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Proposal_in_Pending_Stage</fullName>
        <field>Date_Time_Proposal_in_Pending_Stage__c</field>
        <formula>LastModifiedDate</formula>
        <name>Date/Time Proposal in Pending Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_SR_Credit_Review</fullName>
        <field>Date_Time_SR_Credit_Review__c</field>
        <formula>LastModifiedDate</formula>
        <name>Date/Time SR Credit Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_SR_Ops_Received</fullName>
        <field>Date_Time_SR_Ops_Received__c</field>
        <formula>LastModifiedDate</formula>
        <name>Date/Time SR Ops Received</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Signoff_Review</fullName>
        <field>Date_Time_Signoff_Review__c</field>
        <formula>LastModifiedDate</formula>
        <name>Date/Time Signoff Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Submitted</fullName>
        <field>Date_Time_Submitted__c</field>
        <formula>LastModifiedDate</formula>
        <name>Date/Time Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Dealer_fee_value</fullName>
        <field>Dealer_Fee__c</field>
        <formula>0.13</formula>
        <name>Dealer fee value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>December_kWh</fullName>
        <field>Dec_Usage__c</field>
        <formula>December_kWh__c</formula>
        <name>December kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Feburary_kWh</fullName>
        <field>Feb_Usage__c</field>
        <formula>February_kWh__c</formula>
        <name>Feburary kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Financing_Institution_for_COBF</fullName>
        <field>Financing_Institution__c</field>
        <formula>&quot;GreenSky&quot;</formula>
        <name>Financing Institution for COBF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>January_kWh</fullName>
        <field>Jan_Usage__c</field>
        <formula>January_kWh__c</formula>
        <name>January kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>July_kWh</fullName>
        <field>Jul_Usage__c</field>
        <formula>July_kWh__c</formula>
        <name>July kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>June_kWh</fullName>
        <field>Jun_Usage__c</field>
        <formula>June_kWh__c</formula>
        <name>June kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Manual_Shade_Site</fullName>
        <field>Manual_Shade_Site__c</field>
        <literalValue>1</literalValue>
        <name>Manual Shade Site</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>March_kWh</fullName>
        <field>Mar_Usage__c</field>
        <formula>March_kWh__c</formula>
        <name>March kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>May_kWh</fullName>
        <field>May_Usage__c</field>
        <formula>May_kWh__c</formula>
        <name>May kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>November_kWh</fullName>
        <field>Nov_Usage__c</field>
        <formula>November_kWh__c</formula>
        <name>November kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>October_kWh</fullName>
        <field>Oct_Usage__c</field>
        <formula>October_kWh__c</formula>
        <name>October kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opty_Estimated_Construction_Date</fullName>
        <field>Scheduled_Construction_Start_Date__c</field>
        <formula>IF(AND(ISNULL(Customer_Signoff_Date__c),State__c &lt;&gt; &quot;HI&quot;),Today()+80,
IF(AND(ISNULL(Customer_Signoff_Date__c),State__c = &quot;HI&quot;),Today()+200,
IF(AND(NOT(ISNULL(Customer_Signoff_Date__c)),State__c &lt;&gt; &quot;HI&quot;),DATEVALUE(Customer_Signoff_Date__c) + 80,
IF(AND(NOT(ISNULL(Customer_Signoff_Date__c)),State__c = &quot;HI&quot;),DATEVALUE(Customer_Signoff_Date__c) + 200,Today()))))</formula>
        <name>Opty Estimated Construction Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Original_Proposal_Stage</fullName>
        <field>Original_Proposal_Stage_Text__c</field>
        <formula>&apos;SR Approved&apos;</formula>
        <name>Original Proposal Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Promo_Code_Update</fullName>
        <field>Promo_Code__c</field>
        <formula>Lead_Promotion_Id__r.Promotion_Code__c</formula>
        <name>Promo Code Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>September_kWh</fullName>
        <field>Sep_Usage__c</field>
        <formula>September_kWh__c</formula>
        <name>September kWh</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stage_Modified_Date</fullName>
        <field>Stage_Last_Modified__c</field>
        <formula>DATEVALUE(LastModifiedDate)</formula>
        <name>Stage Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Valid_for_BB_proposals</fullName>
        <field>Status__c</field>
        <literalValue>Valid</literalValue>
        <name>Status Valid for BB proposals</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Process_field</fullName>
        <field>Completed_Approval_Process__c</field>
        <literalValue>1</literalValue>
        <name>Update Approval Process field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CloseDate_on_Oppty</fullName>
        <field>CloseDate</field>
        <formula>DATEVALUE(SR_Signoff__c)</formula>
        <name>Update CloseDate on Oppty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Design_Plan_Review</fullName>
        <field>Design_Plan_Review_Required__c</field>
        <literalValue>1</literalValue>
        <name>Update Design Plan Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proposal_Assigne</fullName>
        <field>Assigne__c</field>
        <lookupValue>sroperations@sunrunhome.com.prod</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Proposal Assigne</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Proposal_Stage</fullName>
        <field>ProposalStage__c</field>
        <formula>TEXT( Stage__c)</formula>
        <name>Update Proposal Stage</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SR_Signoff_Date</fullName>
        <field>SR_Signoff__c</field>
        <name>Update SR Signoff Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_on_Opptortunity</fullName>
        <field>StageName</field>
        <literalValue>7. Closed Won</literalValue>
        <name>Update Stage on Opptortunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Stage_on_Oppty</fullName>
        <field>StageName</field>
        <literalValue>7. Closed Won</literalValue>
        <name>Update Stage on Oppty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Utility_Name</fullName>
        <field>Utility__c</field>
        <formula>&quot;NSTAR&quot;</formula>
        <name>Update Utility Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ACH Fee Eligible Update</fullName>
        <actions>
            <name>ACH_Fee_Eligible_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Proposal_Source__c</field>
            <operation>equals</operation>
            <value>PT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.Change_Order__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto Populate Estimated Construction Date</fullName>
        <actions>
            <name>Opty_Estimated_Construction_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Proposal__c.Customer_Signoff_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.Signed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Scheduled_Construction_Start_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Proposal Utility Name</fullName>
        <actions>
            <name>Update_Utility_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Utility__c</field>
            <operation>equals</operation>
            <value>NSTAR - Cape Cod</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Costco Program type 1 on proposal</fullName>
        <actions>
            <name>Costco_Program_type1_field_upd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Program_Type__c</field>
            <operation>equals</operation>
            <value>Program 1</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Costco Program type 2 on proposal</fullName>
        <actions>
            <name>Costco_Program_type2_field_upd</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Program_Type__c</field>
            <operation>equals</operation>
            <value>Program 2</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Date Submitted</fullName>
        <actions>
            <name>Date_Submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Date_Time_Submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( NOT(ISPICKVAL(PRIORVALUE(Stage__c), &quot;Submitted&quot;)), ISPICKVAL(Stage__c, &quot;Submitted&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime Finance Received Proposal</fullName>
        <actions>
            <name>Date_Time_Finance_Received_Proposal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL (Stage__c, &quot;SR Ops Reviewed&quot;) &amp;&amp; NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;SR Ops Reviewed&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime Ops Received Proposal back</fullName>
        <actions>
            <name>Date_Time_Ops_Received_Proposal_back</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL (Stage__c, &quot;SR Credit Approved&quot;) &amp;&amp; NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;SR Credit Approved&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime Pending Task Resolved</fullName>
        <actions>
            <name>Date_Time_Pending_Task_Resolved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL (Stage__c, &quot;Pending Task Completed&quot;) &amp;&amp; NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;Pending Task Completed&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime Proposal in Pending Stage</fullName>
        <actions>
            <name>Date_Time_Pending_Task_Resolved_NULL</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Date_Time_Proposal_in_Pending_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL (Stage__c, &quot;Pending&quot;) &amp;&amp; NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;Pending&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime SR Credit Review</fullName>
        <actions>
            <name>Date_Time_SR_Credit_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL (Stage__c, &quot;SR Credit Review&quot;)  &amp;&amp;  NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;SR Credit Review&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime SR Ops Received</fullName>
        <actions>
            <name>Date_Time_SR_Ops_Received</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL (Stage__c, &quot;SR Ops Received&quot;)  &amp;&amp;  NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;SR Ops Received&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime Signoff Review</fullName>
        <actions>
            <name>Date_Time_Signoff_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL (Stage__c, &quot;SR Signoff Review&quot;) &amp;&amp; NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;SR Signoff Review&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Dealer fee value assignment</fullName>
        <actions>
            <name>Dealer_fee_value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>For all the  dates after the date period 8/4/2015 , the following assignment of dealer fee should be done.
12 year 3.99% APR:  13% dealer fee 
20 year 4.99% APR : 13% dealer fee</description>
        <formula>AND(  OR( ISPICKVAL(Financing_Term_Length__c, &apos;12&apos;), ISPICKVAL(Financing_Term_Length__c, &apos;20&apos;) ), DATEVALUE(CreatedDate) &gt; DATE(2015,08,03)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Financing Institution for COBF</fullName>
        <actions>
            <name>Financing_Institution_for_COBF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Agreement_Type__c</field>
            <operation>equals</operation>
            <value>Customer Owned - Bank Financed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.Financing_Term_Length__c</field>
            <operation>equals</operation>
            <value>12,20</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>7/20/2015</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Manual Shade Site</fullName>
        <actions>
            <name>Manual_Shade_Site</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Manual_Shading_Used__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Proposal Created</fullName>
        <actions>
            <name>Sales_Rep_Email</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
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
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Original Proposal Stage</fullName>
        <actions>
            <name>Original_Proposal_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISPICKVAL (Stage__c, &quot;SR Approved&quot;) &amp;&amp; NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;SR Approved&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Promo Code</fullName>
        <actions>
            <name>Promo_Code_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates Promo Code upon changing Lead Promotion ID on Proposal</description>
        <formula>ISCHANGED(Lead_Promotion_Id__c)=TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Expiration eMail 1 day prior to Expiration</fullName>
        <actions>
            <name>Email_Alert_1_day_prior_to_Proposal_Expiration</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Expiration_eMail_Count__c</field>
            <operation>equals</operation>
            <value>2</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.Install_Partner_Name__c</field>
            <operation>notEqual</operation>
            <value>Sungevity</value>
        </criteriaItems>
        <description>If the current date == 59 days from proposal submitted Date then send a Expiration mail to Sales rep</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal Expiration eMail 10 days prior to expiration</fullName>
        <actions>
            <name>Email_Alert_10_days_prior_to_Proposal_Expiration</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Expiration_eMail_Count__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.Install_Partner_Name__c</field>
            <operation>notEqual</operation>
            <value>Sungevity</value>
        </criteriaItems>
        <description>If the current date &gt; 50 days from proposal submitted Date then send a warning mail to Sales rep</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposal to Oppty %28Jan-Oct%29</fullName>
        <actions>
            <name>April_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>August_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Feburary_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>January_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>July_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>June_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>March_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>May_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>October_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>September_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Proposal_Source__c</field>
            <operation>equals</operation>
            <value>PT</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposal to Oppty %28Nov-Dec%29</fullName>
        <actions>
            <name>December_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>November_kWh</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Proposal_Source__c</field>
            <operation>equals</operation>
            <value>PT</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SR Declined Email Notification</fullName>
        <actions>
            <name>SR_Declined_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(Stage__c, &quot;SR Declined&quot;), Opportunity__r.Opportunity_Division_Custom__c !=  $Label.AEE_label )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Solar Universe Ready for Submission email</fullName>
        <actions>
            <name>Solar_Universe_Ready_for_Submission_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISPICKVAL (Stage__c, &quot;Ready for Submission&quot;), NOT(ISPICKVAL ((PRIORVALUE(Stage__c)), &quot;Ready for Submission&quot;)), $User.Account_Name__c = &apos;Solar Universe&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Stage Modified Date</fullName>
        <actions>
            <name>Stage_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Stage__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Status Valid for BB proposals</fullName>
        <actions>
            <name>Status_Valid_for_BB_proposals</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Proposal__c.Proposal_Source__c</field>
            <operation>equals</operation>
            <value>BB</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update CloseDate%2FStage on Oppty</fullName>
        <actions>
            <name>Update_CloseDate_on_Oppty</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Proposal__c.SR_Signoff__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>7. Closed Won,Closed Won</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Design Plan Review</fullName>
        <actions>
            <name>Update_Design_Plan_Review</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Proposal__c.Proposal_Source__c</field>
            <operation>equals</operation>
            <value>BB</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.Cost_Stack__c</field>
            <operation>equals</operation>
            <value>MULTI_PARTY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.Cost_Stack__c</field>
            <operation>equals</operation>
            <value>INTEGRATED_SUNRUN_SELLS</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Proposal Stage</fullName>
        <actions>
            <name>Update_Proposal_Stage</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Proposal__c.Stage__c</field>
            <operation>equals</operation>
            <value>Pending,Pending Task Completed,SR Approved,SR Credit Approved,SR Credit Review,SR Ops Received,SR Ops Reviewed,SR Signoff Review,Submitted</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Stage on Oppty</fullName>
        <actions>
            <name>Update_Stage_on_Opptortunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Proposal__c.Stage__c</field>
            <operation>equals</operation>
            <value>SR Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Proposal__c.SR_Signoff__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
