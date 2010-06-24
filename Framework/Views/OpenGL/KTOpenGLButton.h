//
//  KTOpenGLButton.h
//  KTUIKit
//
//  Created by Cathy on 20/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTOpenGLControl.h"

typedef enum
{
	KTOpenGLButtonState_Up = 0,
	KTOpenGLButtonState_Down
	
}KTOpenGLButtonState;


typedef enum
{
	KTOpenGLMomentaryPushButton = 0,
	KTOpenGLToggleButton
	
}KTOpenGLButtonType;

@interface KTOpenGLButton : KTOpenGLControl 
{
	KTOpenGLButtonType			mButtonType;
	KTOpenGLButtonState			mState;

}



@property (readwrite, assign) KTOpenGLButtonType buttonType;
@property (readwrite, assign) KTOpenGLButtonState state;

@end
