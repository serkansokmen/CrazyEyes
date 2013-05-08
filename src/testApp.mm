#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    // initialize the accelerometer
    ofxAccelerometer.setup();
    
    //iPhoneAlerts will be sent to this.
    ofxiPhoneAlerts.addListener(this);
    
    // register touch events
    ofRegisterTouchEvents(this);
    
    //If you want a landscape oreintation
    //iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    
    ofSetBackgroundAuto(true);
    ofBackgroundGradient(ofColor(0), ofColor(0x490704));
    
    ofEnableAlphaBlending();
    ofSetFrameRate(FPS);
    ofEnableSmoothing();
    ofSetVerticalSync(true);
    ofSetCircleResolution(40);
    
    
    initialMass = 0.4f;
    
    world.init();
    world.doSleep = false;
    world.checkBounds(true);
    world.createBounds(0, 0, ofGetWidth(), ofGetHeight());
    world.registerGrabbing();
    world.setFPS(FPS);
    
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
}

//--------------------------------------------------------------
void testApp::update(){
    ofSoundUpdate();
    
    float accx = ofxAccelerometer.getForce().x;
    float accy = ofxAccelerometer.getForce().y;
    
    // Box2D
    world.update();
    
    float fx = accx * gravity;
    float fy = accy * -gravity;
    
    world.setGravity(fx, fy);
}

//--------------------------------------------------------------
void testApp::draw() {
    ofSetColor(255);
    ofPushStyle();
    ofClear(0);
    ofBackgroundGradient(ofColor(0), ofColor(0x490704), OF_GRADIENT_LINEAR);
    for (int i=0; i<eyeCircles.size(); i++) {
        eyeCircles[i]->draw();
    }
    for (int i=0; i<eyeRects.size(); i++) {
        eyeRects[i]->draw();
    }
    
    if (bDrawRadiusCircle) {
        ofSetHexColor(0xff0000);
        float radius = startLocation.distance(endLocation) / 2;
        ofCircle(startLocation, radius);
    }
    ofPopStyle();
    ofSetColor(255, 0, 0);
    // for(int i=0; i<joints.size(); i++)      joints[i]->draw();
}

//--------------------------------------------------------------
void testApp::contactStart(ofxBox2dContactArgs &e){
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
                // soundContact.play();
                // sound[aData->soundID].play();
            }
            
            if(bData)
            {
                bData->bHit = true;
                // soundContact.play();
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
void testApp::exit(){
    clearEyes();
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    if (!bDrawWhileDragging)
    {
        bDrawRadiusCircle = true;
        startLocation.set(touch.x, touch.y);
        endLocation.set(touch.x, touch.y);
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    endLocation.set(touch.x, touch.y);
    
    if (bDrawWhileDragging)
    {
        float size = ofRandom(sizeMin, sizeMax);
        if (bAddEyeCircles)     addCircleEye(endLocation, size);
        else                    addRectEye(endLocation, size, size);
    }
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    if (!bDrawWhileDragging)
    {
        bDrawRadiusCircle = false;
        
        float size = startLocation.distance(endLocation) / 2;
        
        if (size > 4 && size < ofGetWidth())
        {
            if (bAddEyeCircles)     addCircleEye(startLocation, size);
            else                    addRectEye(startLocation, size, size);
        }
        
        // get this circle and the prev circle
        if (eyeCircles.size() % 2 == 0 && eyeCircles.size() >= 2) {
            int a = (int)eyeCircles.size()-2;
            int b = (int)eyeCircles.size()-1;
            
            // now connect the new circle with a joint
            ofxBox2dJoint *joint = new ofxBox2dJoint;
            joint->setup(world.getWorld(), eyeCircles[a]->body, eyeCircles[b]->body);
            float length = eyeCircles[a]->getRadius()/2 + eyeCircles[b]->getRadius()/2 + 20;
            joint->setLength(length);
            joint->setFrequency(1.0);
            joint->setDamping(0.2);
            joints.push_back(joint);
        }
    }
}

//--------------------------------------------------------------
void testApp::addCircleEye(ofVec2f position, float radius){
    FishParticle *p = new FishParticle();
    
    p->setPhysics(radius * radius * initialMass, bounciness, friction);
    p->setup(world.getWorld(), position.x, position.y, radius);
    p->init();
    
    p->setData(new SoundData());
    SoundData * sd = (SoundData*)p->getData();
    sd->soundID = 0;
    sd->bHit    = false;
    
    eyeCircles.push_back(p);
    
    if (bSoundEnabled && !bDrawWhileDragging) soundPop.play();
}

//--------------------------------------------------------------
void testApp::addRectEye(ofVec2f position, float width, float height){
    FishRectParticle *p = new FishRectParticle();
    float area = width * height;
    p->setPhysics(area * initialMass, bounciness, friction);
    p->setup(world.getWorld(), position.x, position.y, width / 2, height / 2);
    p->init(width, height);
    
    p->setData(new SoundData());
    SoundData * sd = (SoundData*)p->getData();
    sd->soundID = 1;
    sd->bHit    = false;
    
    eyeRects.push_back(p);
    
    if (bSoundEnabled && !bDrawWhileDragging) soundPop.play();
}

//--------------------------------------------------------------
void testApp::clearEyes(){
    for(int i=0; i<eyeCircles.size(); i++)  eyeCircles[i]->destroy();
    for(int i=0; i<eyeRects.size(); i++)    eyeRects[i]->destroy();
    
    eyeCircles.clear();
    eyeRects.clear();
    
    // for(int i=0; i<joints.size(); i++)      joints[i]->destroy();
    joints.clear();
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
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
void testApp::gotMemoryWarning(){
    // Empty eyes on low memory
    clearEyes();
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
    
}

