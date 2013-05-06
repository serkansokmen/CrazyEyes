#include "ofMain.h"
#include "testApp.h"

int main()
{
    ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow();
	
	// iOSWindow->enableDepthBuffer();
	// iOSWindow->enableAntiAliasing(2);
	// iOSWindow->enableRetina();
    
    ofSetupOpenGL(iOSWindow, 1024, 768, OF_FULLSCREEN);
    
	ofRunApp(new testApp);
}
