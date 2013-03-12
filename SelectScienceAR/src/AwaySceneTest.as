package
{
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
		
		public function AwaySceneTest()
		{
			view = new View3D(null);
			view.antiAlias = 3;
			addChild(view);
			
			addChild(new AwayStats);
			
			world = new ObjectContainer3D();
			world.rotationX = -90;
			world.y = -100;
			world.scale(2);
			
			mover = new ObjectContainer3D();
			mover.y = 0;
			mover.addChild(world);
			
			view.scene.addChild(mover);
			
			
			initModels();
		}
		
		protected function onEnterFrame(e:Event):void
		{
			var yRotation:Number = Maths.map(mouseX, 0, stage.stageWidth, -180, 180);
			var zPos:Number = Maths.map(mouseY, 0, stage.stageHeight, 500, -1000);

			mover.z = zPos;
			mover.rotationY = yRotation;
			//mover.rotate(rotateAxis, 1);
			view.camera.y = 0;
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