<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Request_Status</fullName>
        <field>Request_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update Request Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Async Request Status</fullName>
        <actions>
            <name>Update_Request_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Async_Process_Queue__c.Request_Type__c</field>
            <operation>equals</operation>
            <value>UpdateLastClick,LoadRelatedRecords</value>
        </criteriaItems>
        <criteriaItems>
            <field>Async_Process_Queue__c.Request_Status__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>Update Request for Async Process Queue request to &apos;In Progress&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
