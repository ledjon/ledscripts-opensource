#!/usr/bin/perl

use strict;
use lib '/usr/local/text2phone/dev/src/lib/twilio';
use Twilio;

my $response = new TwilioResponse();

$response->Say('Thank you for calling so & so');
$response->Pause();
$response->Say('This is the end of the call.  Goodby.');
$response->Hangup();
$response->Respond();

1;
__END__
