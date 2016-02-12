<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Audit_Denied</fullName>
        <description>Audit Denied</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Audit_Denied</template>
    </alerts>
    <alerts>
        <fullName>Audit_Rejected</fullName>
        <description>Audit Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Auditor_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Audit_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Audit_Resubmitted</fullName>
        <description>Audit Resubmitted</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Audit_Resubmitted</template>
    </alerts>
    <alerts>
        <fullName>Audit_SR_Approved</fullName>
        <description>Audit SR Approved</description>
        <protected>false</protected>
        <recipients>
            <field>Auditor_Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Audit_SR_Approved</template>
    </alerts>
    <alerts>
        <fullName>Audit_Submitted</fullName>
        <description>Audit Submitted</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Audit_Submitted</template>
    </alerts>
    <fieldUpdates>
        <fullName>Timestamp_Date_Approved</fullName>
        <field>Date_Approved__c</field>
        <formula>IF(ISPICKVAL(Status__c, &apos;SR Approved&apos;), Today(), null)</formula>
        <name>Timestamp Date Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Audit - Denied</fullName>
        <actions>
            <name>Audit_Denied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email notifcation to fleet ops</description>
        <formula>AND(ISCHANGED( Status__c),  ISPICKVAL(Status__c,&quot;Denied&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Audit - Rejected</fullName>
        <actions>
            <name>Audit_Rejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email notification to auditor</description>
        <formula>AND(ISCHANGED(Status__c),  ISPICKVAL(Status__c,&quot;Rejected&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Audit - Resubmitted</fullName>
        <actions>
            <name>Audit_Resubmitted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email notifcation to fleet ops</description>
        <formula>AND(ISCHANGED( Status__c),  ISPICKVAL(Status__c,&quot;Submitted&quot;),  ISPICKVAL(PRIORVALUE(Status__c), &quot;Rejected&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Audit - SR Approved</fullName>
        <actions>
            <name>Audit_SR_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email notifcation</description>
        <formula>AND(ISCHANGED( Status__c),  ISPICKVAL(Status__c,&quot;SR Approved&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Audit - Submitted</fullName>
        <actions>
            <name>Audit_Submitted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email notifcation to fleet ops</description>
        <formula>AND(ISCHANGED( Status__c),  ISPICKVAL(Status__c,&quot;Submitted&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Timestamp date on Install Audit Status</fullName>
        <actions>
            <name>Timestamp_Date_Approved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Install_Audit__c.Status__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Install_Audit__c.Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
