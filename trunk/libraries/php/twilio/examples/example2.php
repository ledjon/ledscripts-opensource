<?
	require_once(dirname(__FILE__) . '/../TwilioResponse.php');
	
	$response = new TwilioResponse();

	$response->Say('this is a test, my friend',
		array('voice' => 'woman', 'loop' => 2)
	);
	
	// Gather, with the alternate method of doing verbs (as a "get" that can be passed as sub-verbs)
	$response->Gather(
		array(
			$response->GetVerb(TwilioResponse::V_SAY, 'Thank you for calling. Please press 1 for more options'),
			$response->GetVerb(TwilioResponse::V_PAUSE),
			$response->GetVerb(TwilioResponse::V_SAY, 'Go on.  press something')
		),
		array(
			'action'	=> '/handle-response.php',
			'numDigits'	=> 1
		)
	);
	$response->Respond();

?>