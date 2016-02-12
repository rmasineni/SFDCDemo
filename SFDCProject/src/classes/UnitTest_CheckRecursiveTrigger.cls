@isTest
public with sharing class UnitTest_CheckRecursiveTrigger{
    static testmethod void UnitTest_CheckRecursiveTrigger(){
    CheckRecursiveTrigger.checkemail();
    CheckRecursiveTrigger.runOnce();
    CheckRecursiveTrigger.SCrunOnce();
    CheckRecursiveTrigger.resetRunOnceFlag();
    }
    }