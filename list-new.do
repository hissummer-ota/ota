<!DOCTYPE html>
<html>
<?php
#$mypath = (dir(getcwd()));
#require_once($mypath->path.'/config/config.do');
$DocumentRoot='/opt/app/qa-site/ota';
require_once($DocumentRoot.'/include/headerinclude.html');?>


<?php 

#mark this script could be executed
define('EXECUTABLE', 'true');

if(isset($_GET['page']) && $_GET['page'] >1 )
$page=$_GET['page'];
else $page=1;

if($page == 1) {$start = 1 ; $end = $start*20;}
else {$start = ($page-1)*20+1; $end=$page*20;}

$type=$_GET['type'];
$sort=$_GET['sort'];

if(isset($_GET['type']) )
{
if($type != "ios" && $type != "android")
  $type="android";
else
  $type=$_GET['type'];
}


if($type == "android")
$location = "/home/ci/jobs/ANDROID构建/builds/";
else if($type == "ios")
$location = "/home/ci/jobs/IOS构建/builds/";

?>

<body class="index">
<script>


$(document).ready(function(){

    var listurl = window.location.href;
    console.log(listurl);
    if(listurl.indexOf('android') > -1)  $('div.header  div  ul  li:nth-child(3) a').addClass(" pure-menu-selected");
    else  $('div.header  div  ul  li:nth-child(2) a').addClass(" pure-menu-selected");

    $('.versionspan').on('click', function(e) {
       if($(this).parent().children('.builddiv').hasClass("invisible"))
        $(this).parent().children('.builddiv').removeClass("invisible");

       else $(this).parent().children('.builddiv').addClass("invisible");
    });

    $('.appspan').on('click', function(e) {
       if($(this).parent().children('.qrcode').hasClass("invisible"))
     { 
       $(this).parent().children('.qrcode').addClass("qrcodeShow")
        $(this).parent().children('.qrcode').removeClass("invisible");
        $(this).text("隐藏二维码");
           
     }
      else 
     { 
       $(this).parent().children('.qrcode').removeClass("qrcodeShow")
        $(this).parent().children('.qrcode').addClass("invisible");
        $(this).text("查看二维码");
     }
      console.log("qrcode click");
    });
/*
    $('.appspan').mouseout('click', function(e) {
       if( $(this).parent().children('.qrcode').removeClass("qrcodeShow"))
       if( $(this).parent().children('.qrcode').addClass("invisible"))
      console.log("out");
    });
*/
});


</script>

<div id="wrap">

<?php require_once($DocumentRoot.'/include/header.html');?>

<div id="contain" class="main container">
<h2><?php $capitaltype=strtoupper($type);echo $capitaltype; ?></h2>
<div class="app-list">

<!-- <div id="searchdiv">search box</div> -->

<?php

require_once('include/getapp.do');

if($sort != "recent")
{

#exec("ls $location | grep -w  '^[0-9]*' | sort -h > tmpdata");
#exec("sh /opt/app/qa-site/ota/middle.sh $start $end /opt/app/qa-site/ota/$type/data.dat",$output);

exec("cat /opt/app/qa-site/ota/$type/version.dat",$versions);

#$versions=array_merge($charaversions,$numberversions);

#print_r($versions);

#$capitaltype =  strtoupper($type);

foreach ($versions as $appversion)
{
    print "<div class=\"versiondiv\"><h3 class=\"versionspan\">版本：$appversion</h3>";	
    $appsarray=empty($appsarray);  #need empty this array. because exec will append array ,not clear then set
    #print_r($appsarray);
    exec("cat /opt/app/qa-site/ota/$type/data.dat | grep ',$appversion,'",$appsarray);
    #echo "cat /opt/app/qa-site/ota/$type/data.dat | grep ',$appversion,'";
    $appcounter = 1;
    #print_r($appsarray);
    foreach ($appsarray as $oneapp)
    {
	$buildinfo = explode("," , $oneapp);

	#var_dump($buildinfo);

	#list all apks or ipas
      
        if($buildinfo[0] > 1)
	{
	$output = <<< HTML
	<div class="builddiv invisible"><div class="builddivheader">
HTML;
	print $output;
	getapps($buildinfo[0],$type); # if buildinfo > 1 , will load apps infos from jenkins
      
$output = <<< HTML
        <hr><span class="buildspan">BuildId: <a href="/jenkins/job/${capitaltype}构建/$buildinfo[0]/" target="" > $buildinfo[0]</a></span><span class="buildspan">代码分支: $buildinfo[1]</span><span class="buildspan">环境: $buildinfo[2]</span><span class="buildspan">构建时间: $buildinfo[6]</span><span class="buildspan"><a href="/jenkins/job/${capitaltype}构建/$buildinfo[0]/changes">更新记录</a></span><br/><span class="buildspan">备注: $buildinfo[5]</span></div>
HTML;
        print $output;


	}
       else { 
       
       if($type == "android") $downloadlink = "/ota/$type/app/$buildinfo[8]";
       else if($type == "ios") $downloadlink = "itms-services://?action=download-manifest&url=https://qa.heika.com/ota/$type/app/".$buildinfo[8].".plist";
       $output = <<< HTML
	<div class="builddiv invisible"><div class="builddivheader">

<div class="appcontainer"><div class="appdiv"><span class=""><a class="applink" href="$downloadlink"> $buildinfo[8] </a></span><span class="appspan">查看二维码</span>
<hr>
<span class="buildspan">BuildId: 手动上传应用 </span><span class="buildspan">代码分支: $buildinfo[1]</span><span class="buildspan">环境: $buildinfo[2]</span><span class="buildspan">上传时间: $buildinfo[6]</span><span class="buildspan">无更新记录</span><br/><span class="buildspan">备注: $buildinfo[5]</span>

<span class="qrcode invisible">
<img class="qrimg" src="/ota/$type/app/$buildinfo[8].png">
</span></div></div>


</div>
HTML;

	print $output;
	}

	print "</div><!-- end of the builddiv -->";
	$appcounter ++;
    }
    if($appcounter == 1) 

   {
     print "<div class=\"builddiv invisible\">没有找到此版本的应用</div>";
   }

    print "</div><!--end of the versiondiv -->";


}
} #end of the if sort

else {

    $appsarray=empty($appsarray);  #need empty this array. because exec will append array ,not clear then set
    #print_r($appsarray);
    exec("cat /opt/app/qa-site/ota/$type/data.dat ",$appsarray);
    $appcounter = 1;
    #print_r($appsarray);
    foreach ($appsarray as $oneapp)
    {
        $buildinfo = explode("," , $oneapp);

        #var_dump($buildinfo);

        #list all apks or ipas

        if($buildinfo[0] > 1)
        {
        $output = <<< HTML
 <div class="versiondiv"><h3 class="versionspan">版本：$buildinfo[7] 构建时间: $buildinfo[6]</h3>
        <div class="builddiv invisible"><div class="builddivheader">
HTML;
        print $output;
        getapps($buildinfo[0],$type); # if buildinfo > 1 , will load apps infos from jenkins

$output = <<< HTML
        <hr><span class="buildspan">BuildId: <a href="/jenkins/job/${capitaltype}构建/$buildinfo[0]/" target="" > $buildinfo[0]</a></span><span class="buildspan">代码分支: $buildinfo[1]</span><span class="buildspan">环境: $buildinfo[2]</span><span class="buildspan">构建时间: $buildinfo[6]</span><span class="buildspan"><a href="/jenkins/job/${capitaltype}构建/$buildinfo[0]/changes">更新记录</a></span><br/><span class="buildspan">备注: $buildinfo[5]</span></div>
</div><!-- end of the builddiv -->
</div><!--end of the versiondiv -->
HTML;
        print $output;


        }

 else {

       if($type == "android") $downloadlink = "/ota/$type/app/$buildinfo[8]";
       else if($type == "ios") $downloadlink = "itms-services://?action=download-manifest&url=https://qa.heika.com/ota/$type/app/".$buildinfo[8].".plist";
       $output = <<< HTML
 <div class="versiondiv"><h3 class="versionspan">版本：$buildinfo[7]  构建时间: $buildinfo[6]</h3>
        <div class="builddiv invisible"><div class="builddivheader">

<div class="appcontainer"><div class="appdiv"><span class=""><a class="applink" href="$downloadlink"> $buildinfo[8] </a></span><span class="appspan">查看二维码</span>
<hr>
<span class="buildspan">BuildId: 手动上传应用 </span><span class="buildspan">代码分支: $buildinfo[1]</span><span class="buildspan">环境: $buildinfo[2]</span><span class="buildspan">上传时间: $buildinfo[6]</span><span class="buildspan">无更新记录</span><br/><span class="buildspan">备注: $buildinfo[5]</span>

<span class="qrcode invisible">
<img class="qrimg" src="/ota/$type/app/$buildinfo[8].png">
</span></div></div>


</div>
</div><!-- end of the builddiv -->
</div><!--end of the versiondiv -->
HTML;

        print $output;
        }

#        print "</div><!-- end of the builddiv -->";
        $appcounter ++;
    }
    if($appcounter == 1)

   {
     print "<div class=\"builddiv invisible\">没有找到此版本的应用</div>";
   }
    print "</div><!--end of the versiondiv -->";



}

?>

<script type="text/javascript" src="/ota/static/js/app.js?v=471a4a60173357278fb10d12adcbdbdc"></script>
</div> <!-- end of the applist div-->
</div> <!-- end of the contain div -->
<?php
require_once($DocumentRoot.'/include/footer.html');
?>

</div> <!-- end of the wrap div -->

</body>
</html>
