<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Completed_to_Closed</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Completed to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
        <fullName>Update_IsVisibleInSelfService</fullName>
        <field>IsVisibleInSelfService</field>
        <literalValue>1</literalValue>
        <name>Update IsVisibleInSelfService</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Completed to Closed</fullName>
        <actions>
            <name>Completed_to_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>startsWith</operation>
            <value>Message Sent:</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>startsWith</operation>
            <value>Reply:</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime Pending Task Resolved</fullName>
        <actions>
            <name>Date_Time_Pending_Task_Resolved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL (Status, &quot;Resolved&quot;) &amp;&amp; NOT(ISPICKVAL ((PRIORVALUE(Status)), &quot;Resolved&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update IsVisibleInSelfService field for portal tasks</fullName>
        <actions>
            <name>Update_IsVisibleInSelfService</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Owner:User.ContactId !=null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
