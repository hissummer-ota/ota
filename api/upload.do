<?php


#die('{"message":"维护中，禁止上传!","status":1005}');

function IsNullOrEmptyString($questions){
    foreach ($questions as $question)
{
    if( (!isset($question) || trim($question)==='') )  return true;
    if( (strpos($question,",")) )  return true;
}
    return false;
    
}


function ConvertArray($questions){
    $keynum = 0;
    foreach ($questions as $question)
{
    $question = str_replace("\r\n","<br/>",$question);
    $question = str_replace("\n","<br/>",$question);
    $question = str_replace(",","/",$question);
    $questions[$keynum] = $question;
    #echo $questions[$keynum];
    $keynum ++;
}

    return $questions;
    
}

function GeneratePlist($filename)
{

$plistString = <<< PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>items</key>
<array>
<dict>
<key>assets</key>
<array>
<dict>
<key>kind</key>
<string>software-package</string>
<key>url</key>
<string>http://qa.heika.com/ota/ios/app/$filename</string>
</dict>
</array>
<key>metadata</key>
<dict>
<key>bundle-identifier</key>
<string>com.renrendai.heika</string>
<key>bundle-version</key>
<string>1.0</string>
<key>kind</key>
<string>software</string>
<key>title</key>
<string>$filename</string>
</dict>
</dict>
</array>
</dict>
</plist>
PLIST;

file_put_contents("/opt/app/qa-site/ota/ios/app/$filename.plist", $plistString);

#echo "plist generated!";

}


function AddVersion($version,$type)
{

#check the version is already exist or not
#exec("cat /opt/app/qa-site/ota/$type/version.dat | grep -i $version",$output);
#if(!(count($output) >0)) 
#exec("echo $version >> /opt/app/qa-site/ota/$type/version.dat");

$file="/opt/app/qa-site/ota/$type/version.dat";
$allversions=array();
$dversions=array();
$sversions=array();
$filearray=file($file);
foreach ($filearray as &$value) {
    
    $firstl = $value[0];
    if(is_numeric($firstl)){
    array_push($dversions,trim($value));
    }
   else array_push($sversions,trim($value));
}
$allversions=array_merge($sversions,$dversions);
if(in_array ( $version , $allversions)) return ;

if(is_numeric($version[0])) array_push($dversions,$version);
else array_push($sversions,$version);

sort($sversions);
rsort($dversions);
$allversions=array_merge($sversions,$dversions);

file_put_contents($file, implode("\n", $allversions));

}

function addLock()
{
$fplock = fopen("/opt/app/qa-site/ota/api/upload.lock", "r+");

if (flock($fplock, LOCK_EX|LOCK_NB)) {  // acquire an exclusive lock

} else {
sleep(1);
if (!flock($fplock, LOCK_EX|LOCK_NB))
    die('{"message":"有正在上传的应用，请稍后再试！","status":1004}');
}

return $fplock;

}
function removeLock($lock)
{
flock($lock, LOCK_UN); 
fclose($lock);

}

/*
status code:

1000 file upload error
1001 file exist 
1002 parameter errors
1003 
1004 file uploading not finished
1005 disabled

*/

if ($_SERVER['REQUEST_METHOD'] == 'POST') {



#if request method is post
#print_r($_POST);
#echo "<br>\n=====\n<br>";
#print_r($_FILES);
#echo "<br>\n=====\n<br>";

$uploadType=$_POST["uploadType"];
$buildId=$_POST["buildId"];
$type=$_POST["type"];
$version=$_POST["version"];
$comments=$_POST["comments"];
$codeBranch=$_POST["codeBranch"];
$env=$_POST["env"];
$md5sum=$_POST["md5sum"];
$filename=$_POST["filename"];
$buildTime=$_POST["buildTime"];
$forceOverriden=$_POST["forceOverriden"];

############debug###############

if(empty($version))  exit('{"message":" version is empty"}');
if(empty($uploadType))  exit('{"message":" uploadType is empty"}');
if(empty($type))  exit('{"message":" type is empty"}');

if($uploadType=="manually")
$filename=$_FILES['appfile']['name'];

$uploadLock=addLock();

#$parameters = ConvertArray($parameters);

#echo "====$type=====";

#$type="android";

#print_r($parameters);
#echo "<br>\n=====\n<br>";


if($type != "android" && $type != "ios") 

{
removeLock($uploadLock);
exit('{"message":"'.$type.' 应用类型只能是android 或者 ios!"}');

}
#if($type =="") exit("$type $filename only could be android or ios!");

if($uploadType == "jenkins") {

#add version
#add build
#print_r($_POST);
$parameters = array_merge(array($type),array($version),array($comments),array($codeBranch),array($env),array($buildId));
if(IsNullOrEmptyString($parameters))  {
removeLock($uploadLock);
exit('{"message":"请检查参数，必填参数请填写!","status":1002}');
}
  AddVersion($version,$type);
  exec("echo ${buildId},${codeBranch},${env},0,0,${comments},${buildTime},$version,N/A,$md5sum | cat - /opt/app/qa-site/ota/$type/data.dat > /tmp/$type.dat && mv /tmp/$type.dat /opt/app/qa-site/ota/$type/data.dat");


removeLock($uploadLock);
exit('{"message":"已上传至OTA http://qa.heika.com/ota/!","status":0}');
}

$parameters = array_merge(array($type),array($version),array($comments),array($codeBranch),array($env),array($filename),array($uploadType));
if(IsNullOrEmptyString($parameters)) {

removeLock($uploadLock);
 exit('{"message":"请检查参数，必填参数请填写!","status":1002}');
}

$uploaddir="/opt/app/qa-site/ota/$type/app/";
$uploadfile=$uploaddir.basename($filename);

if(file_exists($uploadfile) && $forceOverriden != "1")

{
removeLock($uploadLock);
 die('{"message":"此应用文件已经存在!'.$forceOverriden.' ","status":1000}');

}

if($forceOverriden == "1")
{

if(move_uploaded_file($_FILES['appfile']['tmp_name'],$uploadfile))
{
removeLock($uploadLock);
die( '{"message":"上传应用成功且覆盖了原来的应用!","status":0}');
}
else{
removeLock($uploadLock);
  die('{"message":"上传文件失败，请确认服务器或者磁盘空间是否正常!'.$_FILES["appfile"]["error"].'","status":1001}');
}

}

if(move_uploaded_file($_FILES['appfile']['tmp_name'],$uploadfile))
{

  if($type == "ios")
	{ 
		#generate the plist	
		GeneratePlist($filename);		
		#echo "generate the list";

	}

  #add data and version record 
  #exec("date +%Y-%m-%d_%T",$datestring);
  #$datestring=$datestring[0];
  #echo "add app and version record";
  AddVersion($version,$type); 
  exec("echo 0,${codeBranch},${env},0,0,${comments},$(date +%Y-%m-%d_%T),$version,$filename,$md5sum | cat - /opt/app/qa-site/ota/$type/data.dat > /tmp/$type.dat && mv /tmp/$type.dat /opt/app/qa-site/ota/$type/data.dat");
  if($type=="android") $qrencodeString = "http://qa.heika.com/ota/$type/app/$filename";
  else if($type == "ios") $qrencodeString="itms-services://?action=download-manifest&url=https://qa.heika.com/ota/$type/app/$filename.plist";
  #echo "$qrencodeString";
  exec("/usr/local/bin/qrencode -o /opt/app/qa-site/ota/$type/app/$filename.png -s 6 '$qrencodeString'");
removeLock($uploadLock);
  echo '{"message":"上传应用成功!","status":0}';
 
}

else{
  removeLock($uploadLock);
  echo '{"message":"上传应用错误，请检查服务器或者磁盘空间是否正常!'.$_FILES["appfile"]["error"].'","status":1001}';
}

#print_r($_FILES);

 
}
//end of  post method

else{ 

removeLock($uploadLock);
echo '{"message":"不支持的http方法!","status":400}';

}


?>
