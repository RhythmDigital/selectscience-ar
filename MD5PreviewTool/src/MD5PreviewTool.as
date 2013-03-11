package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Vector3D;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.events.ResourceEvent;
	
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.debug.WireframeAxesGrid;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.MD5AnimParser;
	import away3d.loaders.parsers.MD5MeshParser;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;
	import away3d.tools.utils.Bounds;
	import away3d.utils.Cast;
	
	[SWF(frameRate="40", width="960", height="540" background="#c2c2c2")]
	public class MD5PreviewTool extends Sprite
	{
		private var mainUI:MainUI;
		protected var scene:Scene3D;
		protected var view:View3D;
		private var file:FileReference;
		private var filterMD5Mesh:FileFilter;
		private var filterMD5Anim:FileFilter;
		private var filterMD5Mat:FileFilter;
		
		private var animator:SkeletonAnimator;
		private var animationSet:SkeletonAnimationSet;
		private var stateTransition:CrossfadeTransition = new CrossfadeTransition(0.5);
		private var skeleton:Skeleton;
		private var placeHolder:ObjectContainer3D;
		private var mesh:Mesh;
		private var container:ObjectContainer3D;
		private var bodyMaterial:TextureMaterial;
		
		
		public function MD5PreviewTool()
		{
			AssetLibrary.addEventListener(ResourceEvent.COMPLETE, onResourceComplete);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			filterMD5Mesh = new FileFilter("MD5 Mesh (*.md5mesh)", "*.md5mesh");
			filterMD5Anim = new FileFilter("MD5 Animation (*.md5anim)", "*.md5anim");
			filterMD5Mat = new FileFilter("Texture (*.png,*.jpg)", "*.png;*.jpg");
			file = new FileReference();
			file.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onResourceComplete(e:ResourceEvent):void
		{
			trace("Resource complete!");
			mainUI.progressBar.scaleX = 0;
		}
		
		private function onAssetComplete(e:AssetEvent):void
		{
			trace(e.asset.assetType);
			trace(e.asset.assetType);
			
			if (e.asset.assetType == AssetType.ANIMATION_NODE) {
				
				var node:SkeletonClipNode = e.asset as SkeletonClipNode;
				var name:String = e.asset.assetNamespace;
				node.name = name;
				trace("Animation: " + node.name);
				animationSet.addAnimation(node);
				
				//if (name == "default") {
					node.looping = true;
				//} 
				
				animator.play(node.name);
				
			} else if (e.asset.assetType == AssetType.ANIMATION_SET) {
				animationSet = e.asset as SkeletonAnimationSet;
				animator = new SkeletonAnimator(animationSet, skeleton);
				
//				mainUI.btnAnim.enable();
				mesh.animator = animator;
				
				
			} else if (e.asset.assetType == AssetType.SKELETON) {
				skeleton = e.asset as Skeleton;
				trace("skeleton: " + skeleton);
			} else if (e.asset.assetType == AssetType.MESH) {
				trace("MESH!!");
				//grab mesh object and assign our material object
				mesh = e.asset as Mesh;
				
				mainUI.progressBar.scaleX = 0;
				mainUI.btnMat.enable();
				
				//mesh.material = bodyMaterial;
				mesh.castsShadows = true;
				mesh.rotationX = -90;
				mesh.rotationZ = 90;
				mesh.rotationY = -180;
				Bounds.getMeshBounds(mesh);
				mesh.scale(30);
				mesh.y = (Bounds.height >> 1)*mesh.scaleY;
				
				trace("mesh bouds height: " + Bounds.height);
				
				
				
				container = new ObjectContainer3D();
				container.addChild(mesh);
				
				
				
				scene.addChild(container);
			}

		}
		
		protected function onAddedToStage(e:Event):void
		{
			init();
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function init():void
		{
			trace("Ready.");
			init3D();
		}
		
		protected function init3D():void
		{
			//setup the view
			view = new View3D();
			scene = view.scene;
			addChild(view);
			
			//setup parser to be used on Loader3D
			Parsers.enableAllBundled();
			
			//setup the camera
			view.camera.z = 600;
			view.camera.y = 400;
			view.camera.lookAt(new Vector3D());
			
			view.backgroundColor = 0xc2c2c2;
			
			var sphereGeometry:PlaneGeometry = new PlaneGeometry(400,400,3,3,true,true);
			var sphereMaterial:ColorMaterial = new ColorMaterial( 0xff0000 );
			var mesh:Mesh = new Mesh(sphereGeometry, sphereMaterial);
			view.scene.addChild(mesh);
			//mesh.z = - 600;
			
			
			//setup the render loop
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			addChild(new AwayStats(view));
			
			initUI();
		}
		
		protected function onEnterFrame(e:Event):void
		{
			view.render();
		}
		
		private function initUI():void
		{
			trace("Initialising interface.");
			// init ui.
			mainUI = new MainUI();
			mainUI.btnAnim.disable();
			mainUI.btnMat.disable();
			mainUI.btnMesh.addEventListener(MouseEvent.CLICK, onMeshSelect);
			mainUI.btnMat.addEventListener(MouseEvent.CLICK, onMatSelect);
			mainUI.btnAnim.addEventListener(MouseEvent.CLICK, onAnimSelect);
			mainUI.progressBar.scaleX = 0;
			addChild(mainUI);
		}
		
		protected function onAnimSelect(e:MouseEvent):void
		{
			file.browse([filterMD5Anim]);
			file.addEventListener(Event.SELECT, onAnimSelected);
		}
		
		protected function onAnimSelected(e:Event):void
		{
			mainUI.btnAnim.disable();
			file.removeEventListener(Event.SELECT, onMatSelected);
			file.addEventListener(Event.COMPLETE, onAnimDataLoaded);
			file.load();
		}
		
		protected function onAnimDataLoaded(event:Event):void
		{
			file.removeEventListener(Event.COMPLETE, onMeshLoaded);
			AssetLibrary.loadData(Cast.byteArray(file.data), null, null, new MD5AnimParser);
			mainUI.visible = false;
		}
		/*
		protected function onnAnimLoaded(e:Event):void
		{
			trace("mesh loaded.");
			file.removeEventListener(Event.COMPLETE, onMeshLoaded);
			AssetLibrary.loadData(Cast.byteArray(file.data), null, null, new MD5MeshParser());
		}
		*/
		
		protected function onMeshSelect(e:MouseEvent):void
		{
			file.browse([filterMD5Mesh]);
			file.addEventListener(Event.SELECT, onMeshSelected);
		}
		
		protected function onMeshSelected(e:Event):void
		{
			mainUI.btnMesh.disable();
			file.removeEventListener(Event.SELECT, onMeshSelected);
			file.addEventListener(Event.COMPLETE, onMeshLoaded);
			file.load();
		}
		
		protected function onMeshLoaded(e:Event):void
		{
			trace("mesh loaded.");
			file.removeEventListener(Event.COMPLETE, onMeshLoaded);
			AssetLibrary.loadData(Cast.byteArray(file.data), null, null, new MD5MeshParser());
		}
		
		protected function onMatSelect(e:MouseEvent):void
		{
			file.browse([filterMD5Mat]);
			file.addEventListener(Event.SELECT, onMatSelected);
		}
		
		protected function onMatSelected(e:Event):void
		{
			mainUI.btnMat.disable();
			file.removeEventListener(Event.SELECT, onMatSelected);
			file.addEventListener(Event.COMPLETE, onMatDataLoaded);
			file.load();
		}
		
		protected function onMatDataLoaded(e:Event):void
		{
			file.removeEventListener(Event.COMPLETE, onMatDataLoaded);
			
			// convert to loader
			var img:Loader = new Loader();
			img.contentLoaderInfo.addEventListener(Event.COMPLETE, onMatBitmapComplete);
			img.loadBytes(file.data);
		}
		
		protected function onMatBitmapComplete(e:Event):void
		{
			// this is the image.
			trace("image loaded and parsed.");
			e.target.removeEventListener(Event.COMPLETE, onMatBitmapComplete);
			if(bodyMaterial) {
				mesh.material = null;
				bodyMaterial.dispose();
			}
			
			bodyMaterial = new TextureMaterial(Cast.bitmapTexture(e.target.content.bitmapData));
			mesh.material = bodyMaterial;
			mainUI.progressBar.scaleX = 0;
			
			mainUI.btnAnim.enable();
		}
		
		
		
		
		protected function onProgress(e:ProgressEvent):void
		{
			mainUI.progressBar.scaleX = e.bytesLoaded/e.bytesTotal;
		}
		
	}
}