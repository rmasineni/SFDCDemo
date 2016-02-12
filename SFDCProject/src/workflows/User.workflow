<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AO_Nullify</fullName>
        <field>Assignment_Order__c</field>
        <name>AO Nullify</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>User_Deactivated</fullName>
        <field>User_Deactivated__c</field>
        <formula>now()</formula>
        <name>User Deactivated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <flowActions>
        <fullName>User_Updates</fullName>
        <description>When a new user is created, this Flow automatically updates a variety of settings/related components depending upon the type of user (assigns Remedyforce permission set, Remedyforce licnese, assigns Work.com permsision set, sets as Knowledge user, etc.</description>
        <flow>User_updates</flow>
        <flowInputs>
            <name>ProfileID</name>
            <value>{!ProfileId}</value>
        </flowInputs>
        <flowInputs>
            <name>UserDivision</name>
            <value>{!Division}</value>
        </flowInputs>
        <flowInputs>
            <name>UserEmail</name>
            <value>{!Email}</value>
        </flowInputs>
        <flowInputs>
            <name>UserFirstName</name>
            <value>{!FirstName}</value>
        </flowInputs>
        <flowInputs>
            <name>UserID</name>
            <value>{!Id}</value>
        </flowInputs>
        <flowInputs>
            <name>UserLastName</name>
            <value>{!LastName}</value>
        </flowInputs>
        <flowInputs>
            <name>UserProfileName</name>
            <value>{!Profile.Name}</value>
        </flowInputs>
        <flowInputs>
            <name>UserTitle</name>
            <value>{!Title}</value>
        </flowInputs>
        <label>User Updates</label>
        <language>en_US</language>
        <protected>false</protected>
    </flowActions>
    <rules>
        <fullName>Execute User Flow</fullName>
        <actions>
            <name>User_Updates</name>
            <type>FlowAction</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Standard</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When a new user is created, this Flow automatically updates a variety of settings/related components depending upon the type of user (assigns Remedyforce permission set, Remedyforce licnese, assigns Work.com permsision set, sets as Knowledge user, etc.)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Null AO if User is Inactive</fullName>
        <actions>
            <name>AO_Nullify</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Null out Assignment Order if User is inactive</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TEst SFDC</fullName>
        <active>false</active>
        <criteriaItems>
            <field>User.DefaultDivision</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>User Deactivated</fullName>
        <actions>
            <name>User_Deactivated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IsActive =false &amp;&amp; ISCHANGED(IsActive)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
