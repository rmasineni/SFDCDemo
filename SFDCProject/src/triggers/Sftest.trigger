trigger Sftest on User (after update) {
user u = new user();
if(u.DefaultDivision=='02d550000008OMb'){
u.User_Division_Custom__c='02d550000008OMbAAM';
}else{
u.User_Division_Custom__c='02d550000008OMgAAM';
}


}