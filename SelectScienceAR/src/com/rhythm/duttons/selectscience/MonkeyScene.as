package com.rhythm.duttons.selectscience
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
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
		
		public function MonkeyScene()
		{
			trace("Monkey Scene");
			super();
			
			var plane:Mesh = new Mesh(new PlaneGeometry(100,100,3,3,true,true), new ColorMaterial(0xffffff, 1));
			plane.rotationX = 90;
			addChild(plane);
			
			monkeyFull = new ObjectContainer3D();
			addChild(monkeyFull);
			
			glassesScaler = new ObjectContainer3D();
			monkeyFull.addChild(glassesScaler);
			
			monkeyFull.rotationX = -90;
			monkeyFull.rotationZ = 0;
			monkeyFull.rotationY = 90;
			monkeyFull.z = 50;
			
			//monkeyFull.scale(20);
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
			// reset animation
			TweenMax.killTweensOf(monkeyFull);
			TweenMax.killTweensOf(glassesScaler);
			
			monkeyAnimator.reset("monkeymonkey", 0);
			glassesAnimator.reset("monkeyglassesmonkeyglasses", 0);
			monkeyFull.scaleX = monkeyFull.scaleY = monkeyFull.scaleZ = 0;
			glassesScaler.scaleX = glassesScaler.scaleY = glassesScaler.scaleZ = 0;
			
			TweenMax.to(glassesScaler, 2, {delay:1, scaleX:1, scaleY:1, scaleZ:1, overwrite:2, ease:Back.easeOut});
			TweenMax.to(monkeyFull, 2, {delay:.2, scaleX:20, scaleY:20, scaleZ:20, overwrite:2, ease:Elastic.easeOut});
		}
		
		override public function hide():void
		{
			
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