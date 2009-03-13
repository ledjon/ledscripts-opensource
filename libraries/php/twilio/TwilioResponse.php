<?

require_once(dirname(__FILE__) . '/TwilioResponseVerb.php');

class TwilioResponse
{
	protected $mParts = array();
	
	const V_SAY 		= 'Say';
	const V_GATHER 		= 'Gather';
	const V_PLAY 		= 'Play';
	const V_RECORD 		= 'Record';
	const V_DIAL 		= 'Dial';
	const V_REDIRECT 	= 'Redirect';
	const V_PAUSE 		= 'Pause';
	const V_HANGUP 		= 'Hangup';
	
	public function AddVerb($verb, $content, $attributes = null)
	{
		$this->mParts[] = $this->GetVerb($verb, $content, $attributes);
	}
	
	public function GetVerb($verb, $content = null, $attributes = null)
	{
		return new TwilioResponseVerb($verb, $content, $attributes);
	}
	
	public function Say($text, $attributes = null)
	{
		$this->AddVerb(self::V_SAY, $text, $attributes);
	}
	
	public function Gather( $subVerbs, $attributes = null )
	{
		$this->AddVerb(self::V_GATHER, $subVerbs, $attributes);
	}
	
	public function Play($fileLocation, $attributes = null)
	{
		$this->AddVerb(self::V_PLAY, $fileLocation, $attributes);
	}
	
	public function Record($attributes = null)
	{
		$this->AddVerb(self::V_RECORD, null, $attributes);
	}
	
	public function Dial($phoneNumber, $attributes = null)
	{
		$this->AddVerb(self::V_DIAL, $phoneNumber, $attributes);
	}
	
	public function Hangup($attributes = null)
	{
		$this->AddVerb(self::V_HANGUP, null, $attributes);
	}
	
	public function Pause($attributes = null)
	{
		$this->AddVerb(self::V_PAUSE, null, $attributes);
	}
	
	public function Redirect($location, $attributes = null)
	{
		$this->AddVerb(self::V_REDIRECT, $location, $attributes);
	}
	
	public function GetResponse()
	{
		$r = '<Response>';
		
		foreach ($this->mParts as $part)
		{			
			/* @var $part TwilioResponseVerb */
			
			$r .= $part->Render();
		}
		
		$r .= '</Response>';
		
		return $r;
	}
	
	public function Respond()
	{
		echo $this->GetResponse();
	}
}

?>