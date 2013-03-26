package com.rhythm.utils
{
	import flash.utils.Timer;
	
	public class CustomTimer extends Timer
	{
		public var id:int;
		
		public function CustomTimer(delay:Number, repeatCount:int=0, id:int = 0)
		{
			this.id = id;
			super(delay, repeatCount);
		}
	}
}