package
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.events.ResourceEvent;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.loaders.parsers.AWDParser;
	
	[SWF(width="1024", height="768", frameRate="60", backgroundColor="#ffffff")]
	public class AWDTest extends Sprite
	{
		[Embed(source="/assets/3d/awd/v1.AWD", mimeType="application/octet-stream")]
		private static var MONKEY_AWD:Class;
		
		[Embed(source="/assets/3d/awd/MONKEYMESH_Painted.png", mimeType="image/png")]
		private static var MONKEY_TEXTURE:Class;
		
		private var scene:Scene3D;
		private var view:View3D;
		
		public function AWDTest()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(e:Event):void
		{
			view = new View3D();
			scene = view.scene;
			addChild(view);
			view.addChild(new AwayStats());
			
			AssetLibrary.enableParser( AWD2Parser );
			AssetLibrary.addEventListener( AssetEvent.ASSET_COMPLETE, onAssetComplete );
			AssetLibrary.addEventListener( LoaderEvent.RESOURCE_COMPLETE, onResourceComplete );
			AssetLibrary.addEventListener( LoaderEvent.LOAD_ERROR, onLoadError );
			
			AssetLibrary.loadData(new MONKEY_AWD, null,null,new AWDParser);
		}
		
		private function onLoadError(e:LoaderEvent):void
		{
			// TODO Auto Generated method stub
			
		}
		
		private function onResourceComplete(e:LoaderEvent):void
		{
			// TODO Auto Generated method stub
			trace("done.");
			
		}
		
		private function onAssetComplete(e:AssetEvent):void
		{
			// TODO Auto Generated method stub
			trace(e.asset.assetType);
		}
	}
}