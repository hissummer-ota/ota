<?php

$fplock = fopen("/tmp/mytest.lock", "r+");

$flag = 0;

if (flock($fplock, LOCK_EX|LOCK_NB )) {  // acquire an exclusive lock

echo "lock the file";
sleep(10);

} else {

    die('{"message":"有正在上传的应用，请稍后再试！","status":1004}');

}

?>
