Fluocam
=======

This is a virtual camera developed in Action Script 3 (AS3) for Starling applications.



Installation

a. If you’re using a Starling swc, you’ll need to create a starling.extensions package in your src folder. 

    starling/extensions/fluocode/Fluocam/Fluocam.as
    starling/extensions/fluocode/FluocamControl.as
    

b. Locate the spacebar folder in the download.

c. Drag the spacebar folder and all of its contents into the extensions package.



Implementation


    import starling.extensions.fluocode.Fluocam;
    import starling.extensions.fluocode.FluocamControl;

    starling.simulateMultitouch = true;
    
    var cam:Fluocam = new Fluocam(world,480,320, false);
    addChild(cam);
    

The params in the contructor are:

Fluocam(world:Sprite, widthScene:Number=0, heightScene:Number=0, test:Boolean=true, explorer:Sprite=null, dragAndZoom:Boolean=true)


Where:

    world. - Is a Sprite that content all the objects to explore with the camera
    
    widthScene .- scene's width 
    
    heightScene .- scene's height 
    
    test.- Show a picture to see the current position of the target camera (requires remove coments in Fluocam.as)
    
    explorer.- Is a object in "your world" used like a "explorer" is recomendable keep null this value.
    
    dragAndZoom.- Is a flag to activate or desactivete the "Explore Mode" (drag to move the camera and zoom gesture)
    
    

Methods:

public function working(sw:Boolean=true):void

    cam.working(true) // Turn on the camera
    cam.working(true) // Turn off the camera 
    //// The camera is working when since is add to the stage
    


public function changeTarget(camTarget:Sprite, toMark:Sprite=null, refreshRate:int=1):void 

    cam.changeTarget(objectInTheWorld)
    // Change the target to the sprite "objectInTheWorld"
    


public function goToTarget(explorer:Sprite, toMark:Sprite=null, controlTo:Sprite=null):void

    cam.goToTarget(objectInTheWorld);
    // Go with a smooth move to the sprite "objectInTheWorld"
    
    
public function targetToTarget(trgO:Sprite,trg:Sprite):void 

    cam.targetToTarget(objectInTheWorld, otherObjectInTheWorld)
    //Move the camera from the first object to the second object
    

public function zoomToTarget(zoom:Number,durationZoom:Number):void

    cam.zoomToTarget( 5.2, 1.5 )
    // Zoom in the current position to scale 5.2 in 1.5 seconds


public function explore():void

    cam.explore();
    //Move the camera on the current target position and then give the control to the camera
