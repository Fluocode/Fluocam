package starling.extensions.fluocode {

	import starling.core.Starling;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	import starling.display.Image;
	import starling.textures.Texture;
	
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	
	import flash.display.Bitmap;

	public class FluocamControl extends Sprite 
	{		
		public var minScale:Number=0.25;
		public var maxScale:Number=10;
		
		private var mouseX:int = 0;
		private var mouseY:int = 0;
		
		private var elementsInStage:Array = new Array();
		
		public var orignalStageX:Number;
		public var orignalStageY:Number;

		public var firstTouchX:Number;
		public var firstTouchY:Number;
		public var refTouchX:Number;
		public var refTouchY:Number;

		public var inicialPosX:Number;
		public var inicialPosY:Number;
		public var moveOrSelect:Boolean;
		public var itemSelectable:Boolean;

		public var scrollable:Boolean;
		public var qScrollable:Number;

		public var tiempoDrag:int;
		public var cada:int=1;
		public var velX:Number;
		public var velY:Number;
		public var friccion:Number=4;
		public var sensibility:int=20;
		public var accuracyDragForce:int=300;

		public var canvas:Sprite;
		public var targetCam:Sprite
		
		private var touch:Touch;
		private var pos:Point;
		
		private var dx:int;
		private var dy:int;
		private var oDist:int=0;
		private var currentScale:Number=1;
		private var onZoom:Boolean=false;


		public function FluocamControl(){
		}
		

		public function init(camX:Number, camY:Number, world:Sprite, targetCam:Sprite):void
		{
		
			canvas=world;
			this.targetCam=targetCam;

			currentScale=canvas.scaleY;
			
			targetCam.x=camX;
			targetCam.y=camY;
			
			orignalStageX=targetCam.x;
			orignalStageY=targetCam.y;

			qScrollable=canvas.width-stage.stageWidth>>1

			stage.addEventListener(TouchEvent.TOUCH, onTouch);
			
			//trace("canvas.targetCam",canvas.targetCam.x,canvas.targetCam.y)
			//targetCam.mouseEnabled=false;
			//canvas.targetCam.visible=false; //<--------------------------------------------------------- targetCam
			//addChildAt(targetCam,numChildren);
		}

		var lap:Timer=new Timer(accuracyDragForce,0);
		public function getCoordinateByTime(o:Boolean):void {
			if (o) {
				tiempoDrag=getTimer();
				refTouchX=(mouseX);
				refTouchY=(mouseY);
				lap.addEventListener(TimerEvent.TIMER, timerLap,false,0,true);
				lap.start();
			}else{
				refTouchX=(mouseX);
				refTouchY=(mouseY);
				lap.stop();
				lap.removeEventListener(TimerEvent.TIMER, timerLap);
			}
		}

		public function timerLap(e:TimerEvent):void 
		{
			tiempoDrag=getTimer();
			refTouchX=(mouseX);
			refTouchY=(mouseY);
		}

		public function stageTouched():void 
		{
			itemSelectable=true;
			velX=0;
			velY=0;
			
			getCoordinateByTime(true);
			firstTouchX=(mouseX);
			firstTouchY=(mouseY);
			
			inicialPosX=(targetCam.x);
			inicialPosY=(targetCam.y);
		}

		public function noStageTouched():void 
		{
			getCoordinateByTime(false);
		}

		public function adjustRegisterPoint():void 
		{			
			var adjustRegX:Number=targetCam.x;
			var adjustRegY:Number=targetCam.y;
			
			targetCam.x=0;
			targetCam.y=0;
		
			canvas.x+=adjustRegX;
			canvas.y+=adjustRegY;
		}

		public function moveStage():void 
		{
			//trace("on move")
			var xValue:int=int(mouseX-firstTouchX);
			var yValue:int=int(mouseY-firstTouchY);
			
			if((abs(xValue)>10 || abs(yValue)>10) && !onZoom)
			{
				targetCam.x=inicialPosX-(xValue)/(canvas.scaleX);
				targetCam.y=inicialPosY-(yValue)/(canvas.scaleY);
				
				itemSelectable=false;
				stageBound()
			}
			else{
				itemSelectable=true;
			}
		}

		public function stageBound():void 
		{
			//testTarget.x = targetCam.x;			
			//testTarget.y = targetCam.y;
			
			///Limite Izquierdo y control de Flecha
		//	if(canvas.targetCam.x>canvas.stageWidth>>1){
		//		canvas.targetCam.x=canvas.stageWidth>>1;
		//	}
		//	
		//	//Limite Derecho y control de Flecha
		//	if(canvas.targetCam.x<-qScrollable){
		//		canvas.targetCam.x=-qScrollable;
		//	}
		}

		public function outStage():void 
		{
			//if(scrollable){				
			//}
			tiempoDrag+=-getTimer();
			velX+=((sensibility/canvas.scaleX)*((tiempoDrag!=0)?((refTouchX-mouseX)/tiempoDrag):11));
			velY+=((sensibility/canvas.scaleY)*((tiempoDrag!=0)?((refTouchY-mouseY)/tiempoDrag):11));
			
			stage.addEventListener(Event.ENTER_FRAME,controlMov);
			getCoordinateByTime(false);
		}	

		public function abs(a:Number):Number 
		{
			return a<0?-a:a;
		}

		public function controlMov(e:Event):void 
		{			
			if(++cada>8)
			{
				cada=1;
				velX/=friccion;
				velY/=friccion;
			}
			if(targetCam!=null)
			{
				targetCam.x-=(velX/canvas.scaleX);
				targetCam.y-=(velY/canvas.scaleY);

				if((velX<0?-velX:velX)<0.5){
					velX=0;
					stage.removeEventListener(Event.ENTER_FRAME,controlMov);
				}
				
				stageBound();
			}
		}
		
		
		private function onTouch(e:TouchEvent):void
		{			
			touch=e.getTouch(stage);
			var touches:Vector.<Touch> = e.touches;
			
			if(touch!=null){
				//pos=touch.getLocation(stage);
				mouseX=touch.globalX;
				mouseY=touch.globalY;
			
				if(touch.phase=="began"){
					stageTouched();
				}
						
				if(touch.phase=="moved"){
					moveStage();
				}
			}
			
			// retrieves the touch points
			// if two fingers
			if ( touches.length == 2 )
			{
				var finger1:Touch = touches[0];
				var finger2:Touch = touches[1];
				var distance:int;
				var dx:int;
				var dy:int;
				
				// if both fingers moving (dragging)
				if ( finger1.phase == TouchPhase.MOVED && finger2.phase == TouchPhase.MOVED )
				{
					onZoom=true;
					
					if(oDist==0)
					oDist=fingerDistance(finger1, finger2)/currentScale;
					
					distance=fingerDistance(finger1, finger2);
					
					if(distance/oDist > minScale && distance/oDist < maxScale)
					canvas.scaleX=canvas.scaleY=currentScale=distance/oDist;					
				}
			}
			
			if(touch!=null){
				if(touch.phase=="ended"){
					onZoom=false;
					oDist=0;
					outStage();
				}
			}
		
		}
		

		private function fingerDistance(finger1:Touch, finger2:Touch):int
		{
			dx = Math.abs ( finger1.globalX - finger2.globalX );
			dy = Math.abs ( finger1.globalY - finger2.globalY );

			return Math.sqrt(dx*dx+dy*dy);
		}
		

	}//end class

}//end package
