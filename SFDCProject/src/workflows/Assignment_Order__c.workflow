<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Assignment_Criteria_2</fullName>
        <field>Assignment_Criteria_2__c</field>
        <formula>text(Assignment_Criteria__c)</formula>
        <name>Assignment Criteria 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_2</fullName>
        <field>Order_2__c</field>
        <formula>value( text(Order__c ))</formula>
        <name>Order 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Assignment Criteria</fullName>
        <actions>
            <name>Assignment_Criteria_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Assignment_Order__c.Assignment_Criteria__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
