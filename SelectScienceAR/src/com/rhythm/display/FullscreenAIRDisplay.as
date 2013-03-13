package com.rhythm.display
{
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.FullScreenEvent;
	
	public class FullscreenAIRDisplay extends Sprite
	{
		public static const FULLSCREEN_ENABLED:Boolean = true;
		
		public function FullscreenAIRDisplay()
		{
			super();
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		public function initWithScreen(screen:Screen):void {
		
			stage.nativeWindow.x = screen.bounds.x;
			
			if(FULLSCREEN_ENABLED)
			{
				stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEntered);
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} else {
				init();
			}
			
		}
		
		protected function onFullScreenEntered(e:FullScreenEvent):void
		{
			if(e.fullScreen) {
				trace("ok.");
				stage.removeEventListener(FullScreenEvent.FULL_SCREEN, onFullScreenEntered);
				init();
			}
		}
		
		protected function init():void
		{
			// override me.
		}
	}
}