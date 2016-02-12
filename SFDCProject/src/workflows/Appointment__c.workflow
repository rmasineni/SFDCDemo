<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Mobile_for_SMS</fullName>
        <field>Mobile_for_SMS__c</field>
        <formula>Opportunity__r.Contact__r.Phone</formula>
        <name>Mobile for SMS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>24 hr appt reminder</fullName>
        <active>true</active>
        <formula>AND ( 
OR( 
ISPICKVAL(Appointment_Type__c, &apos;Phone Consultation&apos;), 
ISPICKVAL(Appointment_Type__c, &apos;Field Consultation&apos;),
ISPICKVAL(Appointment_Type__c, &apos;Home Visit&apos;), 
ISPICKVAL(Appointment_Type__c, &apos;Home Visit Follow up&apos;), 
ISPICKVAL(Appointment_Type__c, &apos;Phone Call&apos;), 
ISPICKVAL(Appointment_Type__c, &apos;Phone Call Follow up&apos;)  
), 

Appointment_Date_Time__c - NOW() &gt; 1,

Text_Opt_Out__c &lt;&gt; TRUE 

)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SMS_Notification</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Appointment__c.Appointment_Date_Time__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Mobile on Appointment</fullName>
        <actions>
            <name>Mobile_for_SMS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Id &lt;&gt; NULL</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>SMS_Notification</fullName>
        <assignedToType>owner</assignedToType>
        <description>SMS-Notification-Appointment__c-8efd</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Appointment__c.Appointment_Date_Time__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Closed</status>
        <subject>SMS Notification</subject>
    </tasks>
</Workflow>
