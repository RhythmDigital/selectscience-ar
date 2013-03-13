package
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.rhythm.away3D4AR.Constants;
	import com.rhythm.away3D4AR.SceneFX;
	import com.rhythm.display.FullscreenARView;
	import com.rhythm.duttons.selectscience.FlaskScene;
	import com.rhythm.duttons.selectscience.MonkeyScene;
	import com.rhythm.duttons.selectscience.RetroVirusScene;
	import com.rhythm.utils.Maths;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.lights.PointLight;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.primitives.WireframeSphere;
	
	[SWF(width="1280", height="720", frameRate="30", backgroundColor="#c2c2c2")] 
	public class AwaySceneTest extends Sprite
	{
		private var view:View3D;
		private var monkey:MonkeyScene;
		private var retro:RetroVirusScene;
		private var flask:FlaskScene;
		private var numDone:int;
		private var total:int;
		
		private var world:ObjectContainer3D;
		private var mover:ObjectContainer3D;
		private var rotateAxis:Vector3D = new Vector3D(0,0.5,0);
		private var light:PointLight;
		
		public function AwaySceneTest()
		{
			view = new View3D(null);
			view.antiAlias = 3;
			addChild(view);
			
			addChild(new AwayStats);
			
			world = new ObjectContainer3D();
			world.rotationX = -135;
			world.y = -100;
			world.scale(2);
			
			mover = new ObjectContainer3D();
			mover.y = 0;
			mover.addChild(world);
			
			view.scene.addChild(mover);
			
			initLights();
			initModels();
		}
		
		private function initLights():void
		{
			//body material
			//bodyMaterial = new TextureMaterial(Cast.bitmapTexture(TEXTURE));
			//bodyMaterial.gloss = 20;
			//bodyMaterial.specular = 1.5;
			//bodyMaterial.specularMap = Cast.bitmapTexture(BodySpecular);
			//bodyMaterial.normalMap = Cast.bitmapTexture(BodyNormals);
			//bodyMaterial.addMethod(fogMethod);
			//bodyMaterial.lightPicker = lightPicker;
			//bodyMaterial.shadowMethod = shadowMapMethod;
			
			//add stats panel
			light = new PointLight();
			light.castsShadows = true;
			light.shadowMapper.depthMapSize = 1024;
			light.color = 0xffffff;
			light.diffuse = 0.7;
			light.specular = 0.6;
			light.radius = 500;
			light.fallOff = 700;
			light.ambient = 0xa0a0c0;
			light.ambient = 0.3;	
			
			var sphere:WireframeSphere = new WireframeSphere(20, 4,4,0xff0000, 2);
			sphere.y = 0;
			sphere.z = -300;
			sphere.x = -200;
			
			//view.scene.addChild(sphere);
			/*
			if(Constants.DEBUG_MODE) {
				var trident:Trident = new Trident();
				trident.scale(1);
				view.scene.addChild(trident);
			}
			*/
			
			light.x = sphere.x;
			light.y = sphere.y;
			light.z = sphere.z;
			
			TweenMax.allTo([sphere,light], 3, {x:200, repeat:-1, yoyo:true, ease:Quad.easeInOut, overwrite:2});
			TweenMax.allTo([sphere,light], 2, {y:400, repeat:-1, yoyo:true, ease:Quad.easeInOut, overwrite:2});
			
			SceneFX.LIGHT = light;
			SceneFX.LIGHTPICKER = new StaticLightPicker([SceneFX.LIGHT]);
			SceneFX.SHADOW = new HardShadowMapMethod(SceneFX.LIGHT);
			SceneFX.SHADOW.alpha=0.3;
			
			view.scene.addChild(light);
			
		}
		
		protected function onEnterFrame(e:Event):void
		{
			var xPos:Number = Maths.map(mouseX, 0, stage.stageWidth, -1000, 1000);
			var zPos:Number = Maths.map(mouseY, 0, stage.stageHeight, -1000, -300);

			view.camera.z = zPos;
			view.camera.x = xPos;
			//mover.rotationY = yRotation;
			//mover.rotate(rotateAxis, 1);
			//view.camera.y = 0;
			view.camera.lookAt(mover.position);
			view.render();
		}
		
		private function initModels():void
		{
			monkey = new MonkeyScene();
			monkey.addEventListener(Event.COMPLETE, onComplete);
			world.addChild(monkey);
			monkey.x = -150;
			
			flask = new FlaskScene();
			flask.addEventListener(Event.COMPLETE, onComplete);
			world.addChild(flask);
			
			retro = new RetroVirusScene();
			retro.addEventListener(Event.COMPLETE, onComplete);
			world.addChild(retro);
			retro.x = 150;
			
			total = 3;
			numDone = 0;
		}
		
		protected function onComplete(event:Event):void
		{
			numDone ++;
			trace("COMPLETE!");
			if(numDone == total) {
				trace("DONE!");
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode) {
				case Keyboard.NUMBER_1:
					trace("MONKEY");
					//world.addChild(monkey);
					monkey.show();
					
					break;
				case Keyboard.NUMBER_2:
					trace("FLASK");
					//world.addChild(flask);
					flask.show();
					break;
				case Keyboard.NUMBER_3:
					trace("RETRO");
					//world.addChild(retro);
					retro.show();
					break;
			}
		}
		
		protected function onKeyUp(e:KeyboardEvent):void
		{
			switch(e.keyCode) {
				case Keyboard.NUMBER_1:
					monkey.hide();
					break;
				case Keyboard.NUMBER_2:
					flask.hide();
					break;
				case Keyboard.NUMBER_3:
					retro.hide();
					break;
			}
		}
	}
}