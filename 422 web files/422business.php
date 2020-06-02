<?php

include('connectionData.txt');

$conn = mysqli_connect($server, $user, $pass, $dbname, $port)
or die('Error connecting to MySQL server.');
?>

<!--
GROUP 5 - PROJECT 2 Business BACKEND PHP PAGE
Created: 5/31/20
Last Modified: 6/1/20
Authors: Primary: Mason Jones (MJ), Secondary: Man Him Fung (MF)
-->

<html>
<head>
  <title>Group 5 - CIS 422 Project 2 Business Backend</title>
  </head>

<body bgcolor="#84828F">

  <hr>
<p>
<?php
//Get the business address
$business = $_POST['b_addr'];
$business = mysqli_real_escape_string($conn, $business);


/*      AVERAGE TIME SPENT AT A LOCATION        */
$query = "SELECT ROUND(sum(Time_at_Location)/count(Identity),2 ) as ave_time_at FROM Geospatial_Data as Geo right join Business on ABS(ABS(Geo.Latitude) - ABS(Business.latitude)) <= ABS(0.00027) and ABS(ABS(Geo.Longitude) - ABS(Business.longitude)) <= ABS(0.00035) where weekday(Date) = weekday(curdate()) and HOUR(Time) = hour(current_time()) and addr = '";
$query = $query.$business."';";

?>
</p>

<p>
The query:
<p>
<?php
print $query;
?>

<p>
Result:
<p>
<?php
$result = $conn->query($query);
print "<pre>\n";
print "Business: $business\n";
while($row = $result->fetch_assoc())
{
        $avg_t = $row[ave_time_at];
        print "Average time: $row[ave_time_at]\n";
}
print "</pre>\n";

/*      UPDATE THIS BUSINESS' AVERAGE TIME SPENT AT LOCATION        */
$update2 = "UPDATE `CIS422_Project1`.`Business` SET `avg_time` = '";
$update2 = $update2.$avg_t."' WHERE (`addr` = '";
$update2 = $update2.$business."');";

$res_upd2 = $conn->query($update2);

mysqli_free_result($result);
mysqli_free_result($res_upd2);
?>



<?php
/*      NUMBER OF USERS AT BUSINESS FOR THE CURRENT HOUR        */
$query2 = "SELECT count(Identity) as number_user_per_location FROM Geospatial_Data as Geo
right join Business on ABS(ABS(Geo.Latitude) - ABS(Business.latitude)) <= ABS(0.00027) and ABS(ABS(Geo.Longitude) - ABS(Business.longitude)) <= ABS(0.00035)
where weekday(Date) = weekday(curdate()) and HOUR(Time) = hour(current_time()) and addr = '";
$query2 = $query2.$business."';";
?>
<p>
The query2:
<p>
<?php
print $query2;
?>
<p>
Result 2:
<p>
<?php
$result2 = $conn->query($query2);
print "<pre>\n";
while($row = $result2->fetch_assoc())
{
        $upl = $row[number_user_per_location];
        print "Users at this business over the past hour: $row[number_user_per_location]\n";
}
print "</pre>\n";

/*      UPDATE THIS BUSINESS' POPULATION        */
$update1 = "UPDATE `CIS422_Project1`.`Business` SET `population` = '";
$update1 = $update1.$upl."' WHERE (`addr` = '";
$update1 = $update1.$business."');";

$res_upd1 = $conn->query($update1);

mysqli_free_result($result2);
mysqli_free_result($res_upd1);
?>

<?php
/*      AVERAGE PEAK FOOT TRAFFIC FOR THE HOUR - Evaluates all curr_days (ex: mondays) at the current hour (ex: 6:00-7:00pm)    */
$query3 = "SELECT count(Identity)/((max(Date)-min(Date)+7)/7) as ave_foot  FROM Geospatial_Data as Geo
right join Business on ABS(ABS(Geo.Latitude) - ABS(Business.latitude)) <= ABS(0.00027) and ABS(ABS(Geo.Longitude) - ABS(Business.longitude)) <= ABS(0.00035)
where weekday(Date) = weekday(curdate()) and HOUR(Time) = hour(current_time()) and addr = '";
$query3 = $query3.$business."';";
?>
<p>
The query3:
<p>
<?php
print $query3;
?>
<p>
Result 3:
<p>
<?php
$result3 = $conn->query($query3);
print "<pre>\n";
while($row = $result3->fetch_assoc())
{
        $avg_pop = $row[ave_foot];
        print "There are typically this many users here at this time: $row[ave_foot]\n";
}
print "</pre>\n";
mysqli_free_result($result3);

/*      UPDATE BUSINESS' AVERAGE POPULATION      */
$update4 = "UPDATE `CIS422_Project1`.`Business` SET `avg_pop` = '";
$update4 = $update4.$avg_pop."' WHERE (`addr` = '";
$update4 = $update4.$business."');";

$res_upd4 = $conn->query($update4);

mysqli_free_result($res_upd4);
?>

<?php
/*      AVERAGE TIME SPENT IN LINE FOR THIS BUSINESS    */
$query4 = "select TRUNCATE(AVG(Line_wait),1) as avg_line_time FROM Line_Time_Data WHERE WEEKDAY(Line_date) = WEEKDAY(curdate()) and HOUR(Line_time)  = HOUR(current_time()) and Location_addr = '";
$query4 = $query4.$business."';";
?>
<p>
The query4:
<p>
<?php
print $query4;
?>
<p>
Result 4:
<p>
<?php
$result4 = $conn->query($query4);
print "<pre>\n";
while($row = $result4->fetch_assoc())
{
        $line_t = $row[avg_line_time];
        print "People have been spending this many minutes in line at the store recently: $row[avg_line_time]\n";
}
print "</pre>\n";
mysqli_free_result($result4);

/*      UPDATE BUSINESS' LINE TIME      */
$update3 = "UPDATE `CIS422_Project1`.`Business` SET `line_time` = '";
$update3 = $update3.$line_t."' WHERE (`addr` = '";
$update3 = $update3.$business."');";

$res_upd3 = $conn->query($update3);

mysqli_free_result($res_upd3);
mysqli_close($conn);
?>

<hr>
</body>
</html>