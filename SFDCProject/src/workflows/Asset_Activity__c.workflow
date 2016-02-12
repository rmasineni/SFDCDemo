<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_VER_of_meter_test_SC</fullName>
        <ccEmails>sr.ops@yopmail.com</ccEmails>
        <description>Notify VER of meter test (SC)</description>
        <protected>false</protected>
        <recipients>
            <recipient>ashleys@sunrunhome.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Notify_VER_of_meter_test_SC</template>
    </alerts>
    <rules>
        <fullName>Notify VER of meter test</fullName>
        <actions>
            <name>Notify_VER_of_meter_test_SC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( Meter_Registration_Date__c &lt;&gt; NULL, Asset__r.ServiceContract__r.Install_Partner__c = &apos;Verengo&apos; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
