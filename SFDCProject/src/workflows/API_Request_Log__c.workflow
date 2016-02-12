<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Request_Status</fullName>
        <field>Request_Status__c</field>
        <literalValue>Look-up In Progress</literalValue>
        <name>Update Request Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update API Request Log to Invoke Lookup Callout</fullName>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>API_Request_Log__c.External_Sync_System__c</field>
            <operation>equals</operation>
            <value>Home Depot</value>
        </criteriaItems>
        <criteriaItems>
            <field>API_Request_Log__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>HD Lead Look-up</value>
        </criteriaItems>
        <criteriaItems>
            <field>API_Request_Log__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>HD SCE Look-up</value>
        </criteriaItems>
        <description>This WF will update field Request Status on API Request Log which will invoke the HD lookup callout using the trigger code</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Request_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>API_Request_Log__c.Trigger_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
