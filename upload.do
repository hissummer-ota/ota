
<!DOCTYPE html>
<html>
<?php 

$DocumentRoot='/opt/app/qa-site/ota';
require_once($DocumentRoot.'/include/headerinclude.html');?>

<body class="index">
<script>

$(document).ready(function(){

    $('div.header  div  ul  li:nth-child(4) a').addClass(" pure-menu-selected");
    $('#upload').on('click',function(e) {
        e.preventDefault();
/*
check parameters.
*/

$('#message').removeClass();
$('#message').addClass("messageok");
$("#upload").prop('disabled', true);
//$("#upload").addClass('disable');
$("#upload").css('background','gray');
$('#message').html("<img class=\"loadinggif\" src=\"static/images/loading.gif\" />   "+"正在上传中...");


//console.log($('[name="type"]').val());
var fd = new FormData();    
//fd.append( 'codeBranch', new Blob([$('[name="codeBranch"]').val()],{type: "text/plain; charset=UTF-8"}));
fd.append( 'codeBranch', $('[name="codeBranch"]').val());
fd.append( 'version', $('[name="version"]').val() );
fd.append( 'type',$('[name="type"]').val()  );
fd.append( 'env',  $('[name="env"]').val());
fd.append( 'uploadType', $('[name="uploadType"]').val() );
fd.append( 'comments', $('[name="comments"]').val() );
if($('[name="forceOverriden"]').is(':checked'))
fd.append( 'forceOverriden', $('[name="forceOverriden"]').val() );

fd.append( 'appfile',  $('[name="appfile"]')[0].files[0]);

$.ajax({
  url: '/ota/api/upload.do',
  data: fd,
  processData: false,
  contentType: false,
  type: 'POST',
  success: function(data){

    console.log(data);
    var message=JSON.parse(data);
    console.log(message.message);
    //$('#message').removeClass("invisible");
    $('#message').text(message.message);

    if(message.status == 0)
{     $('#message').removeClass();
      $('#message').addClass("messageok");
}
    else
{
     $('#message').removeClass();
      $('#message').addClass("messageerror");
}

    $("#upload").css('background','#1f8dd6');
   // $("#upload").removeClass('disable');
    $("input").prop('disabled', false);
    //console.log(message.message);
    //alert(data);
    //alert(typeof(message));
  },

  error: function(jqXHR, textStatus, errorThrown){

    //$("#upload").removeClass('disable');
    $("#upload").css('background','#1f8dd6');
   $('#message').removeClass();
   $('#message').addClass("messageerror"); 
   //$('#message').removeClass("invisible");
   $('#message').text("服务器出现错误 '"+textStatus+": "+errorThrown+"'请刷新后重试！");
    $("input").prop('disabled', false);
  },

  timeout: 30000

});


    });

});



</script>
<div id="wrap">

<?php require_once($DocumentRoot.'/include/header.html');?>


<div id="contain" class="main container">
<h2>上传应用</h2>
<div class="app-list">
<a style="font:red;" href="http://qa.heika.com/wiki/doku.php?id=%E5%AE%A2%E6%88%B7%E7%AB%AF%E6%9E%84%E5%BB%BA%E6%95%99%E7%A8%8B">使用前请阅读文档-手动上传部分</a><br/><br/>
<div id="message"class="invisible "  ></div>
<!-- <h2 class="upload">
上传应用
</h2>-->
<div id="uploaddiv">
 <form method="post" enctype="multipart/form-data" id="uploadForm" action="/ota/api/upload.do"> 
<fieldset>
 <legend>应用信息</legend>
 <label for="appfile">应用包:</label> <input type="file" name="appfile" accept=".apk,.ipa"><br/><br/>
<label for="type">平台:</label><select name="type">
  <option value="android">ANDROID</option>
  <option value="ios">IOS</option>
</select> <br/><br/>
<label for="version">版本:</label>  <input type="text" name="version" placeholder="unKnown" ><br/><br/>
<label for="codeBranch">代码分支:</label>  <input type="text" name="codeBranch" placeholder="unKnown" ><br/><br/>
<label for="env">环境:</label>  <input type="text" name="env" placeholder="unKnown" ><br/><br/>
<label for="comments">备注:</label>  <input type="text" name="comments"  cols="30" placeholder="无备注"></input><br/><br/>
<label for="forceOverriden">强制覆盖:</label><input  type="checkbox" name="forceOverriden" onclick="if(this.checked) alert('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n选择此选项遇到文件名相同时，将会覆盖原文件，请再次确定是否选择此选项!\n================');" value="1"><br/><br/>
<input type="hidden" name="uploadType" value="manually">

  <input id="upload" type="submit" value="提交">
</fieldset>
</form> 

<br/>
<div style="color:red;">备注：输入框中,不能使用逗号","。强制替换选项，慎重选择！</div>
</div>
</div>



</div>


<script type="text/javascript" src="/ota/static/js/app.js?v=471a4a60173357278fb10d12adcbdbdc"></script>
<?php
require_once($DocumentRoot.'/include/footer.html');
?>

</div>

</body>
</html>
