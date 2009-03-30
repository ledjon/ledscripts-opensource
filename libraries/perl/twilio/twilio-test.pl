#!/usr/bin/perl

use strict;
use Twilio;
use Data::Dumper;

my $sid = 'AC6d282c890cb109919ad4cf8c3a598b2b'; 
my $token = 'f65aef15e5d11758dbca34808d45e9ef';

my $sourcePhone = '8778595978';
my $destPhone = '3175080013';

my $req = new TwilioRestClient($sid, $token);

my $res = $req->request(
		'/2008-08-01/Accounts/'. $sid . '/Calls',
		'POST',
		{
		 'Caller'	=> $sourcePhone,
		 'Called'	=> $destPhone,
		 'Url'		=> 'http://demo.twilio.com/welcome'
		}
	);

print Dumper($res);

1;
__END__
