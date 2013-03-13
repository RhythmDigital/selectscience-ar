package com.rhythm.display
{
	import com.quasimondo.bitmapdata.CameraBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.media.Video;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.lights.PointLight;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.textures.BitmapTexture;
	
	import org.libspark.flartoolkit.core.types.FLARIntSize;
	import org.libspark.flartoolkit.markersystem.FLARMarkerSystemConfig;
	import org.libspark.flartoolkit.markersystem.FLARSensor;
	import org.libspark.flartoolkit.support.away3dv40.FLARAway3DMarkerSystem;
	
	public class FullscreenARView extends FullscreenAIRDisplay
	{	
		//protected var bmp:Bitmap;
		//protected var camera:CameraBitmap;
		protected var bg:BitmapTexture;
		
		// 3D
		protected var scene:Scene3D;
		protected var view:View3D;
		
		
		// AR
		private var arParams:Object;
		
		protected var isShowBinRaster:Boolean = false;
		private var marker_ids:Array = [];
		private var scenes:Array = [];
		private var marker_node:ObjectContainer3D;
		private var fid:Vector.<int>=new Vector.<int>(3);
		
		//http://blog.jwwisman.nl/2009/03/23/flartoolkit-single-multiplemarker-detection/
		private var codeWidth:int;
		private var camWidth:int;
		private var camHeight:int;
		private var rasterWidth:int;
		private var rasterHeight:int;
		private var scaleRatio:Matrix;
		private var arSensor:FLARSensor;
		private var markerSys:FLARAway3DMarkerSystem;
		private var camOutputW:int;
		private var camOutputH:int;
		private var video:Video;
		private var camera:CameraBitmap;
		private var cameraResized:BitmapData;
		private var cameraResizeMatrix:Matrix;
		
		protected var cameraID:int = 0;
		
		public function FullscreenARView()
		{
			super();
		}
		
		public function start(flarParams:Object):void
		{
			
			
			sizeParamSetup();
			initCamera();
			initAR(flarParams);
			initLights();
			init3D();
		}
		
		public function sizeParamSetup():void
		{
			var ratio:Number = 9/16; // widescreen //stage.stageHeight/stage.stageWidth;
			
			var pow2W:int = 1024;
			var pow2H:int = 512;
			
			camOutputW = pow2W;
			camOutputH = int(camOutputW*ratio);
			
			//camWidth = 1024;
			//camHeight = 512;
			
			rasterWidth  = 300;
			rasterHeight = int(rasterWidth*ratio);
			
			codeWidth = 80;
			
			// resize parametor
			scaleRatio = new Matrix();
			scaleRatio.scale( rasterWidth/camOutputW, rasterHeight/camOutputH)
			
			cameraResized = new BitmapData(pow2W, pow2H, false, 0x000000);
			cameraResizeMatrix = new Matrix();
			cameraResizeMatrix.scale(pow2W/camOutputW,pow2H/camOutputH);
			
			camera = new CameraBitmap(camOutputW, camOutputH, 20, camOutputW, camOutputH, 0, true);
			camera.addEventListener(Event.RENDER, onCameraRender);
			
			
			trace("CAMERA INIT");
		}
		
		protected function initCamera():void
		{
			
		}
		
		protected function initAR(arParams:Object):void
		{
			this.arParams = arParams;
			trace("init AR");
			
			var markerSysConf:FLARMarkerSystemConfig = new FLARMarkerSystemConfig(new arParams.camPattern, rasterWidth, rasterHeight);
			arSensor  = new FLARSensor(new FLARIntSize(rasterWidth, rasterHeight));
			markerSys = new FLARAway3DMarkerSystem(markerSysConf);
			
		}
		
		protected function initLights():void
		{
			
		}
		
		protected function init3D():void
		{
			//setup the view
			view = new View3D(new Scene3D, markerSys.getAway3DCamera());
			view.width = stage.stageWidth;
			view.height = stage.stageWidth/16*9;
			view.y = (stage.stageHeight >> 1) - (view.height >> 1);
			view.antiAlias = 3;
			view.backgroundColor = 0x000000;
			scene = view.scene;
			addChild(view);
			
			//setup parser to be used on Loader3D
			//Parsers.enableAllBundled();
			
			// bg texture
			//view.background = new FLARWebCamTexture(camOutputW, camOutputH);
			bg = new BitmapTexture(cameraResized);
			view.background = bg;
			
			//register AR Marker
			var i:int = 0;
			for each(var m:String in arParams.markers) {
				marker_ids.push(this.markerSys.addARMarker_2(m, 16, 25, codeWidth));
				var obj:ObjectContainer3D = createScene(i);
				obj.visible = false;
				scenes.push(obj);
				view.scene.addChild(obj);
				
				++i;
			}
			
			//setup the render loop
			
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		protected function onCameraRender(e:Event):void
		{
			if(bg) {
				//trace("render!");
				//.copyPixels(bmd, bmd.rect, new Point(0,0));//
				cameraResized.draw(bmd,cameraResizeMatrix);
				bg.invalidateContent();
			}
		}
		
		public function startRender():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		protected function onEnterFrame(e:Event):void
		{
			// update sensor status
			arSensor.update_3(bmd, scaleRatio);
			
			// update markersystem status
			markerSys.update(arSensor);
			
			//FLARWebCamTexture(view.background).update(video);
			
			for each(var m:int in marker_ids) {
				if (markerSys.isExistMarker(m)){
					
					//trace("MARKER "+m+" VISIBLE!");
					
					var resultMat:Matrix3D = new Matrix3D();
					markerSys.getAway3dMarkerMatrix(m, resultMat);
					scenes[m].transform = resultMat;
					_objectTransform(scenes[m]);
					
					if(scenes[m].visible == false) {
						scenes[m].visible = true;
						showScene(m);
					}
					
				} else {
					
					if(scenes[m].visible == true) {
						scenes[m].visible = false;
						hideScene(m);
					}
					
				}
			}
			
			if (isShowBinRaster) {
				this.addChild(new Bitmap(arSensor.getBinImage(markerSys.getCurrentThreshold()).getBitmapData()));
			}
			
			view.render();
		}
		
		/**
		 * 3Dオブジェクト生成
		 */
		private function createScene(id:int):ObjectContainer3D
		{
			var container:ObjectContainer3D = new ObjectContainer3D();
			constructScene(container, id);
			return container;
		}
		
		protected function constructScene(container:ObjectContainer3D, id:int):void
		{
			trace("Building scene : " + id);
		}

		protected function showScene(id:int):void
		{
			
		}
		
		protected function hideScene(id:int):void
		{
			
		}
		
		/**
		 * transmatを適応後に何かする場合はオーバーライドして実装すること。
		 */
		protected function _objectTransform(_container:ObjectContainer3D):void
		{
			//_container.roll(1);
		}
		
		protected function onResize(e:Event):void
		{
			// TODO Auto-generated method stub
			
		}
		
		public function get bmd():BitmapData
		{
			return camera.bitmapData;
		}
	}
}