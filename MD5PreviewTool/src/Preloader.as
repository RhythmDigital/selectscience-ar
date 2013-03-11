package
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Preloader extends Sprite
	{
		private var doneTxt:TextField;
		private var l:Loader;
		
		public function Preloader()
		{
			super();
			l = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			l.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			l.load(new URLRequest("MD5PreviewTool.swf"));
			
			doneTxt = new TextField();
			doneTxt.autoSize = TextFieldAutoSize.LEFT;
			doneTxt.setTextFormat(new TextFormat("Arial", 40, 0x000000));
			doneTxt.text = "0%";
			doneTxt.x = (stage.stageWidth >>1)-(doneTxt.textWidth>>1);
			doneTxt.y = stage.stageHeight >>1;
			addChild(doneTxt);
			
		}
		
		protected function onProgress(e:ProgressEvent):void
		{
			doneTxt.text = int(e.bytesLoaded/e.bytesTotal*100)+"%";
			doneTxt.x = (stage.stageWidth >>1)-(doneTxt.textWidth>>1);
		}
		
		protected function onComplete(event:Event):void
		{
			trace("done.");
			
			removeChild(doneTxt);
			addChild(l.contentLoaderInfo.content);
		}
	}
}