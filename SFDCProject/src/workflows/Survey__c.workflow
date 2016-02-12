<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CSAT_Check_Contact_Happy_Customer</fullName>
        <description>When CSAT results come in, the customers who give us 10 on the question: &quot;How likely are you to recommend Sunrun?&quot;) should be marked as Happy Customers in their Contact, so that Customer Care can be aware.</description>
        <field>Happy_Customer__c</field>
        <literalValue>1</literalValue>
        <name>CSAT - Check Contact:&quot;Happy Customer&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSAT_Check_Contact_Unhappy_Customer</fullName>
        <description>When CSAT results come in, the customers who are Detractors (give us 0-6 on the question: &quot;How likely are you to recommend Sunrun?&quot;) should be marked as Unhappy Customers in their Contact, so that Customer Care can be aware of the situation.</description>
        <field>Unhappy_Customer__c</field>
        <literalValue>1</literalValue>
        <name>CSAT - Check Contact:&quot;Unhappy Customer&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSAT_UnCheck_Contact_Happy_Customer</fullName>
        <field>Happy_Customer__c</field>
        <literalValue>0</literalValue>
        <name>CSAT - UnCheck Contact:&quot;Happy Customer&quot;</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSAT_UnCheck_Contact_Unhappy_Customer</fullName>
        <field>Unhappy_Customer__c</field>
        <literalValue>0</literalValue>
        <name>CSAT - UnCheck Contact:Unhappy Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Unhappy</fullName>
        <description>This action changes all detractors to &quot;Unhappy Customers&quot;.</description>
        <field>Unhappy_Customer__c</field>
        <name>Unhappy</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>Contact__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>CSAT - Update Contact%3A%22Happy Customer%22</fullName>
        <actions>
            <name>CSAT_Check_Contact_Happy_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CSAT_UnCheck_Contact_Unhappy_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When CSAT results come in, the customers who give us 10 on the question: &quot;How likely are you to recommend Sunrun?&quot;) should be marked as Happy Customers in their Contact, so that Customer Care can be aware.</description>
        <formula>OR( AND(ISCHANGED(X1M_Recommend_SunRun__c), X1M_Recommend_SunRun__c = 10), AND(ISCHANGED(X6M_Recommend_Sunrun__c), X6M_Recommend_Sunrun__c = 10), AND(ISCHANGED(X12M_Recommend_Sunrun__c), X12M_Recommend_Sunrun__c = 10), AND(ISCHANGED(X18M_Recommend_Sunrun__c), X18M_Recommend_Sunrun__c = 10), AND(ISCHANGED(X24M_Recommend_Sunrun__c), X24M_Recommend_Sunrun__c = 10), AND(ISCHANGED(X30M_Recommend_Sunrun__c), X30M_Recommend_Sunrun__c = 10), AND(ISCHANGED(X42M_Recommend_Sunrun__c), X42M_Recommend_Sunrun__c = 10), AND(ISCHANGED(X54M_Recommend_Sunrun__c), X54M_Recommend_Sunrun__c = 10), AND(ISCHANGED(X66M_Recommend_Sunrun__c), X66M_Recommend_Sunrun__c = 10), AND(ISCHANGED(X78M_Recommend_Sunrun__c), X78M_Recommend_Sunrun__c = 10))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CSAT - Update Contact%3A%22Unhappy Customer%22</fullName>
        <actions>
            <name>CSAT_Check_Contact_Unhappy_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CSAT_UnCheck_Contact_Happy_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When CSAT results come in, the customers who are Detractors (give us 0-6 on the question: &quot;How likely are you to recommend Sunrun?&quot;) should be marked as Unhappy Customers in their Contact, so that Customer Care can be aware of the situation.</description>
        <formula>OR( AND(ISCHANGED(X1M_Recommend_SunRun__c), X1M_Recommend_SunRun__c &lt; 7), AND(ISCHANGED(X6M_Recommend_Sunrun__c), X6M_Recommend_Sunrun__c &lt; 7), AND(ISCHANGED(X12M_Recommend_Sunrun__c), X12M_Recommend_Sunrun__c &lt; 7), AND(ISCHANGED(X18M_Recommend_Sunrun__c), X18M_Recommend_Sunrun__c &lt; 7), AND(ISCHANGED(X24M_Recommend_Sunrun__c), X24M_Recommend_Sunrun__c &lt; 7), AND(ISCHANGED(X30M_Recommend_Sunrun__c), X30M_Recommend_Sunrun__c &lt; 7), AND(ISCHANGED(X42M_Recommend_Sunrun__c), X42M_Recommend_Sunrun__c &lt; 7), AND(ISCHANGED(X54M_Recommend_Sunrun__c), X54M_Recommend_Sunrun__c &lt; 7), AND(ISCHANGED(X66M_Recommend_Sunrun__c), X66M_Recommend_Sunrun__c &lt; 7), AND(ISCHANGED(X78M_Recommend_Sunrun__c), X78M_Recommend_Sunrun__c &lt; 7))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sunrun Detractor</fullName>
        <active>false</active>
        <booleanFilter>(1 or 2) or (3 or 4) or (5 or 6) or (7 or 8) or 9</booleanFilter>
        <criteriaItems>
            <field>Survey__c.X6M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Survey__c.X12M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Survey__c.X18M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Survey__c.X24M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Survey__c.X30M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Survey__c.X42M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Survey__c.X54M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Survey__c.X66M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <criteriaItems>
            <field>Survey__c.X78M_Recommend_Sunrun__c</field>
            <operation>lessThan</operation>
            <value>7</value>
        </criteriaItems>
        <description>Rule for identifying Sunrun Detractors.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
