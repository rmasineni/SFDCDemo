<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EOP_Fix_add_missing_in_pdf_fielname</fullName>
        <field>Document_Name__c</field>
        <formula>SUBSTITUTE( Document_Name__c , &quot;pdf&quot;, &quot;.pdf&quot;)</formula>
        <name>EOP Fix add missing . in pdf fielname</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EOP Temp Bug Fix - Missing period for pdfs</fullName>
        <actions>
            <name>EOP_Fix_add_missing_in_pdf_fielname</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( 
CONTAINS(Document_Name__c, &quot;pdf&quot;), 
NOT(CONTAINS(Document_Name__c, &quot;.pdf&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
