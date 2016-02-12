<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Partner_confirmed_ensure_ERP_setup_is_complete</fullName>
        <ccEmails>ap@sunrun.com</ccEmails>
        <description>New Partner confirmed: ensure ERP setup is complete</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Finance/New_Partner_Confirmed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Copy_Latitude_to_Geolocation_Field</fullName>
        <field>Billing_Address_Location__Latitude__s</field>
        <formula>Latitude__c</formula>
        <name>Copy Latitude to Geolocation Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Longitude_to_Geolocation_Field</fullName>
        <field>Billing_Address_Location__Longitude__s</field>
        <formula>Longitude__c</formula>
        <name>Copy Longitude to Geolocation Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Copy Latitude%2FLongitude to Geolocation Field</fullName>
        <actions>
            <name>Copy_Latitude_to_Geolocation_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Longitude_to_Geolocation_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Partner Confirmed</fullName>
        <actions>
            <name>New_Partner_confirmed_ensure_ERP_setup_is_complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Stage__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate AccountId-Name External Id</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
