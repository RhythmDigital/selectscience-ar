package com.rhythm.duttons.selectscience
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.rhythm.away3D4AR.A3DParticle;
	import com.rhythm.away3D4AR.A3DParticleEmitter;
	import com.rhythm.away3D4AR.AnimatedModel;
	import com.rhythm.away3D4AR.Constants;
	import com.rhythm.away3D4AR.SceneLoader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.AssetType;
	import away3d.lights.PointLight;
	import away3d.loaders.parsers.DAEParser;
	import away3d.loaders.parsers.OBJParser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.primitives.WireframeCube;
	import away3d.textures.BitmapTexture;
	import away3d.tools.utils.Bounds;
	import away3d.utils.Cast;
	
	public class FlaskScene extends SceneLoader
	{
		[Embed(source="/assets/flask/BOTTLE.dae", mimeType="application/octet-stream")]
		private var DAE_BOTTLE:Class;
		
		[Embed(source="/assets/flask/MALE.dae", mimeType="application/octet-stream")]
		private var DAE_MALE:Class;
		
		[Embed(source="/assets/flask/FEMALE.dae", mimeType="application/octet-stream")]
		private var DAE_FEMALE:Class;
		
		[Embed(source="/assets/flask/male_no_mat.obj", mimeType="application/octet-stream")]
		private var OBJ_MALE_SYM:Class;
		
		[Embed(source="/assets/flask/female_no_mat.obj", mimeType="application/octet-stream")]
		private var OBJ_FEMALE_SYM:Class;
		
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

		private var botMat:TextureMaterial;
		private var flaskTextureBMP:Bitmap;
		private var flaskEmitterPoint:ObjectContainer3D;
		private var worldEmitterPoint:ObjectContainer3D;
		private var emitter:A3DParticleEmitter;
		private var femaleMat:ColorMaterial;
		private var maleMat:ColorMaterial;
		
		public function FlaskScene()
		{
			super();
			messageType = 'flask';
			
			flask = new ObjectContainer3D();
			flask.rotationX = 90;
			flask.scale(10);
			addChild(flask);
		}
		
		// load the model assets
		override protected function addLoaderItems():void
		{
			loadModel(new DAE_BOTTLE, "bottle", new DAEParser);
			loadModel(new DAE_MALE, "female", new DAEParser);
			loadModel(new DAE_FEMALE, "male", new DAEParser);
			loadModel(new OBJ_MALE_SYM, "male-obj", new OBJParser);
			loadModel(new OBJ_FEMALE_SYM, "female-obj", new OBJParser);
		}
		
		override public function show():void
		{
			super.show();

			// flaskMaterial.play();
			
			TweenMax.killTweensOf(flask);
			flask.scaleY = 0; 
			flask.scaleZ = 0;
			
			TweenMax.to(flask, 1, {delay:.2, scaleY:10, overwrite:2, ease:Elastic.easeOut});
			TweenMax.to(flask, 1.6, {delay:.3, scaleZ:10, overwrite:2, ease:Elastic.easeOut});
			
			emitter.start();
		}
		
		override public function hide():void
		{
			super.hide();
			
			emitter.stop();
			// flaskMaterial.gotoAndStop(0);
		}
		
		override protected function onAssetComplete(e:AssetEvent):void
		{
			trace(e.asset.assetNamespace + " ==> " + e.asset.assetType);
			
			var m:AnimatedModel = getModelByName(e.asset.assetNamespace);

			if(e.asset.assetType == AssetType.MESH) {
				
				m.mesh = new Mesh(Mesh(e.asset).geometry, null);
				e.asset.dispose();
				
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
		
		override protected function initCustomMaterials():void
		{
			initLights();
			
			flaskMaterial = new FlaskMaterial();
			flaskMaterial.gotoAndStop(1);
			// Constants.stage.addChild(flaskMaterial);
			
			flaskTextureMtx = new Matrix();
			flaskTextureMtx.scale(1,1);
			
			applyBottleTexture();
			
			var maleModel:AnimatedModel = getModelByName("male");
			var femaleModel:AnimatedModel = getModelByName("female");
			
			// Male Material
			maleMat = maleModel.getNewColourMaterial(0x8dcc, 1);
			maleModel.mesh.material = maleMat;
			//maleMat.shadowMethod = shadowMap;
			maleMat.lightPicker = lightPicker;
			
			// Female Material
			femaleMat = femaleModel.getNewColourMaterial(0xcc558a, 1); 
			femaleModel.mesh.material = femaleMat; 
			//femaleMat.shadowMethod = shadowMap;
			femaleMat.lightPicker = lightPicker;
		}
		
		private function applyBottleTexture():void
		{						
			redrawBottleTexture();			
			
			if (botMat) botMat = null;
			botMat = new TextureMaterial(flaskTextureMat);

			botMat.gloss = 40;
			botMat.bothSides = true;
			botMat.specular = 10;
			botMat.alpha = .99;
			botMat.lightPicker = lightPicker;
			
			bottle.material = botMat;
		}
		
		private function redrawBottleTexture():void
		{
			if (flaskTextureBMD) 
			{
				flaskTextureBMD.dispose();
				flaskTextureBMD = null;
			}			
			
			if (!flaskTextureBMP)
			{
				flaskTextureBMP = new Bitmap();
				flaskTextureBMP.x = 257;
				// Constants.stage.addChild(flaskTextureBMP);
			}
			
			flaskTextureBMD = new BitmapData(256, 256, true, 0x00000000);
			flaskTextureBMP.bitmapData = flaskTextureBMD;			
			
			flaskTextureMat = Cast.bitmapTexture(flaskTextureBMD);
			
			flaskTextureBMD.lock();
			flaskTextureBMD.draw(flaskMaterial, flaskTextureMtx);
			flaskTextureBMD.unlock();
			flaskTextureMat.invalidateContent();
		}
		
		private function initLights():void
		{
			///add stats panel
			if (!light1) light1 = new PointLight();
			
			light1.castsShadows = true;
			light1.shadowMapper.depthMapSize = 1024;
			
			light1.color = 0xffffff;			
			light1.diffuse = .7;
		
			light1.specular = 10;
			light1.radius = 10000;
			light1.fallOff = 7000;
 			light1.ambient = 0xffff66;
			light1.ambient = 0.5;
			
			light1.x = 200;  // left - right
			light1.y = 100; // up - down
			light1.z = 200; // forwards - backwards
			
			if (!lightPicker) lightPicker = new StaticLightPicker([light1]);
			else lightPicker.lights = [light1];
			
			addChild(light1);		
			
			if (!shadowMap) shadowMap = new HardShadowMapMethod(light1);			
			shadowMap.alpha = 0.3;
			
			ColorMaterial(plane.material).shadowMethod = shadowMap;
			ColorMaterial(plane.material).lightPicker = lightPicker;
		}
		
		override public function update():void
		{
			// applyBottleTexture();
			// initLights();
			//point2.lookAt(point1.position);
			
			worldEmitterPoint.transform =  flaskEmitterPoint.sceneTransform;
			
			
		//	flask.rotationX ++;
		}	
		
		override protected function onAllResourcesLoaded():void
		{
			getModelByName("bottle").init();
			getModelByName("male").init();
			getModelByName("female").init();
			
			flaskEmitterPoint = new WireframeCube(0.1,0.1,0.1,0xff0000,1);
			Bounds.getMeshBounds(getModelByName("bottle").mesh);
			flaskEmitterPoint.y = Bounds.height - 4;
			
			worldEmitterPoint = new WireframeCube(0.6,0.6,0.6,0x00FF00,1);
			
			flask.addChild(flaskEmitterPoint);
			
			//worldEmitterPoint.addChild(new Trident(1000));
			//Constants.scene.addChild(worldEmitterPoint);
			
			
			emitter = new A3DParticleEmitter({targ:Constants.scene, follow:flaskEmitterPoint});
			emitter.addParticle(getModelByName("male-obj").mesh, new ColorMaterial(0x8dcc, 1));
			emitter.addParticle(getModelByName("female-obj").mesh, new ColorMaterial(0xcc558a, 1));
			
			super.onAllResourcesLoaded();
		}
	}
}