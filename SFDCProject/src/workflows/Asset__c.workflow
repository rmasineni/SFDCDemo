<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Asset_Type_Meter</fullName>
        <field>Meter_Type__c</field>
        <literalValue>SS iTRon</literalValue>
        <name>Asset Type = Meter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Asset Type Meter</fullName>
        <actions>
            <name>Asset_Type_Meter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( ISPICKVAL(Type__c, &quot;Meter&quot;), ISPICKVAL(Meter_Type__c, &quot;&quot;), DATEVALUE(CreatedDate) &gt;  DATE(2014,07,09) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
