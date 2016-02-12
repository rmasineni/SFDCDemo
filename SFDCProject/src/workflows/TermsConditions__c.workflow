<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Terms_Conditions_EndDate</fullName>
        <description>Update Terms &amp; Conditions EndDate when status becomes inactive</description>
        <field>EndDate__c</field>
        <formula>TODAY()</formula>
        <name>Update Terms &amp; Conditions EndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate Terms and Conditions EndDate</fullName>
        <actions>
            <name>Update_Terms_Conditions_EndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>TermsConditions__c.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Populate Terms and Conditions EndDate when Status becomes inactive</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
