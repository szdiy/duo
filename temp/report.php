<?php
$time = strtotime("2017-09-22 00:00:00");
$node = 'TEST';
$total = 12759;

for ($i=0; $i < 288; $i++) {
    $t = $time + $i * 300;
    $total = $total + rand(0, 5);
    $url = "http://localhost:8000/duo/upload?node=$node&total=$total&time=$t";
    echo file_get_contents($url);
    echo "\n";
}
