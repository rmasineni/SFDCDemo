/*
 * Class        : PaginationHelper
 * Developer/Org: Peter Alexander Mandy
 * Created      : September 07, 2013
 * Objective    : Class for creating and processing lists of sObjects for "Pagination"(displaying lists on visualforce pages)
*/
public with sharing class PaginationHelper {

 /*
   * Wraps a list sObjects in a StandardSetController.
   * @param list<sObject> records, Integer pageSize
   * @return ApexPages.StandardSetController
  */
  public static ApexPages.StandardSetController getStdSetController(list<sObject> records, Integer pageSize){
    if(records != null){
      ApexPages.StandardSetController stdSetCtr = new ApexPages.StandardSetController(records);
      stdSetCtr.setPageSize(pageSize);
      return stdSetCtr;
    }
    return null;
  }

  /*
   * Method called in order to iterate to next "page" in list of set controller.
   * @param ApexPages.StandardSetController stdSetCtrl
   * @return List<SObject>
  */
  public static List<SObject> getNextSetOfRecords(ApexPages.StandardSetController stdSetCtrl){
    stdSetCtrl.next();
    return stdSetCtrl.getRecords();
  }

  /*
   * Method called in order to iterate to previous "page" in list of set controller.
   * @param ApexPages.StandardSetController stdSetCtrl
   * @return List<SObject>
  */
  public static List<SObject> getPreviousSetOfRecords(ApexPages.StandardSetController stdSetCtrl){
    stdSetCtrl.previous();
    return stdSetCtrl.getRecords();
  }
  
  /*
   * Method called to find total pages in StandardSetController
   * @param ApexPages.StandardSetController stdSetCtrl
   * @return Integer
  */
  public static Integer getTotalNumberOfPages(ApexPages.StandardSetController stdSetCtrl){
    return integer.valueOf(math.ceil((decimal.valueOf(stdSetCtrl.getResultSize())/decimal.valueOf(stdSetCtrl.getPageSize()))));
  }
}