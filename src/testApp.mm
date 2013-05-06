#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup()
{
	// initialize the accelerometer
	ofxAccelerometer.setup();
    
    //iPhoneAlerts will be sent to this.
	ofxiPhoneAlerts.addListener(this);
    
    // register touch events
	ofRegisterTouchEvents(this);
	
	//If you want a landscape oreintation
	//iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	
    backgroundColor = ofColor(0);
	ofBackground(backgroundColor);
    ofEnableAlphaBlending();
    
    int fps = 30;
    
    initialMass = 0.4f;
	
	ofBackground(0);
	ofSetBackgroundAuto(false);
	ofSetFrameRate(fps);
	ofEnableSmoothing();
	ofSetVerticalSync(true);
	ofSetCircleResolution(50);
	
	world.init();
    world.doSleep = false;
	world.checkBounds(true);
	world.createBounds(0, 0, ofGetWidth(), ofGetHeight());
	world.setFPS(fps);
    
    bDrawWhileDragging = true;
    startLocation.set(0, 0);
    endLocation.set(0, 0);
    
    startLocation.set(ofGetWidth()/2, ofGetHeight()/2);
    endLocation.set(ofGetWidth()/2, ofGetHeight()/2);
    
    // register the listener so that we get the events
	ofAddListener(world.contactStartEvents, this, &testApp::contactStart);
	ofAddListener(world.contactEndEvents, this, &testApp::contactEnd);
    
    // load the sfx soundfiles
    soundPop.loadSound("sfx/BubblePo-Benjamin-8920_hifi.wav");
    soundPop.setMultiPlay(true);
    soundPop.setLoop(false);
    
    soundContact.loadSound("sfx/glass.wav");
    soundContact.setMultiPlay(true);
    soundContact.setVolume(.1f);
    soundContact.setLoop(false);
    
    settingsView = [[SettingsUIView alloc] initWithNibName:@"SettingsUIView" bundle:nil];
    [ofxiPhoneGetGLView() addSubview:settingsView.view];
    settingsView.view.hidden = YES;
    
    ofFbo::Settings settings;
	settings.width = ofGetWidth() * 4;
	settings.height = ofGetHeight() * 4;
	settings.internalformat = GL_RGBA;
	settings.numSamples = 0;
	settings.useDepth = true;
	settings.useStencil = true;
	fbo.allocate(settings);
}

//--------------------------------------------------------------
void testApp::update()
{
    ofSoundUpdate();
    
    float accx = ofxAccelerometer.getForce().x;
    float accy = ofxAccelerometer.getForce().y;
    
    // Box2D
    world.update();
    
    float fx = accx * gravity;
    float fy = accy * -gravity;
    
    world.setGravity(fx, fy);
    
    fbo.begin();
    ofPushStyle();
    ofClear(backgroundColor);
    for (int i=0; i<eyeCircles.size(); i++)
	{
		eyeCircles[i]->draw();
	}
    for (int i=0; i<eyeRects.size(); i++)
	{
		eyeRects[i]->draw();
	}
 	
    if (bDrawRadiusCircle) {
        ofSetHexColor(0xff0000);
        float radius = startLocation.distance(endLocation) / 2;
        ofCircle(startLocation, radius);
    }
    ofPopStyle();
    fbo.end();
}

//--------------------------------------------------------------
void testApp::draw()
{
    fbo.draw(0, 0, ofGetWidth() * 4, ofGetHeight() * 4);
}

//--------------------------------------------------------------
void testApp::contactStart(ofxBox2dContactArgs &e)
{
	if (e.a != NULL && e.b != NULL)
    {
		// if we collide with the ground we do not
		// want to play a sound. this is how you do that
		if(e.a->GetType() == b2Shape::e_circle && e.b->GetType() == b2Shape::e_circle)
        {
		    SoundData * aData = (SoundData*)e.a->GetBody()->GetUserData();
            SoundData * bData = (SoundData*)e.b->GetBody()->GetUserData();
            
            if(aData)
            {
                aData->bHit = true;
//                soundContact.play();
                // sound[aData->soundID].play();
            }
            
            if(bData)
            {
                bData->bHit = true;
//                soundContact.play();
                // sound[bData->soundID].play();
            }
		}
	}
}

//--------------------------------------------------------------
void testApp::contactEnd(ofxBox2dContactArgs &e) {
	if (e.a != NULL && e.b != NULL)
    {
		SoundData * aData = (SoundData*)e.a->GetBody()->GetUserData();
		SoundData * bData = (SoundData*)e.b->GetBody()->GetUserData();
		
		if(aData)
        {
			aData->bHit = false;
		}
		
		if(bData)
        {
			bData->bHit = false;
		}
	}
}

//--------------------------------------------------------------
void testApp::exit()
{
    clearEyes();
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch)
{
    if (!bDrawWhileDragging)
    {
        bDrawRadiusCircle = true;
        startLocation.set(touch.x, touch.y);
        endLocation.set(touch.x, touch.y);
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch)
{
    endLocation.set(touch.x, touch.y);
    
    if (bDrawWhileDragging)
    {
        if (bAddEyeCircles)
        {
            float radius = ofRandom(sizeMin, sizeMax);
            addCircleEye(endLocation, radius);
        }
        else
        {
            float width = ofRandom(sizeMin, sizeMax);
            float height = ofRandom(sizeMin, sizeMax);
            addRectEye(endLocation, width, height);
        }
    }
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch)
{
    if (!bDrawWhileDragging)
    {
        bDrawRadiusCircle = false;
        
        if (bAddEyeCircles)
        {
            float radius = startLocation.distance(endLocation) / 2;
            if (radius > 4)
                addCircleEye(startLocation, radius);
        }
        else
        {
            float width = startLocation.distance(endLocation) / 2;
            float height = startLocation.distance(endLocation) / 2;
            if (width > 4 && height > 4)
                addRectEye(startLocation, width, height);
        }
    }
}

//--------------------------------------------------------------
void testApp::addCircleEye(ofVec2f position, float radius)
{
    FishParticle *p = new FishParticle();
    
    p->setPhysics(radius * radius * initialMass, bounciness, friction);
    p->setup(world.getWorld(), position.x, position.y, radius);
    p->init();
    
    p->setData(new SoundData());
    SoundData * sd = (SoundData*)p->getData();
    sd->soundID = 0;
    sd->bHit	= false;
    
    eyeCircles.push_back(p);
    
    if (bSoundEnabled && !bDrawWhileDragging) soundPop.play();
}

//--------------------------------------------------------------
void testApp::addRectEye(ofVec2f position, float width, float height)
{
    FishRectParticle *p = new FishRectParticle();
    float area = width * height;
    p->setPhysics(area * initialMass, bounciness, friction);
    p->setup(world.getWorld(), position.x, position.y, width / 2, height / 2);
    p->init(width, height);
    
    p->setData(new SoundData());
    SoundData * sd = (SoundData*)p->getData();
    sd->soundID = 1;
    sd->bHit	= false;
    
    eyeRects.push_back(p);
    
    if (bSoundEnabled && !bDrawWhileDragging) soundPop.play();
}

//--------------------------------------------------------------
void testApp::clearEyes()
{
    int sum (0);
    
    for(int i=0; i<eyeCircles.size(); i++)    eyeCircles[i]->destroy();
    for(int i=0; i<eyeRects.size(); i++)    eyeRects[i]->destroy();
    
    while (!eyeCircles.empty())
    {
        sum += (int)eyeCircles.back();
        eyeCircles.pop_back();
    }
    while (!eyeRects.empty())
    {
        sum += (int)eyeRects.back();
        eyeRects.pop_back();
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch)
{
    settingsView.view.hidden = NO;
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning()
{
    // Empty eyes on low memory
    clearEyes();
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation)
{
    
}

