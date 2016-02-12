public class controller_formatted_datetime
{
public DateTime date_time { get; set; } //property that reads the datetime value from component attribute tag
public String defined_format { get; set;} //property that reads the string value from component attribute tag
public String getFormattedDatetime()
{
if (date_time == null) {return ''; }
else { if (defined_format == null) {
return date_time.format(); //return the full date/time in user's locale and time zone
}
else { return date_time.format(defined_format);  //Specify Time zone like IST,CST
}}}}