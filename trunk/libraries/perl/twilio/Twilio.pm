package Twilio;

use strict;

package TwilioRestResponse;

use strict;
use HTTP::Response;
use XML::Simple;
use Data::Dumper;

sub new
{
	my $class = shift;
	my $req = shift;
	my $res = shift;

	my $opts = {
		'request'	=> $req,
		'response'	=> $res
	};

	my $this = bless( $opts, $class );

	$this->parseResponse();

	return $this;
}

sub parseResponse
{
	my $this = shift;

	my $url = $this->{'request'}->uri;

	if($url =~ /([^?]+)\??(.*)/)
	{
		$this->{'Url'} = $1;
		$this->{'QueryString'} = $2;
	}

	$this->{'ResponseText'} = $this->{'response'}->content;
	$this->{'HttpStatus'} = $this->{'response'}->code;

	if( $this->{'HttpStatus'} != 204 )
	{
		eval
		{
			$this->{'ResponseXml'} = XMLin($this->{'ResponseText'});
		};
	}

	if($this->{'IsError'} = ($this->{'HttpStatus'} >= 400))
	{
		$this->{'ErrorMessage'} = $this->{'ResponseXml'}->{'RestException'}->{'Message'};
	}
}

package TwilioRestClient;

use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use URI::Escape;
use Encode;

sub new 
{
	my $class = shift;
	my $accountSid = shift;
	my $authToken = shift;
	my $endpoint = shift || "https://api.twilio.com";

	my $opts = {
		'AccountSid'	=> $accountSid,
		'AuthToken'		=> $authToken,
		'Endpoint'		=> $endpoint
	};

	return bless( $opts, $class );
}

sub request
{
	my $this = shift;
	my $path = shift;
	my $method = shift || 'GET';
	my %vars = %{shift @_};

	my $encoded = '';

	for my $k (keys %vars)
	{
		$encoded .= sprintf("%s=%s&", $k, uri_escape($vars{$k}));
	}
	$encoded = substr($encoded, 0, length($encoded));

	# construct full url
	my $url = sprintf("%s/%s", $this->{'Endpoint'}, $path);

	# if GET and vars, append them
	if($method eq 'GET')
	{
		$url .= (($path !~ /\?/) ? "?" : "&") . $encoded;
	}
	# we're taking a pretty big step away from the php version
	# since we have HTTP::Request
	my $ua = LWP::UserAgent->new;
	my $request = HTTP::Request->new( $method, $url );
	$request->headers->authorization_basic( $this->{'AccountSid'}, $this->{'AuthToken'} );

	if(uc($method) eq 'POST')
	{
		$request->content( $encoded );
	}

	my $response = $ua->request($request);

	return new TwilioRestResponse($request, $response);
}


1;
__END__
