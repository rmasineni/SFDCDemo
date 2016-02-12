<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Referral_Payment_Made_Referee</fullName>
        <description>Referral Payment Made Referee</description>
        <protected>false</protected>
        <recipients>
            <field>Target_Contact_Id__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Alert_Pilot_Sales_Rep_Alerts/Referral_Alert_Referee</template>
    </alerts>
    <alerts>
        <fullName>Referral_Payment_Made_Referee2</fullName>
        <description>Referral Payment Made Referee</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Alert_Pilot_Sales_Rep_Alerts/Referral_Alert_Referee</template>
    </alerts>
    <alerts>
        <fullName>Referral_Payment_Made_Referrrer</fullName>
        <description>Referral Payment Made Referrrer</description>
        <protected>false</protected>
        <recipients>
            <field>Sales_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Referral_Alert_Pilot_Sales_Rep_Alerts/Referral_Alert_Referrer</template>
    </alerts>
    <rules>
        <fullName>Referral Payment Made Referee</fullName>
        <actions>
            <name>Referral_Payment_Made_Referee2</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(NOT(ISBLANK(TEXT(Referee_Status_1__c ))),  OR(   (ISPICKVAL  (Service_Contract__r.Opportunity__r.Sales_Representative__r.Division__c, &quot;Inside Sales&quot;)  ),   ((ISPICKVAL(Service_Contract__r.Opportunity__r.Sales_Representative__r.Branch_Location__c,&quot;New York&quot;))),   ((ISPICKVAL(Service_Contract__r.Opportunity__r.Sales_Representative__r.Branch_Location__c,&quot;New Jersey&quot;)))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Referral Payment Made Referrer</fullName>
        <actions>
            <name>Referral_Payment_Made_Referrrer</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(  (ISPICKVAL(Referrer_Status_1__c,  &quot;Paid&quot;)),  OR(   (ISPICKVAL  (Service_Contract__r.Opportunity__r.Sales_Representative__r.Division__c , &quot;Inside Sales&quot;)  ),   ((ISPICKVAL(Service_Contract__r.Opportunity__r.Sales_Representative__r.Branch_Location__c,&quot;New York&quot;))),   ((ISPICKVAL(Service_Contract__r.Opportunity__r.Sales_Representative__r.Branch_Location__c,&quot;New Jersey&quot;)))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
