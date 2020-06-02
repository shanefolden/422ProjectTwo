<?php

include('connectionData.txt');

$conn = mysqli_connect($server, $user, $pass, $dbname, $port)
or die('Error connecting to MySQL server.');
?>

<!--
GROUP 5 - PROJECT 2 Line Time BACKEND PHP PAGE -> USERS ENTER THE TIME THEY SPENT IN LINE AT A BUSINESS
Created: 5/30/20
Last Modified: 5/31/20
Authors: Mason Jones (MJ)
-->

<html>
<head>
  <title>Group 5 - CIS 422 Project 2</title>
  </head>

  <body bgcolor="#84828F">

  <hr>


<?php

$addr = $_POST['l_addr'];
$wait = $_POST['l_wait'];
$date = $_POST['l_date'];
$time = $_POST['l_time'];

$addr = mysqli_real_escape_string($conn, $addr);
$wait = mysqli_real_escape_string($conn, $wait);
$date = mysqli_real_escape_string($conn, $date);
$time = mysqli_real_escape_string($conn, $time);
// this is a small attempt to avoid SQL injection
// better to use prepared statements

$query = "INSERT INTO `Line_Time_Data` (`Location_addr`,`Line_wait`,`Line_date`,`Line_time`) VALUES ('";
$query = $query.$addr."','".$wait."','".$date."','".$time."');";

$result = mysqli_query($conn, $query)
or die(mysqli_error($conn));

mysqli_free_result($result);

mysqli_close($conn);

?>

</p>
<hr>
</body>
</html>
