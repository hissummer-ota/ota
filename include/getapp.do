<?php


/*


*Get the apps from jenkins based on the jenkins BuildId


*/

#define('EXECUTABLE', 'true');

if (defined('EXECUTABLE')) {
}
else{
exit("sorry , permission denied!");
}


function getapps($buildId , $type)

{

$buildId = is_numeric($buildId)?$buildId:0;
#$type=$type;


if($type == "ios")
{
$location = "/home/test/ci/jobs/IOS构建/builds/$buildId/";
$type = "ipa";
#$jenkinsUrl="http://172.16.2.37/jenkins/view/%E9%BB%91%E5%8D%A1%E5%AE%A2%E6%88%B7%E7%AB%AF/job/IOS构建/$buildId/";
$jenkinsUrl="http://qa.heika.com/jenkins/plist/$buildId/";
$jenkinsPngUrl="http://qa.heika.com/jenkins/job/IOS构建/$buildId/";
}

else if ($type == "android")
{

$location = "/home/test/ci/jobs/ANDROID构建/builds/$buildId/";
$type="apk";
#$jenkinsUrl="http://172.16.2.37/jenkins/view/%E9%BB%91%E5%8D%A1%E5%AE%A2%E6%88%B7%E7%AB%AF/job/ANDROID构建/$buildId/";
$jenkinsUrl="http://qa.heika.com/jenkins/job/ANDROID构建/$buildId/";

}


#$outputarray=array();

#step1 , find all apps under the location
#echo $location;
#echo $type;
#echo "/bin/find $location  -iname '*.$type' | grep -v 'unaligned'";
exec("/bin/find $location  -iname '*.$type'  ",$outputarray);

#var_dump($outputarray);

print '<div class="appcontainer">';
foreach ($outputarray as $appwithpath )
{
#print $appwithpath;

#print "<br/>";

#get the name without the appendix

$pattern = '/^.*\/archive\/(.*)\/(.*)\..*/';
preg_match($pattern, $appwithpath, $matches);
#print_r($matches);


#$appname = str_replace(".*\//", "", $appwithpath);
#$appname = str_replace(".$type", "", $appname);



if($type == "apk")
{
$returnvar = <<< HTMLEND
<div class="appdiv"><span class=""><a class="applink" href="${jenkinsUrl}artifact/$matches[1]/$matches[2].$type" > $matches[2].$type </a></span><span class="appspan">查看二维码</span><span class="qrcode invisible">
<img class="qrimg" src="${jenkinsUrl}artifact/$matches[1]/$matches[2].apk.png"/>
</span></div>
HTMLEND;
}
if($type=="ipa")
{

$jenkinsUrlHttps = str_replace("http:","https:",$jenkinsUrl);

$returnvar = <<< HTMLEND
<div class="appdiv"><span class=""><a class="applink" href="itms-services://?action=download-manifest&url=${jenkinsUrlHttps}artifact/$matches[1]/$matches[2].xml" > $matches[2].$type </a></span><span class="appspan">查看二维码</span><span class="qrcode invisible">
<img class="qrimg" src="${jenkinsPngUrl}artifact/$matches[1]/$matches[2].png"/>
</div>
HTMLEND;
}
print $returnvar;


}

print "</div>";
}

?>
