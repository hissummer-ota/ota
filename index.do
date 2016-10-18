
<!DOCTYPE html>
<html>
<?php 

$DocumentRoot='/opt/app/qa-site/ota';
require_once($DocumentRoot.'/include/headerinclude.html');?>
<body class="index">
<script>
$(document).ready(function(){

//
$('div.header  div  ul  li:nth-child(1) a').addClass(" pure-menu-selected");

});

</script>
<div id="wrap">

<?php require_once($DocumentRoot.'/include/header.html');?>


<div id="contain" class="main container">
<h2>
HOME
</h2>
<div class="welcome">
<p>
Ota for app download
</p>
<p>
<a href="list.do?type=ios" class="button-welcome pure-button">ios</a>
<a href="list.do?type=android" class="button-secondary pure-button">android</a>
</p>
</div>



</div>


<script type="text/javascript" src="/ota/static/js/app.js?v=471a4a60173357278fb10d12adcbdbdc"></script>
<?php 
require_once($DocumentRoot.'/include/footer.html');
?>
</div>

</body>
</html>
