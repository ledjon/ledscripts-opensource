<?

	require_once(dirname(__FILE__) . '/../TwilioResponse.php');
	
	$response = new TwilioResponse();
	
	$response->Say('Thank you for calling so & so'); // notice that the '&' gets properly encoded
	$response->Pause();
	$response->Say('This is the end of the call.  Goodby.');
	$response->Hangup();
	$response->Respond();	


?>