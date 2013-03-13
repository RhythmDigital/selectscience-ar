package com.rhythm.away3D4AR
{
	import flash.events.Event;
	
	import away3d.containers.ObjectContainer3D;
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
		
		public function SceneLoader()
		{
			super();
			
			plane = new Mesh(new PlaneGeometry(100,100,3,3,true,true), new ColorMaterial(0xffffff, 1));
			plane.rotationX = 90;
			
			var planeMat:ColorMaterial = ColorMaterial(plane.material);
			planeMat.shadowMethod = SceneFX.SHADOW;
			planeMat.lightPicker = SceneFX.LIGHTPICKER;
			
			addChild(plane);
			
			// Show a Trident
			/*var trident:Trident = new Trident();
			trident.scale(0.1);
			addChild(trident);*/
			
			models = new Vector.<AnimatedModel>();
			totalResources = 0;
			numResourcesLoaded = 0;
			addLoaderItems();
		}
		
		public function show():void
		{
			
		}
		
		public function hide():void
		{
			
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
		
		protected function onAssetComplete(e:AssetEvent):void
		{
			trace("Asset loaded.");
		}
		
		protected function onResourceComplete(e:LoaderEvent):void
		{
			trace("Resource complete.");
			
			numResourcesLoaded++;
			
			if(numResourcesLoaded == totalResources) {
				onAllResourcesLoaded();
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function onAllResourcesLoaded():void
		{
			trace("-------------------------------");
			trace("------ RESOURCES LOADED! ------");
			trace("-------------------------------");
		}
	}
}