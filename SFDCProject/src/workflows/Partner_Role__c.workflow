<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Do_not_share_with_Sunrun_Oppty</fullName>
        <field>Share_w_Sunrun__c</field>
        <literalValue>0</literalValue>
        <name>Do not share with Sunrun (Oppty)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Market</fullName>
        <field>Market__c</field>
        <formula>Opportunity__r.Market_Assignment_Sales__r.Market__r.Name</formula>
        <name>Populate Market</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Market_Assignment</fullName>
        <field>Market_Assignment__c</field>
        <formula>Opportunity__r.Market_Assignment_Sales__r.Name</formula>
        <name>Populate Market Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Market_Assignment_Install</fullName>
        <field>Market_Assignment__c</field>
        <formula>Opportunity__r.Market_Assignment_Install__r.Name</formula>
        <name>Populate Market Assignment Install</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Market_Install</fullName>
        <field>Market__c</field>
        <formula>Opportunity__r.Market_Assignment_Install__r.Market__r.Name</formula>
        <name>Populate Market Install</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Partner_Performance_Adder</fullName>
        <field>Performance_adder__c</field>
        <formula>Opportunity__r.Market_Assignment_Sales__r.Partner_Performance_Adder__c</formula>
        <name>Populate Partner Performance Adder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Partner_Performance_Adder_Inst</fullName>
        <field>Performance_adder__c</field>
        <formula>Opportunity__r.Market_Assignment_Install__r.Partner_Performance_Adder__c</formula>
        <name>Populate Partner Performance Adder Inst</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_SunRun_Fee_Adder</fullName>
        <field>Sunrun_fee_adder__c</field>
        <formula>Opportunity__r.Market_Assignment_Sales__r.Sunrun_Fee_Adder__c</formula>
        <name>Populate SunRun Fee Adder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_SunRun_Fee_Adder_Install</fullName>
        <field>Sunrun_fee_adder__c</field>
        <formula>Opportunity__r.Market_Assignment_Install__r.Sunrun_Fee_Adder__c</formula>
        <name>Populate SunRun Fee Adder Install</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Share_with_Sunrun_Oppty</fullName>
        <field>Share_w_Sunrun__c</field>
        <literalValue>1</literalValue>
        <name>Share with Sunrun (Oppty)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Opportunity__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Rep_Division</fullName>
        <field>Sales_Rep_Division__c</field>
        <formula>TEXT(Opportunity__r.Sales_Representative__r.Division__c)</formula>
        <name>Update Sales Rep Division</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Rep_email</fullName>
        <field>Sales_Rep_Email__c</field>
        <formula>Opportunity__r.Sales_Representative__r.Email</formula>
        <name>Update Sales Rep email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Do not share with Sunrun %28Partner Roles%29</fullName>
        <actions>
            <name>Do_not_share_with_Sunrun_Oppty</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND (   NOT(Partner_Name__r.Name  = &quot;Sunrun&quot;),NOT(Partner_Name__r.Name=&quot;&quot;) , ISPICKVAL( Role__c , &quot;Sales&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Populate Install Partner Fields</fullName>
        <actions>
            <name>Populate_Market_Assignment_Install</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Market_Install</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Partner_Performance_Adder_Inst</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_SunRun_Fee_Adder_Install</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Role__c.Role__c</field>
            <operation>equals</operation>
            <value>Install</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Sales Email%2Fdiv for PT on PR</fullName>
        <actions>
            <name>Update_Sales_Rep_Division</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Sales_Rep_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Opportunity__r.Sales_Representative__c !=null</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Sales Partner Fields</fullName>
        <actions>
            <name>Populate_Market</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Market_Assignment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Partner_Performance_Adder</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_SunRun_Fee_Adder</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Partner_Role__c.Role__c</field>
            <operation>equals</operation>
            <value>Sales</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Share with Sunrun</fullName>
        <actions>
            <name>Share_with_Sunrun_Oppty</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(    OR( Partner_Name__r.Name = &quot;Sunrun&quot;, Partner_Name__r.Name = &quot;&quot;), ISPICKVAL(Role__c , &quot;Sales&quot;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
