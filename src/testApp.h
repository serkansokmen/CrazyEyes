#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxBox2d.h"
#include "SettingsUIView.h"

#define FPS 30


class SoundData
{
public:
	int	 soundID;
	bool bHit;
};


class FishParticle : public ofxBox2dCircle
{
	float outerRadius;
	float innerRadius;
	float pupilRadius;
	
public:
	FishParticle(){
	}
	
	void init()
	{
		float radius = getRadius();
		
		outerRadius = radius;
		innerRadius = radius * ofRandom(.7, .9);
		pupilRadius = radius * ofRandom(.1, .4);
	}
	
	void draw()
	{
		glPushMatrix();
		glTranslatef(getPosition().x, getPosition().y, 0);
		
		glRotatef(getRotation() * 2, 0, 0, 1);
		
		// Outer
		ofSetHexColor(0x27AAE1);
		ofFill();
		ofCircle(0, 0, outerRadius);
		
		// White
		glTranslatef((outerRadius - innerRadius) / 2, (outerRadius - innerRadius) / 2, 0);
		ofSetHexColor(0xffffff);
		ofCircle(0, 0, innerRadius);
		
		// Pupil
		glTranslatef((innerRadius - pupilRadius) / 2, (innerRadius - pupilRadius) / 2, 0);
		ofSetColor(0);
		ofCircle(0, 0, pupilRadius);
		
		glPopMatrix();
	}
};

class FishRectParticle : public ofxBox2dRect
{
	float outerSize;
	float innerSize;
	float pupilSize;
	
public:
	
	FishRectParticle(){
	}
	
	void init(float w, float h)
	{
		outerSize = max(w, h);
		innerSize = outerSize * ofRandom(.7, .9);
		pupilSize = outerSize * ofRandom(.1, .4);
	}
	
	void draw()
	{
		ofSetRectMode(OF_RECTMODE_CENTER);
		glPushMatrix();
		glTranslatef(getPosition().x, getPosition().y, 0);
		
		glRotatef(getRotation() * 2, 0, 0, 1);
		
		// Outer
		ofSetColor(146, 138, 196);
		ofFill();
		ofRect(0, 0, outerSize, outerSize);
		
		// White
		glTranslatef((outerSize - innerSize - 4) / 2, (outerSize - innerSize - 4) / 2, 0);
		ofSetHexColor(0xffffff);
		ofRect(0, 0, innerSize, innerSize);
		
		// Pupil
		glTranslatef((innerSize - pupilSize * 1.2) / 2, (innerSize - pupilSize * 1.2) / 2, 0);
		ofSetColor(0);
		ofRect(0, 0, pupilSize * 1.2, pupilSize * 1.2);
		
		glPopMatrix();
		ofSetRectMode(OF_RECTMODE_CORNER);
	}
};



class testApp : public ofxiPhoneApp
{
public:
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void addCircleEye(ofVec2f position, float radius);
    void addRectEye(ofVec2f position, float width, float height);
    void clearEyes();
    
    // this is the function for contacts
    void contactStart(ofxBox2dContactArgs &e);
    void contactEnd(ofxBox2dContactArgs &e);
    
    ofSoundPlayer soundPop;
    ofSoundPlayer soundContact;
    
    bool bSoundEnabled = true;
        
    ofxBox2d world;
    
    vector <FishParticle *> eyeCircles;
	vector <FishRectParticle *> eyeRects;
    vector <ofxBox2dJoint *> joints;
    
    bool bAddEyeCircles = true;
    bool bDrawWhileDragging = false;
    bool bDrawRadiusCircle = false;
    
    // Drawing vectors
    ofVec2f startLocation;
    ofVec2f endLocation;
    
    //
    float initialMass = 20.0f;
    float friction = .8f;
    float bounciness = 0.5f;
    float gravity = 50.0f;
    float sizeMin = 2.0f;
    float sizeMax = 20.0f;
    
    SettingsUIView *settingsView;
};
