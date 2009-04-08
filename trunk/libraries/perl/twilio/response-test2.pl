#!/usr/bin/perl

use strict;
use lib '/usr/local/text2phone/dev/src/lib/twilio';
use Twilio;
use Data::Dumper;

my $response = new TwilioResponse();

$response->Say('this is a test, my friend',
		'voice' => 'woman',
		'loop' => 2
	);

$response->Gather(
	[
		$response->GetVerb(TwilioResponse::V_SAY, 'Thank you for calling. Please press 1 for more options'),
		$response->GetVerb(TwilioResponse::V_PAUSE),
		$response->GetVerb(TwilioResponse::V_SAY, 'Go on. Press something')
	],
	'action'	=> '/handle-response.php?a=b&c=d',
	'numDigits'	=> 1
);

$response->Respond();



1;
__END__
