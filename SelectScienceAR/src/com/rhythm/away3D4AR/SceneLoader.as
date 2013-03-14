package com.rhythm.away3D4AR
{
	import com.rhythm.utils.CustomEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.loaders.AssetLoader;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.loaders.parsers.ParserBase;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.PlaneGeometry;
	
	public class SceneLoader extends ObjectContainer3D
	{
		protected var models:Vector.<AnimatedModel>;
		private var numResourcesLoaded:int;
		private var totalResources:int;
		protected var plane:Mesh;
		public var ready:Boolean;
		public var showing:Boolean;
		public var id:int = 0;

		protected var messageType:String;
		private var timer:Timer;
		
		public function SceneLoader()
		{
			super();
			
			plane = new Mesh(new PlaneGeometry(100,100,3,3,true,true), new ColorMaterial(0xffffff, 1));
			plane.rotationX = 90;
			
			var planeMat:ColorMaterial = ColorMaterial(plane.material);
			//planeMat.shadowMethod = SceneFX.SHADOW;
			//planeMat.lightPicker = SceneFX.LIGHTPICKER;
			addChild(plane);
			
			// Show a Trident
			if(Constants.DEBUG_MODE) {
				var trident:Trident = new Trident();
				trident.scale(0.1);
				addChild(trident);
			}
			
			
			models = new Vector.<AnimatedModel>();
			totalResources = 0;
			numResourcesLoaded = 0;
			addLoaderItems();
		}
		
		protected function addGroundPlane():void
		{
			
		}
		
		public function show():void
		{
			if(!ready) return;
			showing = true;
			
			if (timer == null)
			{
				timer = new Timer(5000, 1);
				timer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);
				timer.start();
			}			
		}
		
		protected function onTimerTick(event:TimerEvent):void
		{
			dispatchEvent(new CustomEvent('SHOW_MESSAGE', {messageType:messageType}, true));
		}
		
		public function hide():void
		{
			if(!ready) return;
			showing = false;
			
			if (timer) 
			{
				timer.stop();
				timer = null;
			}		
			
			dispatchEvent(new Event('HIDE_MESSAGE', true));
		}
		
		protected function loadTexture():void
		{
			
		}
		
		protected function addModel(model:AnimatedModel):AnimatedModel
		{
			models.push(model);
			return model;
		}
		
		protected function getModelByName(modelName:String):AnimatedModel
		{
			for each(var m:AnimatedModel in models) {
				if(modelName == m.name) {
					return m;
				}
			}
			
			return addModel(new AnimatedModel(modelName));
		}
		
		protected function loadModel(data:*, ns:String, parser:ParserBase):void
		{
			var l:AssetLoader = new AssetLoader();
			l.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			l.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			l.loadData(data, "", null, ns, parser);
			totalResources ++;
		}
		
		protected function loadMD5Mesh(mesh:*, ns:String):void
		{
			var l:AssetLoader = new AssetLoader();
			l.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			l.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			l.loadData(mesh, "", null, ns, new MD5MeshParser);
			totalResources ++;
		}
		
		protected function loadMD5Animation(anim:*, ns:String):void
		{
			var l:AssetLoader = new AssetLoader();
			l.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			l.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			l.loadData(anim, "", null, ns, new MD5AnimParser);
			
			totalResources ++;
		}
		
		protected function addLoaderItems():void
		{
			// override
		}
		
		public function update():void
		{
			
		}
		
		protected function onAssetComplete(e:AssetEvent):void
		{
			trace("Asset loaded.");
		}
		
		protected function onResourceComplete(e:LoaderEvent):void
		{
			trace("Resource complete.");
			
			numResourcesLoaded++;
			
			if(numResourcesLoaded == totalResources) {
				initCustomMaterials();
				ready = true;
				onAllResourcesLoaded();
				dispatchEvent(new Event("SCENE_LOADED"));
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function initCustomMaterials():void
		{
			
		}
		
		protected function onAllResourcesLoaded():void
		{
			trace("-------------------------------");
			trace("------ RESOURCES LOADED! ------");
			trace("-------------------------------");
		}
	}
}