package com.rhythm.away3D4AR
{
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.debug.Trident;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	
	public class A3DParticle extends ObjectContainer3D
	{
		public var dead:Boolean;
		public var mesh:Mesh;
		public var velX:Number;
		public var velY:Number;
		public var velZ:Number;
		public var gravity:Number;
		
		public var speed:Number;
		public var damping:Number;
		
		private var maxScale:Number;
		private var spin:Vector3D;
		
		public var deadCallback:Function;
		public var tick:int;
		private var meshDefaultScale:Number;
		
		
		public function A3DParticle(geom:Geometry, mat:MaterialBase)
		{
			mesh = new Mesh(geom, mat);
			mesh.scale(.3);
			meshDefaultScale = mesh.scaleX;
			addChild(mesh);
			
			// addChild(new Trident);
		}
		
		public function reset():void
		{
			mesh.scaleX = mesh.scaleY = mesh.scaleZ = meshDefaultScale;
			
			velX = 4 - Math.random()*8;
			velY = 3;
			velZ = 4 - Math.random()*8;
			gravity = 0.5;
			
			speed = 1700 + Math.random()*300;
			damping = .92;
			
			maxScale = 1 + Math.random()*.6;
			spin = new Vector3D(3+Math.random()*7, 3+Math.random()*7, 3+Math.random()*7);
		}
		
		public function update():void
		{
			++tick;
			
			mesh.rotationX += spin.x;
			mesh.rotationY += spin.y;
			mesh.rotationZ += spin.z;
			
			moveUp(speed);
			speed *= damping;
			
			y -= velY;
			x -= velX;
			z -= velZ;
			
			mesh.scaleX = mesh.scaleY = mesh.scaleZ = Math.min(maxScale, mesh.scaleX*1.1);
			
			if (tick > 100)
			{	
				// deadCallback(this);
				
				mesh.scaleX = mesh.scaleY = mesh.scaleZ -= 0.2;				
				if (mesh.scaleX <= 0.1) deadCallback(this);
			}
			
		}
	}
}