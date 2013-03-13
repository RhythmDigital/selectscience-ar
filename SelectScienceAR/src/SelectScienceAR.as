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
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.rhythm.away3D4AR.SceneLoader;
	import com.rhythm.display.FullscreenARView;
	import com.rhythm.duttons.selectscience.FlaskScene;
	import com.rhythm.duttons.selectscience.MonkeyScene;
	import com.rhythm.duttons.selectscience.RetroVirusScene;
	
	import flash.events.Event;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.debug.AwayStats;
	import away3d.debug.Trident;
	import away3d.lights.PointLight;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.primitives.WireframeSphere;
	
	[SWF(frameRate="30", width="1280", height="720", backgroundColor=0xff0000)]
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
		
		public function SelectScienceAR()
		{
			super();
		}
		
		override protected function init():void
		{
			super.init();
			
			flarParams = {
				camPattern:CamParam, 
				markers:[new Marker1, new Marker2, new Marker3]
			};
			
			scenes = new Vector.<SceneLoader>();
			
			start(flarParams);
		}
		
		override protected function initLights():void
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
			
			var trident:Trident = new Trident();
			trident.scale(1);
			//view.scene.addChild(trident);
			
			light.x = sphere.x;
			light.y = sphere.y;
			light.z = sphere.z;
			
			TweenMax.allTo([sphere,light], 3, {x:200, repeat:-1, yoyo:true, ease:Quad.easeInOut, overwrite:2});
			TweenMax.allTo([sphere,light], 2, {y:400, repeat:-1, yoyo:true, ease:Quad.easeInOut, overwrite:2});
			
			FullscreenARView.LIGHT = light;
			FullscreenARView.LIGHTPICKER = new StaticLightPicker([FullscreenARView.LIGHT]);
			FullscreenARView.SHADOW = new HardShadowMapMethod(FullscreenARView.LIGHT);
			FullscreenARView.SHADOW.alpha=0.3;
		}
		
		override protected function init3D():void
		{
			super.init3D();
			
			view.scene.addChild(light);
			
			addChild(new AwayStats(view));
		}
		
		override protected function constructScene(container:ObjectContainer3D, id:int):void
		{
			trace("Building scene : " + id);
			scenes[id] = new sceneClasses[id]();
			container.addChild(scenes[id]);
		}
		
		override protected function showScene(id:int):void
		{
			trace("Show scene: " + id);
			scenes[id].show();
		}
		
		override protected function hideScene(id:int):void
		{
			trace("Hide scene: " + id);
			scenes[id].hide();
		}
		
		override protected function onEnterFrame(e:Event):void
		{
			try {
				super.onEnterFrame(e);
			} catch(err:Error) {
				trace(err.getStackTrace());
			}
			
		}
		
	}
}