//
//  SettingsUIView.cpp
//  FishEyes
//
//  Created by Serkan Sökmen on 30.04.2013.
//
//

#import "SettingsUIView.h"
#import "ofxiPhoneExtras.h"
#import "testApp.h"

@implementation SettingsUIView

testApp *app;

-(void) viewDidLoad
{
    app = (testApp*)ofGetAppPtr();
}

-(IBAction)hide
{
    [[self view] setHidden:YES];
}

-(IBAction)toggleDrawWhileDragging:(id)sender
{
    UISwitch *switcher = (UISwitch*)sender;
    app->bDrawWhileDragging = switcher.on;
}

-(IBAction)toggleAddCircles:(id)sender
{
    UISwitch *switcher = (UISwitch*)sender;
    app->bAddEyeCircles = switcher.on;
}


- (IBAction)clearEyes :(UIButton *)sender
{
    app->clearEyes();
}

- (IBAction)setBounciness:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->bounciness = [sliderObj value];
}
- (IBAction)setFriction:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->friction = [sliderObj value];
}

- (IBAction)setGravity:(UISlider *)sender
{
    UISlider *sliderObj = (UISlider*)sender;
    app->gravity = [sliderObj value];
}

-(IBAction)toggleSoundEnabled:(id)sender
{
    UISwitch *switcher = (UISwitch*)sender;
    app->bSoundEnabled = switcher.on;
}


@end
