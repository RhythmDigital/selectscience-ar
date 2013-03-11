package com.quasimondo.tools
{
	import com.quasimondo.geom.Vector2;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
			
	public class Handle extends Sprite
	{
		public var modes:Array;
		public var point:Vector2;
		
		public var startAngle:Number;
		public var radius:Number;
		
		private var __mouseIsDown:Boolean = false;
		private var __selected:Boolean = false;
		
		private var __lastX:Number;
		private var __lastY:Number;
		
		private var __active:Boolean = false;
		
		private const HANDLE_SIZE:int = 7;
		private const HITAREA_SIZE:int = 20;
		
		public function Handle( point:Vector2 = null )
		{
			if ( point != null ) this.point = point;
			else  this.point = new Vector2();
			
			x = this.point.x;
			y = this.point.y;
			
			updateGrabber();
		}
		
		public function set active( value:Boolean ):void
		{
			__active = value;
			if (stage!=null)
			{
				if ( value )
				{
					addEventListener( MouseEvent.MOUSE_OVER, mouseOver );
					addEventListener( MouseEvent.MOUSE_OUT, mouseOut );
				} else {
					removeEventListener( MouseEvent.MOUSE_OVER, mouseOver );
					removeEventListener( MouseEvent.MOUSE_OUT, mouseOut );
					stage.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
					stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
				}
				initPoint();
			}
		}
		
		public function get active(  ):Boolean
		{
			return __active;
		}
		
		private function initPoint():void
		{
			point.setValue( x, y );
		}
		
		public function set selected( value:Boolean ):void
		{
			__selected = value
			updateGrabber();
		}
		
		private function mouseOver( event:MouseEvent):void
		{
			stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true );
		}
		
		private function mouseOut( event:MouseEvent ):void
		{
			if ( stage != null ) stage.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
		}
		
		
		public function mouseDown( event:MouseEvent = null ):void
		{
			if ( stage == null ) return;
			
			__lastX = stage.mouseX;
			__lastY = stage.mouseY;
			__mouseIsDown = true;
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
			updateGrabber();
		}
		
		public function mouseUp( event:MouseEvent  = null  ):void
		{
			__mouseIsDown = false;
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUp );
			updateGrabber();
		}
		
		private function updateGrabber():void
		{
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill( 0, 0);
			graphics.drawRect( - HITAREA_SIZE * 0.5, - HITAREA_SIZE * 0.5, HITAREA_SIZE, HITAREA_SIZE );
			graphics.lineStyle( 0 );
			graphics.beginFill(  __selected ? ( __mouseIsDown ? 0x000000 : 0xff8000 ) : 0xffffff );
			graphics.drawRect( - HANDLE_SIZE *0.5, - HANDLE_SIZE*0.5, HANDLE_SIZE, HANDLE_SIZE );
			graphics.endFill();
		}
		
		public function getMode():String
		{
			var dx:Number = mouseX;
			var dy:Number = mouseY;
			
			return String( mouseX * mouseX + mouseY * mouseY < 200 ? modes[0] : modes[1] );
		}
		
		public function mouseMove( event:MouseEvent = null ):void
		{
			point.x += stage.mouseX - __lastX;
			point.y += stage.mouseY - __lastY;
			__lastX = stage.mouseX;
			__lastY = stage.mouseY;
			x = Math.round(  point.x  );
			y = Math.round(  point.y );
			dispatchEvent(  new Event( Event.CHANGE ) );
		};
		
		public function setPosition( x:Number, y:Number ):void
		{
			point.x =  x;
			point.y =  y;
			this.x = Math.round( x );
			this.y = Math.round( y );
		}
		
		public function setPoint( p:Vector2 ):void
		{
			point.x = p.x;
			point.y = p.y;
			x = Math.round(  p.x );
			y = Math.round(  p.y );
		}
		
		public function set posX( x:Number ):void
		{
			point.x =  x;
			this.x = Math.round( x );
		}
		
		public function set posY( y:Number ):void
		{
			point.y = y;
			this.y = Math.round( y );
		}
		
		public function get posX( ):Number
		{
			return point.x;
		}
		
		public function get posY( ):Number
		{
			return point.y;
		}
		
	}
}