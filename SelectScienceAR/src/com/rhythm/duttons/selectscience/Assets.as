package com.rhythm.duttons.selectscience
{
	public class Assets
	{
		
		[Embed(source="/assets/3d/monkey/test_smooth.dae", mimeType="application/octet-stream")]
		public static const MONKEY:Class;
		
		[Embed(source="/assets/3d/monkey/MonkeyBaked.png", mimeType="image/png")]
		public static const MONKEY_TEX:Class;
		
		
		public function Assets()
		{
			
		}
	}
}