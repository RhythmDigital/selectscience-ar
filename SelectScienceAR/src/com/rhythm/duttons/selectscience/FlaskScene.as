package com.rhythm.duttons.selectscience
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Quad;
	import com.rhythm.away3D4AR.AnimatedModel;
	import com.rhythm.away3D4AR.Constants;
	import com.rhythm.away3D4AR.SceneFX;
	import com.rhythm.away3D4AR.SceneLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.AssetType;
	import away3d.lights.PointLight;
	import away3d.loaders.parsers.DAEParser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.primitives.WireframeSphere;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	public class FlaskScene extends SceneLoader
	{
		[Embed(source="/assets/flask/BOTTLE.dae", mimeType="application/octet-stream")]
		private var DAE_BOTTLE:Class;
		
		[Embed(source="/assets/flask/MALE.dae", mimeType="application/octet-stream")]
		private var DAE_MALE:Class;
		
		[Embed(source="/assets/flask/Female.dae", mimeType="application/octet-stream")]
		private var DAE_FEMALE:Class;
		
		private var flask:ObjectContainer3D;
		private var bottle:Mesh;
		private var flaskMaterial:FlaskMaterial;
		private var flaskTextureBMD:BitmapData;
		private var flaskTextureMat:BitmapTexture;
		//private var flaskYOffset:int = 0;
		
		private var avg:Array = [];
		private var flaskTextureMtx:Matrix;
		private var light1:PointLight;
		private var light2:PointLight;
		private var lightPicker:StaticLightPicker;
		private var shadowMap:HardShadowMapMethod;
		
		public function FlaskScene()
		{
			super();
			
			flask = new ObjectContainer3D();
			flask.rotationX = 90;
			//flask.z = flaskYOffset;
			flask.scale(10);
			//flask.scaleX = 10;
			addChild(flask);
			
			
		}
		
		// load the model assets
		override protected function addLoaderItems():void
		{
			loadModel(new DAE_BOTTLE, "bottle", new DAEParser);
			loadModel(new DAE_MALE, "female", new DAEParser);
			loadModel(new DAE_FEMALE, "male", new DAEParser);
			
		}
		
		override public function show():void
		{
			super.show();
			// reset animation
		//
			TweenMax.killTweensOf(flask);
			flask.scaleY = 0; 
			flask.scaleZ = 0;
			//flask.z = flaskYOffset;
			
			TweenMax.to(flask, 1, {delay:.2, scaleY:10, overwrite:2, ease:Elastic.easeOut});
			TweenMax.to(flask, 1.6, {delay:.3, scaleZ:10, overwrite:2, ease:Elastic.easeOut});
		}
		
		override public function hide():void
		{
			super.hide();
		}
		
		override protected function onAssetComplete(e:AssetEvent):void
		{
			//trace("!!! " + e.assetPrevName);
			trace(e.asset.assetNamespace + " ==> " + e.asset.assetType);
			
			// skel
			// mesh
			// animNode
			// 
			
			var m:AnimatedModel = getModelByName(e.asset.assetNamespace);
			
			if(e.asset.assetType == AssetType.MESH) {
				
				m.mesh = new Mesh(Mesh(e.asset).geometry, null);
				
				if(e.asset.assetNamespace == "bottle") {
					bottle = m.mesh;
					//bottle.showBounds = true;
					
				}
				//m.mesh.z = 0;//3;
				flask.addChild(m.mesh);
				
			} else if (e.asset.assetType == AssetType.SKELETON) {
				
				trace("Skeleton");
				m.skeleton = e.asset as Skeleton;
				
				
			} else if (e.asset.assetType == AssetType.ANIMATION_SET) {
				
				trace("SkeletonAnimationSet");
				m.animationSet = e.asset as SkeletonAnimationSet;
				m.animator = new SkeletonAnimator(m.animationSet, m.skeleton);
				
			} else if(e.asset.assetType == AssetType.ANIMATION_NODE) {
				
				var node:SkeletonClipNode = e.asset as SkeletonClipNode;
				var name:String = e.asset.assetNamespace;
				node.name = e.asset.assetNamespace+name;
				trace("SkeletonClipNode: " + node.name);
				
				m.animationNode = node;
			}
			
		}
		
		override protected function onResourceComplete(e:LoaderEvent):void
		{
			trace("Flask complete.");
			
			super.onResourceComplete(e);
		}
		
		private function redrawBottleTexture():void
		{
			flaskTextureBMD.lock();
			flaskTextureBMD.draw(flaskMaterial, flaskTextureMtx);
			flaskTextureBMD.unlock();
			flaskTextureMat.invalidateContent();
		}
		
		override protected function initCustomMaterials():void
		{
			initLights();
			
			flaskMaterial = new FlaskMaterial();
			flaskMaterial.gotoAndStop(1);
			
			flaskTextureMtx = new Matrix();
			flaskTextureMtx.scale(1,1);
			flaskTextureBMD = new BitmapData(256, 256, true, 0x00000000);
			flaskTextureMat = Cast.bitmapTexture(flaskTextureBMD);
			
			redrawBottleTexture();	
			
			
			bottle.material = new TextureMaterial(flaskTextureMat);
			
			var botMat:TextureMaterial = TextureMaterial(bottle.material);
			// botMat.alphaThreshold = 0.1;
			botMat.gloss = 40;
			botMat.bothSides = true;
			botMat.specular = 10;
			botMat.alpha = .99;
			// botMat.shadowMethod = shadowMap;
			botMat.lightPicker = lightPicker;
			//botMat.alphaBlending = true;
			botMat.animateUVs = true; // animate uv's
			botMat.repeat = true; // infinate loop material (for uv animation)
			bottle.subMeshes[0].offsetU = 1;
			
			var maleModel:AnimatedModel = getModelByName("male");
			var femaleModel:AnimatedModel = getModelByName("female");
			
			// Male Material
			var maleMat:ColorMaterial = maleModel.getNewColourMaterial(0x8dcc, 1);
			maleModel.mesh.material = maleMat;
			//maleMat.shadowMethod = shadowMap;
			maleMat.lightPicker = lightPicker;
			
			// Female Material
			var femaleMat:ColorMaterial = femaleModel.getNewColourMaterial(0xcc558a, 1); 
			femaleModel.mesh.material = femaleMat; 
			//femaleMat.shadowMethod = shadowMap;
			femaleMat.lightPicker = lightPicker;
		}
		
		private function initLights():void
		{
			///add stats panel
			light1 = new PointLight();
			light2 = new PointLight();
			
			light1.castsShadows = true;
			light1.shadowMapper.depthMapSize = 1024;
			
			light1.color = 0xffffff;
			light2.color = 0xffff88;
			
			light1.diffuse = 0.7;
			light2.diffuse = 0.7;
			
			light1.specular = 10;
			light2.specular = .3;
			light1.radius = light2.radius = 1000;
			light1.fallOff = light2.fallOff = 700;
			light1.ambient = light2.ambient = 0xffff66;
			light1.ambient = light2.ambient = 0.5;
			
			light1.x = 100;
			light1.y = 120;
			light1.z = -50;
			
			light1.x = 200;
			light1.y = 10;
			light1.z = 200;
			
			lightPicker = new StaticLightPicker([light1]);
			
			addChild(light1);		
			// addChild(light2);	
			
			shadowMap = new HardShadowMapMethod(light1);
			shadowMap.alpha=0.3;
			
			ColorMaterial(plane.material).shadowMethod = shadowMap;
			ColorMaterial(plane.material).lightPicker = lightPicker;
			
			//TweenMax.allTo([sphere,light], 3, {x:200, repeat:-1, yoyo:true, ease:Quad.easeInOut, overwrite:2});
			//TweenMax.allTo([sphere,light], 2, {y:0, repeat:-1, yoyo:true, ease:Quad.easeInOut, overwrite:2});
			//TweenMax.allTo([sphere,light], 1, {z:250, repeat:-1, yoyo:true, ease:Quad.easeInOut, overwrite:2});
		}
		
		override public function update():void
		{
			redrawBottleTexture();
			bottle.subMeshes[0].offsetU += 0.01; // how fast the texture rotates.
		}	
		
		override protected function onAllResourcesLoaded():void
		{
			getModelByName("bottle").init();
			getModelByName("male").init();
			getModelByName("female").init();
			
			super.onAllResourcesLoaded();
		}
	}
}