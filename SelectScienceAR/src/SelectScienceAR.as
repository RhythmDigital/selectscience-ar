//https://github.com/away3d/away3d-examples-fp11/blob/master/src/Intermediate_CharacterAnimation.as
//http://away3d.com/forum/viewthread/439/#2906
//https://code.google.com/p/awd/source/browse/#hg/exporters/maya
//http://away3d.com/forum/viewthread/2447/P30/
//http://away3d.com/forum/viewthread/2935/
// http://www.visualiser.fr/blog/index.php?q=content/away3d-4-flartoolkit
// POSSIBLE SOLUTION.

// 1.
// export from maya as *.fbx
//http://www.cg-academy.net/pages/free_tutorials/tut_3dsmax_to_maya_transfer/tut_max_to_maya_mesh&camera_transfer.php

// 2.
// import to 3ds max, and test animation & material is ok.

// 3. export as awd2.

// --- DOESN'T WORK WITH MAX 2013 YET. NEED 2012. CANT FIND IT.

// MD5 ? 
// http://scripts.zbufferstudios.com/

// Collada, why is there errors?

// 3Ds Max 2012 workflow.
// http://away3d.com/tutorials/3DS_Max_Workflow#using
// https://code.google.com/p/awd/wiki/UsingSequencesTxtFiles



// CHARACTER SLIDING ISSUE
// http://away3d.com/forum/viewthread/889/


package
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.PushButton;
	import com.greensock.TweenMax;
	import com.greensock.easing.Sine;
	import com.rhythm.away3D4AR.SceneLoader;
	import com.rhythm.display.FullscreenARView;
	import com.rhythm.duttons.selectscience.FlaskScene;
	import com.rhythm.duttons.selectscience.MonkeyScene;
	import com.rhythm.duttons.selectscience.RetroVirusScene;
	
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.media.Camera;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.lights.PointLight;
	
	
	[SWF(frameRate="30", width="800", height="600", backgroundColor="#000000")]
	public class SelectScienceAR extends FullscreenARView
	{
		[Embed(source="/assets/markers/16/n4_16.pat", mimeType="application/octet-stream")]
		private static var Marker1:Class;
		
		[Embed(source="/assets/markers/16/n1_16.pat", mimeType="application/octet-stream")]
		private static var Marker2:Class;
		
		[Embed(source="/assets/markers/16/n9_16.pat", mimeType="application/octet-stream")]
		private static var Marker3:Class;
		
		[Embed(source="/assets/camera_para_16x9.dat", mimeType="application/octet-stream")]
		private static var CamParam:Class;
		
		private var scenes:Vector.<SceneLoader>;
		private var sceneClasses:Array = [MonkeyScene, FlaskScene, RetroVirusScene];
		private var monkeyScene:MonkeyScene;
		private var flaskScene:FlaskScene;
		private var virusScene:RetroVirusScene;
		
		private var flarParams:Object;	// AR Paramaters
		private var light:PointLight;
		
		private var status:LoadingStatus;
		private var statusID:int = 0;
		private var modelsLoaded:int = 0;
		
		private var startupScreen:Sprite;
		private var idleScreen:IdleScreen;
		private var endMessages:EndMessages;
		
		
		public function SelectScienceAR()
		{
			super();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			status = new LoadingStatus();
			idleScreen = new IdleScreen();
			endMessages = new EndMessages();
			
			showStartupScreen();
		}
		
		protected function onKeyDown(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.ESCAPE) stage.nativeWindow.close();
		}
		
		private function showStartupScreen():void
		{
			stage.nativeWindow.width = 350;
			stage.nativeWindow.height = 250;
			
			startupScreen = new Sprite();
			addChild(startupScreen);
			
			var screens:Array = [];
			var i:int = 0;
			for each(var screen:Screen in Screen.screens){
				screens.push("Screen " + i + ": " + screen.bounds.width + "x" + screen.bounds.height);
					
				i++;
			}
			
			startupScreen.addChild(new SetupText);
			
			
			var screenSelect:ComboBox = new ComboBox(startupScreen, 10, 70, "Please select a screen...", screens);
			screenSelect.width = 330;
			
			var camSelect:ComboBox = new ComboBox(startupScreen, 10, 95, "Please select a camera...", Camera.names);
			camSelect.width = 330;
			
			var goBtn:PushButton = new PushButton(startupScreen, 10, 130, "START", function():void {
				var screenID:int = screenSelect.selectedIndex;
				cameraID = camSelect.selectedIndex > 0 ? camSelect.selectedIndex : 0;				
				removeChild(startupScreen);
				initWithScreen(screenID > 0 ? Screen.screens[screenID] : Screen.mainScreen);
			});
			
			goBtn.width = 150;
			goBtn.height = 80;
			goBtn.x = stage.stageWidth/2 - goBtn.width/2;
			
			stage.nativeWindow.visible = true;
		}
		
		private function updateStatus(msg:String):void
		{
			if(!this.contains(status)) {
				status.x = 0;
				status.y = 0;
				status.txtStatus.autoSize = TextFieldAutoSize.LEFT;
				addChild(status);
			}
			
			status.txtStatus.text = msg;
			status.txtStatus.x = status.dotsAnim.x = (stage.stageWidth >> 1) - (status.txtStatus.textWidth>>1);
			status.txtStatus.y = (stage.stageHeight >> 1) - (status.txtStatus.textHeight>>1);
			
			status.dotsAnim.y = status.txtStatus.y + 100;
			
			statusID++;
		}
		
		override protected function init():void
		{
			super.init();
			
			
			updateStatus("Loading...");
			
			flarParams = {
				camPattern:CamParam, 
				markers:[new Marker1, new Marker2, new Marker3]
			};
			
			scenes = new Vector.<SceneLoader>();
			
			start(flarParams);
		}
		 
		override protected function init3D():void
		{
			super.init3D();
			
			//addChild(new AwayStats(view));
			
			modelsLoaded++;
			updateStatus("Loading 3D Models (" + modelsLoaded + "/3)...");
		}
		
		override protected function constructScene(container:ObjectContainer3D, id:int):void
		{
			trace("Building scene : " + id);
			scenes[id] = new sceneClasses[id]();
			scenes[id].id = id;
			scenes[id].addEventListener("SCENE_LOADED", onSceneLoaded);
			
			container.addChild(scenes[id]);
		}
		
		private function onSceneLoaded(e:Event):void
		{
			if (modelsLoaded == 3) {
				removeChild(status);
				startSelectScience();
				
				Mouse.hide();
			} else {
				modelsLoaded++;
				updateStatus("Loading 3D Models (" + modelsLoaded + "/3)...");
				stage.invalidate();
			}
		}
		
		private function startSelectScience():void
		{
			startRender();
			showIdleScreen(true);
		}
		
		private function showIdleScreen(immediate:Boolean = false):void
		{
			TweenMax.killAll(idleScreen);
			
			idleScreen.width = stage.nativeWindow.width;
			idleScreen.height = stage.nativeWindow.height;
			addChild(idleScreen);
			
			idleScreen.alpha = 0;
			TweenMax.to(idleScreen, 1, {delay:immediate ? 0 : 10, autoAlpha:1, ease:Sine.easeIn, overwrite:2});
		}
		
		private function hideIdleScreen():void
		{
			TweenMax.killAll(idleScreen);			
			TweenMax.to(idleScreen, .5, {ease:Sine.easeIn, autoAlpha:0, onComplete:removeIdleScreen, overwrite:2});
		}
		
		private function removeIdleScreen():void
		{
			if(this.contains(idleScreen)) removeChild(idleScreen);
		}
		
		override protected function showScene(id:int):void
		{
			hideIdleScreen();
			trace("Show scene: " + id);
			scenes[id].show();
		}
		
		override protected function hideScene(id:int):void
		{
			trace("Hide scene: " + id);
			scenes[id].hide();
			showIdleScreen();
		}
		
		override protected function onEnterFrame(e:Event):void
		{
			try {
				
				for each(var s:SceneLoader in scenes) {
					if(s.ready && s.showing) s.update();
				}
				
				super.onEnterFrame(e);
			} catch(err:Error) {
				trace(err.getStackTrace());
			}
			
		}
		
	}
}