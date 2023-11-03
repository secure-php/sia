<?php
if(isset($_GET['var1'])) {
    $var1 = $_GET['var1'];
	if($var1 == '2022'){
		echo "branch one \n";
	}
	elseif($var1 . "world" == "hellworld") {
		echo "branch two \n";
		
		// trigger segfault acccording to Fault Escalation
		system('ls ('); 
	}
}
