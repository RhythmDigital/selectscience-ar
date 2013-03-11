package com.rhythm.duttons.selectscience
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
	import com.rhythm.away3D4AR.AnimatedModel;
	import com.rhythm.away3D4AR.SceneLoader;
	
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
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	
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
		private var flaskYOffset:int = 0;
		
		public function FlaskScene()
		{
			super();
			
			flask = new ObjectContainer3D();
			flask.rotationX = 90;
			flask.z = flaskYOffset;
			//flask.scale(10);
			flask.scaleX = 10;
			addChild(flask);
			
			var plane:Mesh = new Mesh(new PlaneGeometry(100,100,3,3,true,true), new ColorMaterial(0xffffff, 1));
			plane.rotationX = 90;
			addChild(plane);
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
			TweenMax.killTweensOf(flask);
			flask.scaleY = 0; 
			flask.scaleZ = 0;
			flask.z = flaskYOffset;
			
			TweenMax.to(flask, 1, {delay:.2, scaleY:10, overwrite:2, ease:Elastic.easeOut});
			TweenMax.to(flask, 1.6, {delay:.3, scaleZ:10, overwrite:2, ease:Elastic.easeOut});
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
				
				m.mesh = Mesh(e.asset);
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
				node.looping = true;
				
				m.animationNode = node;
				
				
			}
			
			// adjust materials
			if(e.asset.assetType == AssetType.MATERIAL) {
				//trace("Material: " + e.asset.assetFullPath);
				if(e.asset.assetFullPath.indexOf("Bottle") !== -1) {
					ColorMaterial(e.asset).alpha = .7;
					ColorMaterial(e.asset).alphaBlending = true;
					ColorMaterial(e.asset).alphaThreshold = 0.3;
					ColorMaterial(e.asset).bothSides = true;
					
					trace("Bottle Mat: " + e.asset);
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
			getModelByName("bottle").initAnimation();
			getModelByName("male").initAnimation();
			getModelByName("female").initAnimation();
		}
	}
}