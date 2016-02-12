public Class CheckRecursiveTrigger{
    public static boolean sceventrunonce  = false;
    private static boolean run = true;
    private static boolean SCrun = true;
    
 /*   public static boolean checkemail(){
        sceventrunonce = true;
        return sceventrunonce;
    }
*/
    public static boolean checkemail(){
    if(sceventrunonce == false){
     sceventrunonce = true;
     return false;
    }else{
        return sceventrunonce;
    }
    }
    
    public static boolean runOnce(){
    if(run){
     run=false;
     return true;
    }else{
        return run;
    }
    }
    public static boolean SCrunOnce(){
    if(SCrun){
     SCrun=false;
     return true;
    }else{
        return SCrun;
    }
    }
    public static void resetRunOnceFlag() {
    run = true;
    }
}