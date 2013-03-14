package com.rhythm.away3D4AR
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.utils.Timer;
	
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;

	public class A3DParticleEmitter
	{
		private var ticker:MovieClip = new MovieClip();
		private var t:Timer;
		private var props:Object;
		private var particleTypes:Array = [];
		private var particles:Vector.<A3DParticle>;
		private var pool:Vector.<A3DParticle>;
		
		public function A3DParticleEmitter(props:Object)
		{
			this.props = props;
			
			particles = new Vector.<A3DParticle>();
			pool = new Vector.<A3DParticle>();
			
			t = new Timer(20);
			t.addEventListener(TimerEvent.TIMER, onTimerTick);
			
			ticker.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			update();
		}
		
		public function start():void
		{
			t.start();
		}
		
		public function stop():void
		{
			t.stop();
		}
		
		public function update():void
		{
			var p:A3DParticle;
			
			for each(p in particles) {
				p.update();
			}
		}
		
		public function addParticle(mesh:Mesh, mat:MaterialBase):void
		{
			particleTypes.push({geom:mesh.geometry, mat:mat});
		}
		
		protected function onTimerTick(e:TimerEvent):void
		{
			var p:A3DParticle = createParticle();			
			resetParticle(p);
		}
		
		private function createParticle():A3DParticle
		{
			var p:A3DParticle;
			
			if (pool.length) p = pool.shift();
			else {			
				var seed:int = Math.floor(Math.random()*particleTypes.length);
				p = new A3DParticle(particleTypes[seed].geom.clone(), particleTypes[seed].mat);
			}	
			
			return p;
		}
		
		public function deadParticle(p:A3DParticle):void
		{
			pool.push(particles.splice(particles.indexOf(p), 1)[0]);
			props.targ.removeChild(p);
			
			trace('PARTICLES:', particles.length, pool.length);
		}
		
		private function resetParticle(p:A3DParticle):void
		{
			p.reset();
			p.deadCallback = deadParticle;
			p.tick = 0;
			
			var tempEmitterTransform:Matrix3D = props.follow.transform.clone();
			
			// shift it
			props.follow.x += Math.random();
			props.follow.z += Math.random();
			
			// set particle transform
			p.transform = props.follow.sceneTransform;
			
			// reset it
			props.follow.transform = tempEmitterTransform;
			
			p.scaleX = p.scaleY = p.scaleZ = 0.014;
			
			particles.push(p);
			props.targ.addChild(p);
		}
	}
}