//
//  KTOpenGLControl.m
//  KTUIKit
//
//  Created by Cathy on 20/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KTOpenGLControl.h"


@implementation KTOpenGLControl

//=========================================================== 
// - @synthesize-ers
//===========================================================
@synthesize enabled = mEnabled;
@synthesize highlighted = mHighlighted;
@synthesize target = wTarget;
@synthesize action = wAction;
@synthesize floatValue = mFloatValue;
@synthesize intValue = mIntValue;
@synthesize objectValue = mObjectValue;


//=========================================================== 
// - initWithFrame
//===========================================================
- (id)initWithFrame:(NSRect)theFrame
{
	if(![super initWithFrame:theFrame])
		return nil;
		
	[self setEnabled:YES];
	return self;
}

//=========================================================== 
// - dealloc
//===========================================================
- (void)dealloc
{
	[mObjectValue release];
	[super dealloc];
}

//=========================================================== 
// - performAction
//===========================================================
- (void)performAction
{
	if([self action])
	{
		// if our action is nil targeted - send the action
		// to th responder chain
		if([self target] == nil)
			[[self nextResponder] tryToPerform:[self action] with:self];
		else
		{
			if([[self target] respondsToSelector:[self action]])
				[[self target] performSelector:[self action] withObject:self];
		}
	}
}

//=========================================================== 
// - setIntValue
//===========================================================
- (void)setIntValue:(NSInteger)theIntValue
{
	mIntValue = theIntValue;
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setFloatValue
//===========================================================
- (void)setFloatValue:(CGFloat)theFloatValue
{
	mFloatValue = theFloatValue;
	[self setNeedsDisplay:YES];
}



@end