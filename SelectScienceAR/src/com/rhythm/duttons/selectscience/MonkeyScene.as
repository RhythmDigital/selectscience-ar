package com.rhythm.duttons.selectscience
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
	import com.rhythm.away3D4AR.SceneLoader;
	
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
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;

	public class MonkeyScene extends SceneLoader
	{
		
		[Embed(source="/assets/monkey/MonkeyFlipMonkey.md5mesh", mimeType="application/octet-stream")]
		private var MD5_MONKEY:Class;
		
		[Embed(source="/assets/monkey/MonkeyFlipMonkey.md5anim", mimeType="application/octet-stream")]
		private var MD5_MONKEY_ANIM:Class;
		
		[Embed(source="/assets/monkey/MonkeyFlipGlasses.md5mesh", mimeType="application/octet-stream")]
		private var MD5_GLASSES:Class;
		
		[Embed(source="/assets/monkey/MonkeyFlipGlasses.md5anim", mimeType="application/octet-stream")]
		private var MD5_GLASSES_ANIM:Class;
		
		[Embed(source="/MONKEYMESH_Painted.png", mimeType="image/png")]
		private var TEXTURE:Class;
		
		[Embed(source="/assets/audio/chimp1.mp3")]
		private var MONKEY_SFX_1:Class;
		
		private var monkey:Mesh;
		private var glasses:Mesh;
		private var monkeySkel:Skeleton;
		private var glassesSkel:Skeleton;
		private var monkeyAnimator:SkeletonAnimator;
		private var glassesAnimator:SkeletonAnimator;
		private var monkeyAnimationSet:SkeletonAnimationSet;
		private var glassesAnimationSet:SkeletonAnimationSet;
		private var monkeyContainer:ObjectContainer3D;
		private var glassesContainer:ObjectContainer3D;
		private var monkeyFull:ObjectContainer3D;
		private var glassesScaler:ObjectContainer3D;
		
		private var monkeyScale:int = 20;
		private var monkeySfx1:Sound;
		private var sc:SoundChannel;
		
		public function MonkeyScene()
		{
			trace("Monkey Scene");
			super();
			
			messageType = 'chimp';
			
			monkeyFull = new ObjectContainer3D();
			addChild(monkeyFull);
			
			glassesScaler = new ObjectContainer3D();
			monkeyFull.addChild(glassesScaler);
			
			monkeyFull.rotationX = -90;
			monkeyFull.rotationZ = -90;
			monkeyFull.rotationY = 90;
			monkeyFull.z = 50;
			monkeyFull.y = -25;
			
			monkeyFull.scale(monkeyScale);
			
			monkeySfx1 = new MONKEY_SFX_1();
		}
		
		// load the model assets
		override protected function addLoaderItems():void
		{
			//trace("LOADING MONKEY BITS!");
			// override
			//loadTexture();
			loadMD5Mesh(MD5_MONKEY, "monkey");
			loadMD5Mesh(MD5_GLASSES, "monkeyglasses");
		}
		
		override public function show():void
		{
			super.show();
			
			// reset animation
			TweenMax.killTweensOf(monkeyFull);
			TweenMax.killTweensOf(glassesScaler);
			
			monkeyAnimator.reset("monkeymonkey", 0);
			glassesAnimator.reset("monkeyglassesmonkeyglasses", 0);
			monkeyFull.scaleX = monkeyFull.scaleY = monkeyFull.scaleZ = 0;
			glassesScaler.scaleX = glassesScaler.scaleY = glassesScaler.scaleZ = 0;
			
			TweenMax.to(glassesScaler, 2, {delay:.2, scaleX:1, scaleY:1, scaleZ:1, overwrite:2, ease:Back.easeOut});
			TweenMax.to(monkeyFull, 2, {delay:.2, scaleX:monkeyScale, scaleY:monkeyScale, scaleZ:monkeyScale, overwrite:2, ease:Elastic.easeOut});
			
			sc = monkeySfx1.play(0, 9999);
		}
		
		override public function hide():void
		{
			super.hide();
			if(sc) sc.stop();
		}
		
		override protected function onAssetComplete(e:AssetEvent):void
		{
			//trace("NS: " + e.asset.assetNamespace + " / " + e.asset.assetType);
			
			if(e.asset.assetType == AssetType.MESH)
			{
				switch(e.asset.assetNamespace) {
					case "monkey":
						//trace("Monkey Mesh!");
						monkeyContainer = new ObjectContainer3D();
						monkey = Mesh(e.asset);
						monkey.material = null;
						monkeyFull.addChild(monkey);
						
						break;
					
					case "monkeyglasses":
						//trace("Monkey Glasses!");
						glassesContainer = new ObjectContainer3D();
						glasses = Mesh(e.asset); 
						//glassesScale = glasses.scaleX;
						glasses.material = null;
						glassesScaler.addChild(glasses);
					break;
				}
				
				//addChild(Mesh(e.asset));
				
			} else if (e.asset.assetType == AssetType.SKELETON) {
				
				var skel:Skeleton = e.asset as Skeleton;
				
				switch(e.asset.assetNamespace) {
					case "monkey":
						//trace("Monkey Skeleton!");
						monkeySkel = skel;
						break;
					
					case "monkeyglasses":
						//trace("Glasses Skeleton!");
						glassesSkel = skel;
						break;
				}
				
			} else if (e.asset.assetType == AssetType.ANIMATION_SET) {
				
				var animSet:SkeletonAnimationSet = e.asset as SkeletonAnimationSet;
				
				switch(e.asset.assetNamespace) {
					case "monkey":
						//trace("Monkey Animation Set!");
						monkeyAnimationSet = animSet;
						monkeyAnimator = new SkeletonAnimator(monkeyAnimationSet, monkeySkel);
						loadMD5Animation(new MD5_MONKEY_ANIM, "monkey");
						//
						break;
					
					case "monkeyglasses":
						//trace("Glasses Animation Set!");
						glassesAnimationSet = animSet;
						glassesAnimator = new SkeletonAnimator(glassesAnimationSet, glassesSkel);
						loadMD5Animation(new MD5_GLASSES_ANIM, "monkeyglasses");
						//
						break;
				}
				
			} else if (e.asset.assetType == AssetType.ANIMATION_NODE) {
				
				var node:SkeletonClipNode = e.asset as SkeletonClipNode;
				var name:String = e.asset.assetNamespace;
				node.name = e.asset.assetNamespace+name;
				trace("Animation: " + node.name);
				node.looping = true;
				
				switch(e.asset.assetNamespace) {
					case "monkey":
					//trace("Monkey Animation Ready!");
					monkeyAnimationSet.addAnimation(node);
					monkeyAnimator.play(node.name);
					monkey.animator = monkeyAnimator;
					monkey.material = new TextureMaterial(Cast.bitmapTexture(new TEXTURE));
					/*TextureMaterial(monkey.material).lightPicker = new StaticLightPicker([FullscreenARView.LIGHT]);
					TextureMaterial(monkey.material).shadowMethod = new HardShadowMapMethod(FullscreenARView.LIGHT);
					TextureMaterial(monkey.material).specular = .25;
					TextureMaterial(monkey.material).gloss = 20;*/
					
					break;
					
					case "monkeyglasses":
					//trace("Glasses Animation Ready!");
					glassesAnimationSet.addAnimation(node);
					glassesAnimator.play(node.name);
					glasses.animator = glassesAnimator;
					glasses.material = new ColorMaterial(0x000000, 1);// new TextureMaterial(Cast.bitmapTexture(new TEXTURE));
					/*ColorMaterial(glasses.material).lightPicker = new StaticLightPicker([FullscreenARView.LIGHT]);
					ColorMaterial(glasses.material).shadowMethod = new HardShadowMapMethod(FullscreenARView.LIGHT);
					ColorMaterial(glasses.material).specular = .25;
					ColorMaterial(glasses.material).gloss = 20;*/
					break;
				}
				
			}
			
		}
		
		override protected function onResourceComplete(e:LoaderEvent):void
		{
			trace("Resource complete.");
			super.onResourceComplete(e);
		}
	}
}