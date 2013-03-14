package com.rhythm.duttons.selectscience
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quint;
	import com.greensock.easing.Sine;
	import com.rhythm.away3D4AR.AnimatedModel;
	import com.rhythm.away3D4AR.SceneLoader;
	
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
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
	
	public class RetroVirusScene extends SceneLoader
	{
		[Embed(source="/assets/virus/IdleAnimation.dae", mimeType="application/octet-stream")]
		private var DAE_VIRUS_IDLE:Class;
		
		[Embed(source="/assets/virus/DanceAnimationNoAfro.dae", mimeType="application/octet-stream")]
		private var DAE_VIRUS_DANCE:Class;
		
		[Embed(source="/assets/virus/DanceAnimation_JustAfro.dae", mimeType="application/octet-stream")]
		private var DAE_VIRUS_DANCE_AFRO:Class;
		
		[Embed(source="/assets/audio/disco1.mp3")]
		private var DISCO_MUSIC:Class;

		private var virus:ObjectContainer3D;
		private var virusIdleMesh:Mesh;
		private var virusDanceMesh:Mesh;
		private var virusDanceAfroMesh:Mesh;
		private var discoMusic:Sound;
		private var sc:SoundChannel;
		
		private var virusScale:int = 2;
		
		public function RetroVirusScene()
		{
			super();
			
			messageType = 'virus';
			discoMusic = new DISCO_MUSIC();
			
			virus = new ObjectContainer3D();
			virus.rotationX = 90;
			virus.z = 17;
			virus.scale(virusScale);
			addChild(virus);
		}
		
		// load the model assets
		override protected function addLoaderItems():void
		{
			loadModel(new DAE_VIRUS_IDLE, "virus_idle", new DAEParser);
			loadModel(new DAE_VIRUS_DANCE, "virus_dance", new DAEParser);
			loadModel(new DAE_VIRUS_DANCE_AFRO, "virus_dance_afro", new DAEParser);
		}
		
		override public function show():void
		{
			super.show();
			
			TweenMax.killTweensOf(virus);
			TweenMax.killDelayedCallsTo(dance);
			
			virus.scaleY = 0; 
			virus.scaleZ = 0;
			virus.rotationZ = 0;
			
			//getModelByName("virus_idle").restartAnimation();
			
			TweenMax.to(virus, 1, {delay:.2, scaleY:virusScale, overwrite:2, ease:Elastic.easeOut});
			TweenMax.to(virus, 1.6, {delay:.3, scaleZ:virusScale, overwrite:2, ease:Elastic.easeOut, onComplete:dance});
		}
		
		override public function hide():void
		{
			super.hide();
			if(sc) sc.stop();
			
			TweenMax.killDelayedCallsTo(dance);
			TweenMax.killTweensOf(virus);
			
			if(virus.contains(virusDanceMesh)) {
				virus.removeChild(virusDanceMesh);
				virus.removeChild(virusDanceAfroMesh);
				virus.addChild(virusIdleMesh);
			}
		}
		
		private function dance():void
		{
			trace("DANCE!");
			
			if(virus.contains(virusIdleMesh))
			{
				virus.removeChild(virusIdleMesh);
			}
			
			virus.addChild(virusDanceAfroMesh);
			virus.addChild(virusDanceMesh);
			
			sc = discoMusic.play(0,9999);
			
			TweenMax.to(virus, 1, {rotationZ: 1080, ease:Expo.easeOut, overwrite:2});
		}
		
		override protected function onAssetComplete(e:AssetEvent):void
		{
			trace(e.asset.assetNamespace + " ==> " + e.asset.assetType);
			
			var m:AnimatedModel = getModelByName(e.asset.assetNamespace);
			
			if(e.asset.assetType == AssetType.MESH) {
				
				m.mesh = Mesh(e.asset);
				
				if(e.asset.assetNamespace == "virus_idle") {
					// idle mesh
					virusIdleMesh = m.mesh;
					virus.addChild(virusIdleMesh);
					
				} else if(e.asset.assetNamespace == "virus_dance") {
					// dance mesh
					virusDanceMesh = m.mesh;
				} else if(e.asset.assetNamespace == "virus_dance_afro") {
					// dance mesh
					virusDanceAfroMesh = m.mesh;
				}
				
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
			/*if(e.asset.assetType == AssetType.MATERIAL) {
				trace("Material: " + e.asset.assetFullPath);
				
			}*/
		}
		
		override protected function onResourceComplete(e:LoaderEvent):void
		{
			trace("Flask complete.");
			super.onResourceComplete(e);
		}
		
//		override public function update():void {
//			trace("----\nBODY: " + getModelByName("virus_dance").animator.time);
//			trace("AFRO: " + getModelByName("virus_dance_afro").animator.time+"\n----");
//		}
		
		override protected function onAllResourcesLoaded():void
		{
			getModelByName("virus_idle").init();
			getModelByName("virus_dance_afro").init();
			
			var virusBodyModel:AnimatedModel = getModelByName("virus_dance");
			virusBodyModel.init();
			virusBodyModel.addEventListener("ANIMATION_LOOP_COMPLETE", onBodyAnimationComplete);
			
			super.onAllResourcesLoaded();
		}
		
		protected function onBodyAnimationComplete(e:Event):void
		{
			trace("RetroVirus Body Animation Complete.");
			getModelByName("virus_dance_afro").restartAnimation();
		}
	}
}