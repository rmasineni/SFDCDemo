trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
	
    //Below service calls integrates the Account with AddressService to standardize the address.
    Sf.addressService.handleAccountsTrigger();
    
    Sf.awsSyncService.handleAccountsTrigger();
    
    Sf.coreLogicService.handleAccountsTrigger();
}