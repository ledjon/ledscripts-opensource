############################
# Twilio REST interface
#  and Response objects
# 
# In other words, all programatic twilio stuff you'll ever
# need for Perl!
#
# by Jon Coulter
# ledjon <-at-> ledscripts.com
# 
# See included examples on usage
############################

package Twilio;

use strict;

package TwilioRestResponse;

use strict;
use HTTP::Response;
use XML::Simple;

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

use LWP::UserAgent;
#use LWP::Debug qw(+);
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
	$encoded = substr($encoded, 0, length($encoded)-1);

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
		$request->header('Content-Type', 'application/x-www-form-urlencoded');
		$request->content( $encoded );
	}

	my $response = $ua->request($request);

	return new TwilioRestResponse($request, $response);
}

package TwilioResponseVerb;

use strict;
use HTML::Entities;

sub new
{
	my $class = shift;
	my $verb = shift;
	my $content = shift || '';
	my %attributes = @_;

	my $this = bless( { }, $class );
	
	$this->{'mVerb'} = $verb;
	$this->{'mContent'} = $content;
	$this->{'mAttributes'} = \%attributes;

	return $this;
}

sub GetVerb
{
	my $this = shift;
	my $encoded = shift || 1;

	return $encoded ? encode($this->{'mVerb'}) : $this->{'mVerb'};
}

sub GetRawContent
{
	return shift->{'mContent'};
}

sub GetContent
{
	my $this = shift;

	my $content = '';

	if(! (ref($this->{'mContent'}) eq 'ARRAY') )
	{
		if( ref($this->{'mContent'})
			&& $this->{'mContent'}->is_a('TwilioResponseVerb'))
		{
			$this->{'mContent'} = [ $this->{'mContent'} ];
		}
	}

	if( ref($this->{'mContent'}) eq 'ARRAY' )
	{
		for my $v ( @{$this->{'mContent'}})
		{
			$content .= $v->Render();
		}
	}
	else
	{
		$content .= encode( $this->{'mContent'} );
	}

	return $content;
}

sub GetAttributes
{
	return shift->{'mAttributes'};
}

sub GetAtributesAsString
{
	my $this = shift;
	my $encoded = shift || 1;

	my $attr = '';

	for my $k (keys %{ $this->{'mAttributes'} })
	{
		my $v = $this->{'mAttributes'}->{$k};

		$attr .= ' ';

		$attr .= sprintf('%s="%s"', $k, addslashes($encoded ? encode($v) : $v));
	}

	return $attr;
}

sub Render
{
	my $this = shift;

	return sprintf("<%s%s>%s</%s>", $this->GetVerb(), $this->GetAtributesAsString(), $this->GetContent(), $this->GetVerb());
}

sub encode
{
	my $enc = encode_entities(shift);

	# known baddies
	$enc =~ s/&reg;//g;

	return $enc;
}

sub addslashes
{
	my $v = shift;

	$v =~ s!\\!\\\\!g;

	return $v;
}



package TwilioResponse;

use strict;

use constant V_SAY		=> 'Say';
use constant V_GATHER	=> 'Gather';
use constant V_PLAY		=> 'Play';
use constant V_RECORD	=> 'Record';
use constant V_DIAL		=> 'Dial';
use constant V_REDIRECT	=> 'Redirect';
use constant V_PAUSE	=> 'Pause';
use constant V_HANGUP	=> 'Hangup';

sub new 
{
	return bless( { 'mParts' => [] }, shift @_ );
}

sub AddVerb
{
	my $this = shift;
	my $verb = shift;
	my $content = shift;
	my %attributes = @_;

	push( @{$this->{'mParts'}}, $this->GetVerb( $verb, $content, %attributes ) );
}

sub GetVerb
{
	my $this = shift;
	my $verb = shift;
	my $content = shift || '';
	my %attributes = @_;

	return new TwilioResponseVerb($verb, $content, %attributes);
}

sub Say
{
	shift->AddVerb(V_SAY, @_);
}

sub Gather 
{
	shift->AddVerb(V_GATHER, @_);
}

sub Play 
{
	shift->AddVerb(V_PLAY, @_);
}

sub Dial
{
	shift->AddVerb(V_DIAL, @_);
}

sub Redirect
{
	shift->AddVerb(V_REDIRECT, @_);
}

sub Record 
{
	shift->AddVerb(V_RECORD, undef, @_);
}

sub Hangup
{
	shift->AddVerb(V_HANGUP, undef, @_);
}

sub Pause
{
	shift->AddVerb(V_PAUSE, undef, @_);
}

sub GetResponse
{
	my $this = shift;

	my $r = '<Response>';
	
	for my $verb ( @{$this->{'mParts'}} )
	{
		$r .= $verb->Render();
	}

	$r .= '</Response>';

	return $r;
}

sub Respond
{
	my $this = shift;
	my $sendHeader = shift || 1;

	if( $sendHeader )
	{
		print "Content-type: text/xml\n\n";
	}

	print $this->GetResponse();
}


1;
__END__
