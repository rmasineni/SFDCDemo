public class SeriesChartData {
    
    public String name { get; set; }
    public Integer data1 { get; set; }
    public Integer data2 { get; set; }
    public Integer data3 { get; set; }
    public SeriesChartData(String name, Integer data1, Integer data2, Integer data3) {
        this.name = name;
        this.data1 = data1;
        this.data2 = data2;
        this.data3 = data3;
    }

}