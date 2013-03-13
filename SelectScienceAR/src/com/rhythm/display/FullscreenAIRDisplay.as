package com.rhythm.display
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	
	public class FullscreenAIRDisplay extends Sprite
	{
		public static const FULLSCREEN_ENABLED:Boolean = true;
		
		public function FullscreenAIRDisplay()
		{
			super();
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void
		{
			trace("added.");
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
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