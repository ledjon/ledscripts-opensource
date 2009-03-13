<?

class TwilioResponseVerb
{
	protected $mVerb;
	protected $mContent;
	protected $mAttributes;
	protected $mSubVerbs = array();
	
	public function __construct($verb, $content = null, $attributes = null)
	{
		if(!is_array($attributes))
		{
			$attributes = array();
		}
		
		$this->mVerb = $verb;
		$this->mContent = $content;
		$this->mAttributes = $attributes;
	}
	
	public function GetVerb($encoded = true)
	{
		return $encoded ? self::encode($this->mVerb) : $this->mVerb;
	}
	
	public function GetRawContent()
	{
		return $this->mContent;
	}
	
	public function GetContent()
	{
		$content = '';
		
		// 'content' can actually be sub-verbs
		if(! is_array($this->mContent) )
		{
			if( $this->mContent instanceof TwilioResponseVerb )
			{
				$this->mContent = array( $this->mContent );
			}
		}
		
		// at this point, we assume an array in content() is an array
		// of sub-verbs
		if(is_array($this->mContent))
		{
			foreach ($this->mContent as $c)
			{
				/* @var $c TwilioResponseVerb */
			
				$content .= $c->Render();
			}
		}
		else 
		{
			$content = self::encode($this->mContent);
		}
		
		return $content;
	}
	
	public function GetAttributes()
	{
		return $this->mAttributes;
	}
	
	public function GetAtributesAsString($encoded = true)
	{
		$attr = '';
		
		if(count($this->mAttributes) > 0)
		{
			foreach ($this->mAttributes as $k => $v)
			{
				$attr .= ' ';
				
				$attr .= sprintf('%s="%s"', $k, addslashes($encoded ? self::encode($v) : $v));
			}
		}
		
		return $attr;
	}
	
	public function Render()
	{
		return sprintf('<%s%s>%s</%s>', $this->GetVerb(), $this->GetAtributesAsString(), $this->GetContent(), $this->GetVerb());
	}
	
	private function encode($t)
	{
		return htmlspecialchars($t);
	}
}

?>