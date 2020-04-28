<?php

include('connectionData.txt');

$conn = mysqli_connect($server, $user, $pass, $dbname, $port)
or die('Error connecting to MySQL server.');
?>

<!--
GROUP 5 - PROJECT 1 BACKEND PHP PAGE
Created: 4/19/20
Last Modified: 4/27/20
Authors: Secondary:Man Him Fung (MF), Primary:Mason Jones (MJ)	
-->

<html>
<head>
  <title>Group 5 - CIS 422 Project 1</title>
  </head>
  
  <body bgcolor="#84828F">
  
  <hr>
  
  
<?php
  
$userID = $_POST['userId'];
$date = $_POST['tDate'];
$time = $_POST['tTime'];
$lat = $_POST['tLatitude'];
$lon = $_POST['tLongitude'];
//$taloc = $_POST['tTAL'];	

$userID = mysqli_real_escape_string($conn, $userID);
$date = mysqli_real_escape_string($conn, $date);
$time = mysqli_real_escape_string($conn, $time);
$lat = mysqli_real_escape_string($conn, $lat);
$lon = mysqli_real_escape_string($conn, $lon);
//$taloc = mysqli_real_escape_string($conn, $taloc);

// this is a small attempt to avoid SQL injection
// better to use prepared statements

$query = "INSERT INTO `Geospatial_Data` (`Identity`,`Date`,`Time`,`Latitude`,`Longitude`) VALUES ('";
$query = $query.$userID."','".$date."','".$time."','".$lat."','".$lon."');";

$result1 = mysqli_query($conn, $query)
or die(mysqli_error($conn));

?>

<?php
$result2 = $conn->query("SELECT dg.Identity AS ID , dg.Date AS date, MAX(dg.Time) AS Recent_Time, dg.Latitude AS latitude, dg.Longitude AS longitude, dg.Time_at_Location AS time_at FROM (SELECT g1.* FROM Geospatial_Data AS g1 LEFT JOIN Geospatial_Data AS g2 ON g1.Identity = g2.Identity AND g1.Date < g2.Date WHERE g2.Identity IS NULL ) AS dg GROUP BY dg.Identity ORDER BY date DESC, Recent_Time DESC ");

$dbdata = array();

#writing into json
  $fp = fopen('results.json','w');
  fwrite($fp, "{
        \"type\": \"FeatureCollection\",
        \"features\": [
          ");
  while($row = $result2->fetch_assoc()){
     fwrite($fp,"   {\"type\": \"Feature\",
        \"geometry\": {
                \"type\": \"Point\",
              \"coordinates\": [$row[longitude], $row[latitude]]
            },
            \"properties\": {
                 \"Identity\":\"$row[ID]\",
                 \"Date\":\"$row[date]\",
                 \"Time\":\"$row[Recent_Time]\",
                 \"Time_at_Location\":\"$row[time_at]\"
         }}," );
  }

  #fwrite($fp, json_encode($dbdata));
  fwrite($fp, "{}]}");

  fclose($fp);


mysqli_free_result($result1);
mysqli_free_result($result2);

mysqli_close($conn);

?>

</p>
<hr>
<!--
<p>
<a href="findStockDesc.txt" >Contents</a>
of the PHP program that created this page. 	 
--> 
</body>
</html>
	  
