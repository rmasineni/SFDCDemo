<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Intel_Employee_Promo</fullName>
        <field>Promo_Type__c</field>
        <literalValue>Cash back</literalValue>
        <name>Intel Employee Promo_Cashback</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Intel_employee_promo_500</fullName>
        <field>Promo_Value__c</field>
        <formula>500</formula>
        <name>Intel employee promo_500</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Intel Employee Promo</fullName>
        <actions>
            <name>Intel_Employee_Promo</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Intel_employee_promo_500</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Promotions__c.Promo_Name__c</field>
            <operation>equals</operation>
            <value>Intel Employee Program</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
