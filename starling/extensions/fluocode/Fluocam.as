package starling.extensions.fluocode{
	
	import starling.animation.Tween;
	import starling.animation.Transitions;

	import starling.display.MovieClip;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.display.Stage;
	import starling.display.Sprite;

	import starling.textures.Texture;
	import starling.core.Starling;
	
	import flash.display.Bitmap;
	import starling.display.Image;


	public class Fluocam extends Sprite 
	{
		public var targetCam:Sprite;
		public var explorer:Sprite=new Sprite();
		private var targetCamLink:Sprite=new Sprite();

		private var correctionX:Number=0;
		private var correctionY:Number=0;

		private var xCenter:Number;
		private var yCenter:Number;
		private var varAux:int;

		private var i:int;

		private var valueYCam:Number;
		private var valueXCam:Number;
		private var limitTop:Number;
		private var limitBottom:Number;
		private var limitLeft:Number;
		private var limitRight:Number;

		private var mcOriginal:Sprite;
		private var mcGoTo:Sprite;

		private var maskCamView:Sprite = new Sprite();
		private var refWorld:Sprite = new Sprite();
		
		private var markedTarget:Sprite;

		private var tweenAnimation:Tween;
		private var duration:Number=0.8;
		
		private var tweenScale:Tween;
		
		private var widthScene:Number;
		private var heightScene:Number;
		
		private var test:Boolean;
		
		private var tmpLayer:Sprite;
		

		private var controlTo:Sprite;
		private var toControlSw:Boolean;
		private var dragAndZoom:Boolean;
		
		var fControl:FluocamControl;
		
					
		private var countMaxLayers:int=5;
		private var countObjectLayers:int=0
		private var objectsLayersX:Vector.<Sprite>=new Vector.<Sprite>(countObjectLayers);
		private var objectsLayersY:Vector.<Sprite>=new Vector.<Sprite>(countObjectLayers);
		private var depthLayersX:Vector.<int>=new Vector.<int>(countObjectLayers);
		private var depthLayersY:Vector.<int>=new Vector.<int>(countObjectLayers);
		
		public var refreshRate=1;
		private var refreshCount=0;
		
		private var testTarget:Sprite=new Sprite();
		
		//<-- Requires an image in the path -->
		//[Embed(source = "../../../media/target.png")]
		//private static const targetCamIcon:Class;
	
		public function Fluocam(world:Sprite, widthScene:Number=0, heightScene:Number=0, test:Boolean=true, explorer:Sprite=null, dragAndZoom:Boolean=true)
		{

			this.test=test
			
			this.widthScene=widthScene;
			this.heightScene=heightScene;
			this.dragAndZoom=dragAndZoom;
			
			/*
			this.limitLeft=leftLimit;
			this.limitRight=rightLimit;
			this.limitTop=upLimit;
			this.limitBottom=downLimit;
			
			this.correctionX = correctionX;
			this.correctionY = correctionY;
			*/
			
			(stage)?init():addEventListener(Event.ADDED_TO_STAGE, init);

			refWorld = world;
			
			if(explorer!=null){
				this.explorer = Sprite(explorer);
			}else{
				this.explorer = new Sprite();
			}
			targetCam = this.explorer;

			world.addChild(targetCam);
			
			
			//<-- Requires import an image -->
			/*
			if(test)
			{
				var bgBitmapCam:Bitmap=new targetCamIcon();
				var tCam:Texture=Texture.fromBitmap(bgBitmapCam, false);
				var camIco:Image=new Image(tCam)
				
				camIco.x=-camIco.width>>1;
				camIco.y=-camIco.height>>1;
				targetCam.addChild(camIco);
			}
			*/
			
		}

	
		private function init(e:Event=null):void 
		{
			trace("Fluocam initialized",stage.stageWidth,'x',stage.stageHeight)
			stage.addChild(targetCamLink);
			this.xCenter = widthScene>>1;
			this.yCenter = heightScene>>1;

			working(true);
			
			if(dragAndZoom){
				fControl=new FluocamControl();
				refWorld.addChild(fControl);
				fControl.init(targetCam.x,targetCam.y,refWorld,targetCam);
			}
			
		}

		
	
		public function addLayer(sprite:Sprite, depth:int, moveOnCamX:Boolean=true, moveOnCamY:Boolean=false):void 
		{
			if(countObjectLayers<countMaxLayers){
				if(moveOnCamX){			
					objectsLayersX[countObjectLayers]=sprite;
					depthLayersX[countObjectLayers]=1/depth;
				}

				if(moveOnCamY){			
					objectsLayersY[countObjectLayers]=sprite;
					depthLayersY[countObjectLayers]=1/depth;
				}
				
				++countObjectLayers;
			}else{
				trace()
			}
			
		}
		
		
		public function working(sw:Boolean=true):void 
		{
			sw ? stage.addEventListener(Event.ENTER_FRAME,fluoCam):stage.removeEventListener(Event.ENTER_FRAME,fluoCam);
		}


		public function changeTarget(explorer:Sprite, toMark:Sprite=null, refreshRate:int=1):void 
		{
			this.refreshRate=refreshRate;
			targetCam = explorer;
		}
	

		public function goToTarget(explorer:Sprite, toMark:Sprite=null, controlTo:Sprite=null):void
		{
			if(controlTo!=null){
				this.controlTo=controlTo;
				toControlSw=true;
			}else{toControlSw=false}
			
			targetToTarget(targetCam,explorer);
		}
			
		public function goFromMarkedTarget(explorer:Sprite):void {
			targetToTarget(markedTarget,explorer);
		}
		
		public function explore(explorer:Sprite):void {
			//Move the cam on the target then give control to the cam
			explorer.x=targetCam.x;
			explorer.y=targetCam.y;
			targetCam=explorer;
		}
		

		private function fluoCam(e:Event):void 
		{
			//sprite.addChild(anotherObject);
			//sprite.flatten();   // optimize
			//sprite.unflatten(); // restore normal behaviour
			
			/*************************Layers Efect Move********************************
			i=countMaxLayers;
			while (--i>-1){
				tmpLayer=(objectsLayersX[i]!=null)?objectsLayersX[i]:null
				if(tmpLayer!=null){
					tmpLayer.x = depthLayersX[i] * targetCam.x;
				}
				tmpLayer=(objectsLayersY[i]!=null)?objectsLayersY[i]:null
				if(tmpLayer!=null){
					tmpLayer.y = depthLayersY[i] * targetCam.y;
				}	
			}
			/*************************************************************************/
			
			valueXCam = (xCenter - targetCam.x*refWorld.scaleX)  + correctionX * refWorld.scaleX;
			valueYCam = (yCenter - targetCam.y*refWorld.scaleY)  + correctionY * refWorld.scaleY;
			
			if (test){
				testTarget.x = -valueXCam;			
				testTarget.y = -valueYCam;
			}
			
			checkLimits();
		}
		
		private function checkLimits():void{
			//if(!isNaN(limitBottom)){
			//refWorld.y =  ((valueYCam>limitBottom)?valueYCam:limitBottom);
			//}else{
			//refWorld.y = valueYCam;
			//}
			
			/*
			refWorld.x = (!isNaN(limitLeft))?((valueXCam>limitLeft)?valueXCam:limitLeft):valueXCam;			
			refWorld.x = (!isNaN(limitRight))?((valueXCam>limitRight)?valueXCam:limitRight):valueXCam;			

			refWorld.y = (!isNaN(limitTop))?((valueYCam>limitTop)?valueYCam:limitTop):valueYCam;			
			refWorld.y = (!isNaN(limitBottom))?((valueYCam>limitBottom)?valueYCam:limitBottom):valueYCam;
			*/
			
			refWorld.x = valueXCam;			
			refWorld.y = valueYCam
		}


		public function targetToTarget(trgO:Sprite,trg:Sprite):void 
		{
		
			targetCam = targetCamLink;
			explorer=trg;
			targetCamLink.x=trgO.x;
			targetCamLink.y=trgO.y;

			tweenAnimation = new Tween(targetCamLink, duration, Transitions.LINEAR);
			tweenAnimation.animate("x", trg.x);
			tweenAnimation.animate("y", trg.y);
			
			tweenAnimation.onComplete=explorerIsexplorer;
			
			Starling.juggler.add(tweenAnimation);
		}

		private function explorerIsexplorer():void {
			Starling.juggler.remove(tweenAnimation);
			
			this.dispatchEvent(new Event("FINISH"));
			targetCam = toControlSw?controlTo:explorer;
		}

		public function zoomToTarget(zoom:Number,durationZoom:Number):void 
		{
			tweenScale = new Tween(refWorld, durationZoom, Transitions.LINEAR);
			tweenScale.animate("scaleX", zoom);
			tweenScale.animate("scaleY", zoom);
			
			tweenAnimation.onComplete=finishCamZoom;
			Starling.juggler.add(tweenScale);
		}
		
		private function finishCamZoom():void {
			Starling.juggler.remove(tweenScale);
			this.dispatchEvent(new Event("FINISH_ZOOM"));
		}
				
		public function zoomWorld(zoom:Number):void {
			refWorld.scaleX=refWorld.scaleY=zoom;
		}

		
		public function get minScale():Number { return fControl.minScale; }
        public function set minScale(value:Number):void 
        {
            fControl.minScale = value;
        }
		public function get maxScale():Number { return fControl.maxScale; }
        public function set maxScale(value:Number):void 
        {
            fControl.maxScale = value;
        }


	}//end class

}//end package
