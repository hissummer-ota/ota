<?php
$allversions=array();
$dversions=array();
$sversions=array();
$filearray=file("/opt/app/qa-site/ota/android/version.dat");
foreach ($filearray as &$value) {
    $firstl = $value[0];
    if(is_numeric($firstl)){
    array_push($dversions, $value);
    }
   else array_push($sversions,$value);
}

sort($sversions);
rsort($dversions);
$allversions=array_merge($sversions,$dversions);

print_r($allversions);

?>
