public class PieWedgeData {

    public String name { get; set; }
    public Integer data { get; set; }

    public PieWedgeData(String name, Integer data) {
        this.name = name;
        this.data = data;
    }
    
    @isTest (SeeAllData=true)
    public static void testPieWedgeData(){
        String name = 'Name';
        Integer data = 10;
        
        PieWedgeData obj = new PieWedgeData(name,data);
    }

}