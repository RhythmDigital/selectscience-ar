package com.rhythm.away3D4AR
{
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;

	public class AnimatedModel
	{
		public var name:String;
		public var mMesh:Mesh;
		public var skeleton:Skeleton;
		public var animator:SkeletonAnimator;
		public var animationSet:SkeletonAnimationSet;
		public var animationNode:SkeletonClipNode;
		private var tempMaterial:MaterialBase;
		
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
			mat.alpha = .7;
			mat.alphaBlending = true;
			mat.alphaThreshold = 0.3;
			mat.bothSides = true;
			return mat;
		}
		
		public function initAnimation():void
		{
			trace("Animation initialised.");
			animationNode.name = "default";
			animationSet.addAnimation(animationNode);
			mesh.animator = animator;
			animator.play("default");//animationNode.name);
		}
		
		public function toString():String
		{
			return "AnimatedModel => " + name;
		}
	}
}