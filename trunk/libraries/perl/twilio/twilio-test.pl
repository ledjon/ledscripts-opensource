#!/usr/bin/perl

use strict;
use Twilio;
use Data::Dumper;

my $sid = 'your-twilio-sid'; 
my $token = 'your-twilio-secret-token';

my $sourcePhone = 'xxxxxxxx'; # number to display on callerid
my $destPhone = 'xxxxxxxx'; # number to dial

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
