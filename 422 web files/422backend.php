<?php

include('connectionData.txt');

$conn = mysqli_connect($server, $user, $pass, $dbname, $port)
or die('Error connecting to MySQL server.');
?>
<!-- NEW COMMENT YO -->
<!--
GROUP 5 - PROJECT 2 BACKEND PHP PAGE
Created: 4/19/20
Last Modified: 6/1/20
Authors: Secondary:Man Him Fung (MF), Primary:Mason Jones (MJ)
-->

<html>
<head>
  <title>Group 5 - CIS 422 Project 2</title>
</head>

<body bgcolor="#84828F">

<hr>


<?php
/*      THIS IS WHERE NEW GEOLOCATION DATA IS INSERTED INTO THE GEOSPATIAL_DATA TABLE   */
$userID = $_POST['userId'];
$date = $_POST['tDate'];
$time = $_POST['tTime'];
$lat = $_POST['tLatitude'];
$lon = $_POST['tLongitude'];
$taloc = $_POST['tTimeAtLocation'];

$business_addr = $_POST['b_addr'];

$userID = mysqli_real_escape_string($conn, $userID);
$date = mysqli_real_escape_string($conn, $date);
$time = mysqli_real_escape_string($conn, $time);
$lat = mysqli_real_escape_string($conn, $lat);
$lon = mysqli_real_escape_string($conn, $lon);
$taloc = mysqli_real_escape_string($conn, $taloc);
$business_addr = mysqli_real_escape_string($conn, $business_addr);

// this ^^^ is a small attempt to avoid SQL injection
// better to use prepared statements

$query = "INSERT INTO `Geospatial_Data` (`Identity`,`Date`,`Time`,`Latitude`,`Longitude`,`Time_at_Location`) VALUES ('";
$query = $query.$userID."','".$date."','".$time."','".$lat."','".$lon."','".$taloc."');";

$result1 = mysqli_query($conn, $query)
or die(mysqli_error($conn));

?>

<?php
/*      THIS IS WHERE THE JSON FILE USED FOR DISPLAYING USER MARKERS IS CREATED */
$result2 = $conn->query("SELECT * FROM (SELECT Identity as ID, Date as date, Time as Recent_Time, Latitude as latitude, Longitude as longitude, Time_at_Location as time_at FROM Geospatial_Data ORDER BY Date DESC, Time DESC LIMIT 99999999) AS g1 WHERE date = curDate() GROUP BY g1.ID;");

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

  //fwrite($fp, json_encode($dbdata));
  fwrite($fp, "{}]}");  //this adds an empty feature in order to ignore the last comma in our auto generated file. this allows it to be found as a distinct substring. it will now be removed.

  //copy file text to string variable
  $cont = file_get_contents('results.json');
  //replace end of string with the proper end of string
  $cont = str_replace("}},{}]}","}}]}",$cont);
  //put edited text back into file
  file_put_contents('results.json', $cont);
  //close file
  fclose($fp);

?>

<?php
  /*    THIS IS WHERE THE TAB DELIMITED TEXT FILE IS CREATED    */
  $result3 = $conn->query("SELECT * FROM Geospatial_Data ORDER BY Date DESC, TIME DESC ");

  $fp2 = fopen('Query_result.txt','w');
  while($row2 = $result3->fetch_assoc()){
        fwrite($fp2,"$row2[Identity]\t$row2[Date]\t$row2[Time]\t$row2[Latitude]\t$row2[Longitude]\t$row2[Time_at_Location]\n" );
        fwrite($fp2, "");
  }
  fclose($fp2);

?>

<?php
  /*    THIS IS WHERE THE JSON FILE USED FOR DISPLAYING BUSINESS MARKERS IS CREATED     */
//fetch all businesses in the database
$result4 = $conn->query("SELECT * FROM Business;");

$dbdata2 = array();

//write all businesses into a json file
  $fp3 = fopen('business.json','w');
  fwrite($fp3, "{
        \"type\": \"FeatureCollection\",
        \"features\": [
          ");
  while($row = $result4->fetch_assoc()){
     fwrite($fp3,"   {\"type\": \"Feature\",
        \"geometry\": {
                \"type\": \"Point\",
              \"coordinates\": [$row[longitude], $row[latitude]]
            },
            \"properties\": {
                 \"Name\":\"$row[name]\",
                 \"Address\":\"$row[addr]\",
                 \"People\":\"$row[population]\",
                 \"Average_Time\":\"$row[avg_time]\",
                 \"Line_Time\":\"$row[line_time]\",
                 \"Avg_Pop\":\"$row[avg_pop]\"
         }}," );
  }

  #fwrite($fp, json_encode($dbdata));
  fwrite($fp3, "{}]}");  //this adds an empty feature in order to ignore the last comma in our auto generated file. this allows it to be found as a distinct substring. it will now be removed.

  //copy file text to string variable
  $cont2 = file_get_contents('business.json');
  //replace end of string with the proper end of string
  $cont2 = str_replace("}},{}]}","}}]}",$cont2);
  //put edited text back into file
  file_put_contents('business.json', $cont2);

  fclose($fp3);

  mysqli_free_result($result1);
  mysqli_free_result($result2);
  mysqli_free_result($result3);
  mysqli_free_result($result4);

  mysqli_close($conn);

?>
</body>
</html>