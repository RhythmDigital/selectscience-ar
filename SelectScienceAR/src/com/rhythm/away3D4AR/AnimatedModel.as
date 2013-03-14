package com.rhythm.away3D4AR
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.entities.Mesh;
	import away3d.events.AnimationStateEvent;
	import away3d.events.AnimatorEvent;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;

	public class AnimatedModel extends EventDispatcher
	{
		public var name:String;
		public var mMesh:Mesh;
		public var skeleton:Skeleton;
		public var animator:SkeletonAnimator;
		public var animationSet:SkeletonAnimationSet;
		public var animationNode:SkeletonClipNode;
		public var material:MaterialBase;
		private var tempMaterial:MaterialBase;
		private var t:Timer;
		
		public function AnimatedModel(name:String)
		{
			super();
			this.name = name;
			trace(this + " created.");
		}
		
		public function set mesh(m:Mesh):void
		{
			mMesh = m;
			mMesh.material = null;
			//mMesh.material = getNewColourMaterial(Math.random()*0xFFFFFF, .7);
		}
		
		public function get mesh():Mesh
		{
			return mMesh;
		}
		
		public function getNewColourMaterial(mCol:uint = 0xff0000, mAlpha:int = 1):ColorMaterial
		{
			var mat:ColorMaterial = new ColorMaterial(mCol, mAlpha);
			
			if(mAlpha < 1) {
				mat.alpha = 1;
				mat.alphaBlending = true;
				mat.alphaThreshold = 0.5;
				mat.bothSides = true;
			}
			
			return mat;
		}
		
		public function init():void
		{
			trace(name + " initialised.");
			animationNode.name = "default";
			//animationNode.stitchFinalFrame = true;
			animationNode.looping = true;
			animationSet.addAnimation(animationNode);
			mesh.animator = animator;
			
			animator.updatePosition = true;
			
			restartAnimation();
		}
		
		public function restartAnimation():void
		{
			if(!t) {
				animator.play("default");
				resetMeshPos();
				t = new Timer(animationNode.totalDuration);
				t.addEventListener(TimerEvent.TIMER, onTimerTick);
				t.start();
			} else {
				//animator.stop();
				
				resetMeshPos();
				animator.reset("default", 0);
				//animator.start();
				t.reset();
				t.start();
			}
		}
		
		protected function onTimerTick(e:TimerEvent):void
		{
			trace(name + " RESET ANIMATION");
			t.stop();
			restartAnimation();
			
			dispatchEvent(new Event("ANIMATION_LOOP_COMPLETE"));
		}
		
		public function resetMeshPos():void
		{
			mesh.x = 0;
			mesh.y = 0;
			mesh.z = 0;
		}
		
		override public function toString():String
		{
			return "AnimatedModel => " + name;
		}
	}
}