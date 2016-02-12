public class FormatDateTime {
    public DateTime dateTimeValue { get; set; }
    public String getTimeZoneValue() {
        if( dateTimeValue != null ) {
            String localeFormatDT = dateTimeValue.format('h:mm a');
            return localeFormatDT;
        }
        return null;
    }
}