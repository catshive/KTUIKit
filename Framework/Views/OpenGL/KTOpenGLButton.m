//
//  KTOpenGLButton.m
//  KTUIKit
//
//  Created by Cathy on 20/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KTOpenGLButton.h"


@implementation KTOpenGLButton
@synthesize buttonType = mButtonType;
@synthesize state = mState;

- (void)setState:(KTOpenGLButtonState)theState
{
	mState = theState;
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent*)theEvent
{
	if([self enabled])
	{
		[self setState:KTOpenGLButtonState_Down];
	}
}

- (void)mouseUp:(NSEvent*)theEvent
{
	if([self enabled])
	{
		switch(mButtonType)
		{
			case KTOpenGLMomentaryPushButton:
				[self setState:KTOpenGLButtonState_Up];
				[self performAction];
			break;
			
//			case KTOpenGLToggleButton:
//				
//			break:
		}
	}
}


@end
