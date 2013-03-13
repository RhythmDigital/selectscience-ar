package com.rhythm.duttons.selectscience
{
	import com.greensock.TweenMax;
	import com.rhythm.away3D4AR.AnimatedModel;
	import com.rhythm.away3D4AR.SceneLoader;
	import com.rhythm.display.FullscreenARView;
	
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
	import away3d.loaders.parsers.DAEParser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.primitives.PlaneGeometry;
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
		private var plane:Mesh;
		
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
			// reset animation
		//
			TweenMax.killTweensOf(flask);
		//	flask.scaleY = 0; 
		//	flask.scaleZ = 0;
			//flask.z = flaskYOffset;
			
		//	TweenMax.to(flask, 1, {delay:.2, scaleY:10, overwrite:2, ease:Elastic.easeOut});
		//	TweenMax.to(flask, 1.6, {delay:.3, scaleZ:10, overwrite:2, ease:Elastic.easeOut});
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
				//node.looping = true;
				
				m.animationNode = node;
				
				//TweenMax.to(
			}
			
			// adjust materials
			if(e.asset.assetType == AssetType.MATERIAL) {
				//trace("Material: " + e.asset.assetFullPath);
				if(e.asset.assetFullPath.indexOf("Bottle") !== -1) {
				
					//var mat:MaterialBase = e.asset as MaterialBase;
					//mat.dispose();
					
					flaskMaterial = new FlaskMaterial();
					flaskMaterial.stop();
					
					flaskTextureMtx = new Matrix()
					flaskTextureMtx.scale(0.5,0.5);
					flaskTextureBMD = new BitmapData(1024,1024,true,0x000000);
					flaskTextureMat = Cast.bitmapTexture(flaskTextureBMD);
					
					trace("Bottle Mat: " + flaskTextureMat);
				} else {
					
					//m.material = e.asset as MaterialBase;
					//trace("MATERIAL: " + m.material.name);
//					if(e.asset is ColorMaterial) {
//						trace(ColorMaterial(e.asset).color.toString(16));
//					}
				}
			}
		}
		
		override protected function onResourceComplete(e:LoaderEvent):void
		{
			trace("Flask complete.");
			
			super.onResourceComplete(e);
		}
		
		override protected function onAllResourcesLoaded():void
		{
			flaskTextureBMD.lock();
			flaskTextureBMD.draw(flaskMaterial, flaskTextureMtx);
			flaskTextureBMD.unlock();
			flaskTextureMat.invalidateContent();
			
			bottle.material = new TextureMaterial(flaskTextureMat);
			var botMat:TextureMaterial = TextureMaterial(bottle.material); 
			botMat.gloss = 20;
			///botMat.bothSides = true;
			botMat.specular = 1.5;
			botMat.alpha = .3;
			//botMat.shadowMethod = shadowMap;
			botMat.lightPicker = FullscreenARView.LIGHTPICKER;
			
			
			
			//bottle.material. = new HardShadowMapMethod(FullscreenARView.LIGHT);
			/*
			TextureMaterial(monkey.material).specular = .25;
			TextureMaterial(monkey.material).gloss = 20;
			*/
			//TextureMaterial(bottle.material).alphaBlending = true;
			//TextureMaterial(bottle.material).alphaThreshold = 0.5;
			
			var bottleModel:AnimatedModel = getModelByName("bottle");
			var maleModel:AnimatedModel = getModelByName("male");
			var femaleModel:AnimatedModel = getModelByName("female");
			
			bottleModel.init();
			maleModel.init();
			femaleModel.init();
			
			maleModel.mesh.material = maleModel.getNewColourMaterial(0x8dcc, 1);
			ColorMaterial(maleModel.mesh.material).shadowMethod = FullscreenARView.SHADOW;
			ColorMaterial(maleModel.mesh.material).lightPicker = FullscreenARView.LIGHTPICKER;
			
			femaleModel.mesh.material = femaleModel.getNewColourMaterial(0xcc558a, 1);
			ColorMaterial(femaleModel.mesh.material).shadowMethod = FullscreenARView.SHADOW;
			ColorMaterial(femaleModel.mesh.material).lightPicker = FullscreenARView.LIGHTPICKER;
			
			super.onAllResourcesLoaded();
		}
	}
}