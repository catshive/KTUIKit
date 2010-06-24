//
//  KTOpenGLLayer.m
//  KTUIKit
//
//  Created by Cathy on 19/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KTOpenGLLayer.h"
#import <OpenGL/glu.h>
#import "KTLayoutManager.h"
#import "KTOpenGLView.h"


@interface KTOpenGLLayer (Private)
- (void)drawDebugging;
- (void)startTransformation;
- (void)applyTransformations;
- (void)endTransformation;
@end

@implementation KTOpenGLLayer

@synthesize frame = mFrame;
@synthesize rotation = mRotation;
@synthesize anchorPoint = mAnchorPoint;
@synthesize alpha = mAlpha;
@synthesize viewLayoutManager = mLayoutManager;
@synthesize sublayers = mSublayers;
@synthesize superlayer = mSuperlayer;
@synthesize view = wView;
@synthesize drawDebuggingRects = mDrawDebuggingRects;

//=========================================================== 
// - initWithFrame
//===========================================================
- (id)initWithFrame:(NSRect)theFrame
{
	if(self = [super init])
	{
		mFrame = theFrame;
		mSublayers = [[NSMutableArray alloc] init];
		mLayoutManager = [[KTLayoutManager alloc] initWithView:self];
		mAlpha = 1.0;
		wView = nil;
		mAnchorPoint = NSMakePoint(0.0, 0.0);
	}
	return self;
}


//=========================================================== 
// - dealloc
//===========================================================
- (void)dealloc
{
	[mSublayers release];
	[mLayoutManager release];
	wView = nil;
	[super dealloc];
}

//=========================================================== 
// - addSublayer
//===========================================================
- (void)addSublayer:(KTOpenGLLayer*)theSublayer
{
	if(theSublayer)
	{
		// take care of the responder chain
		[theSublayer setNextResponder:self];
		// tell sublayer about its super layer
		[theSublayer setSuperlayer:self];
		// tell the sublayer about its view
		[theSublayer setView:[self view]];
		
		// add
		[mSublayers addObject:theSublayer];
	}
}


//=========================================================== 
// - removeSublayer
//===========================================================
- (void)removeSublayer:(KTOpenGLLayer*)theSublayer
{
	if(theSublayer)
		[mSublayers removeObject:theSublayer];
}


//=========================================================== 
// - drawLayers
//===========================================================
- (void)drawLayers
{

	[self startTransformation];
	[self applyTransformations];
	
	// do all the drawing
	if(mDrawDebuggingRects)
		[self drawDebugging];
	
	// draw ourself
	[self draw];

	// draw sublayers
	for(KTOpenGLLayer * aSublayer in [self sublayers])
		[aSublayer drawLayers];
	
	[self drawOverlays];	
	[self endTransformation];	
}

- (void)drawOverlays
{
}

- (void)startTransformation
{
	glPushMatrix();
}

- (void)endTransformation
{
	glPopMatrix();
}

//=========================================================== 
// - applyTransformations
//===========================================================
- (void)applyTransformations
{
	// translate so that we are "centered" around our anchor point
	NSPoint anAnchorPoint = [self anchorPoint];
	NSRect	aFrame = [self frame];
	CGFloat anXTranslate = aFrame.origin.x + (aFrame.size.width*anAnchorPoint.x) + [[self superlayer] position].x;
	CGFloat aYTranslate = aFrame.origin.y + (aFrame.size.height*anAnchorPoint.y) + [[self superlayer] position].y;
	CGFloat aZTranslate = 0;
	// rotation - we only support 'z' rotation for now, no 3D
	CGFloat anXRotation = 0;
	CGFloat aYRotation = 0;
	CGFloat aZRotation = [self rotation];
	// apply the transofomations
	glTranslatef(anXTranslate, aYTranslate, aZTranslate);
	glRotatef(anXRotation, 1, 0, 0);
	glRotatef(aYRotation, 0, 1, 0);
	glRotatef(aZRotation, 0, 0, 1);
}


//=========================================================== 
// - draw
//===========================================================
- (void)draw
{
}

//=========================================================== 
// - draw
//===========================================================
- (NSPoint)position
{
	NSPoint anAnchorPoint = [self anchorPoint];
	NSRect aFrame = [self frame];
	return NSMakePoint(-aFrame.size.width*anAnchorPoint.x, -aFrame.size.height*anAnchorPoint.y);
}

//=========================================================== 
// - drawDebugging
//===========================================================
- (void)drawDebugging
{
	NSRect aBoundsRect = [self bounds];
	aBoundsRect.origin = [self position];
	NSRect anInsetFrame = NSInsetRect(aBoundsRect, 10, 10);
	NSRect anOriginRect = NSMakeRect(aBoundsRect.origin.x, aBoundsRect.origin.y, 10, 10);
	
	glColor4f(1, 0, 0, .5);
	glBegin(GL_QUADS);
		glVertex2f(NSMinX(anOriginRect), NSMinY(anOriginRect));
		glVertex2f(NSMinX(anOriginRect), NSMaxY(anOriginRect));
		glVertex2f(NSMaxX(anOriginRect), NSMaxY(anOriginRect));
		glVertex2f(NSMaxX(anOriginRect), NSMinY(anOriginRect));
	glEnd();
	glColor4f(0, 1, 0, .5);
	glBegin(GL_QUADS);
		glVertex2f(NSMinX(anInsetFrame), NSMinY(anInsetFrame));
		glVertex2f(NSMinX(anInsetFrame), NSMaxY(anInsetFrame));
		glVertex2f(NSMaxX(anInsetFrame), NSMaxY(anInsetFrame));
		glVertex2f(NSMaxX(anInsetFrame), NSMinY(anInsetFrame));
	glEnd();
	
}

//=========================================================== 
// - setNeedsDisplay
//===========================================================
- (void)setNeedsDisplay:(BOOL)theBool
{
	[[self view] setNeedsDisplay:YES];
}

//=========================================================== 
// - display
//===========================================================
- (void)display
{
	[[self view] display];
}


//=========================================================== 
// - setView
//===========================================================
- (void)setView:(KTOpenGLView*)theView
{
	wView = theView;
	[mSublayers makeObjectsPerformSelector:@selector(setView:) withObject:theView];
}


//=========================================================== 
// - notifiyLayersViewDidReshape
//===========================================================
- (void)notifiyLayersViewDidReshape
{
//	[self viewDidReshape];
//	[mSublayers makeObjectsPerformSelector:@selector(notifiyLayersViewDidReshape:) withObject:nil];
}


//=========================================================== 
// - viewDidReshape
//===========================================================
- (void)viewDidReshape
{
}



#pragma mark Coordinate System
//=========================================================== 
// - convertRect:fromLayer
//===========================================================
- (NSRect)convertRect:(NSRect)theRect fromLayer:(KTOpenGLLayer*)theLayer
{
	NSRect aRectToReturn = NSZeroRect;
	aRectToReturn.origin = [self convertPoint:theRect.origin fromLayer:theLayer];
	aRectToReturn.size = theRect.size;
	return aRectToReturn;
}

//=========================================================== 
// - convertPoint:fromLayer
//===========================================================
- (NSPoint)convertPoint:(NSPoint)thePoint fromLayer:(KTOpenGLLayer*)theLayer
{
	NSPoint aPointToReturn = NSZeroPoint;
	// convert the point to the view's coordinate system
	NSPoint aLayerOrigin = [theLayer frame].origin;
	NSPoint aViewPoint = NSMakePoint(aLayerOrigin.x + thePoint.x, aLayerOrigin.y + thePoint.y);
	// where is this point in our coordinate system?
	aPointToReturn.x = aViewPoint.x - [self frame].origin.x;
	aPointToReturn.y = aViewPoint.y - [self frame].origin.y;
	return aPointToReturn;
}

//=========================================================== 
// - convertRectToViewRect
//===========================================================
- (NSRect)convertRectToViewRect:(NSRect)theRect
{
	NSRect aRectToReturn = theRect;
	aRectToReturn.origin = [self convertPointToViewPoint:aRectToReturn.origin];
	return aRectToReturn;
}

//=========================================================== 
// - convertPointToViewPoint
//===========================================================
- (NSPoint)convertPointToViewPoint:(NSPoint)thePoint
{
	NSPoint aPointToReturn = thePoint;
	// go up the layer tree until we find the view - we will adjust our coordinates for each layer
	KTOpenGLLayer * aLayer = self;
	while(aLayer != nil)
	{
		NSRect aLayerFrame = [aLayer frame];
		aPointToReturn.x+=aLayerFrame.origin.x;
		aPointToReturn.y+=aLayerFrame.origin.y;
		aLayer = [aLayer superlayer];
	}
	return aPointToReturn;
}



//=========================================================== 
// - convertViewPointToLayerPoint
//===========================================================
- (NSPoint)convertViewPointToLayerPoint:(NSPoint)thePoint
{
	NSPoint aPointToReturn = thePoint;
	// go up the layer hierarchy until we get the view and subtract the frame origin
	KTOpenGLLayer * aSuperLayer = [self superlayer];
	while (aSuperLayer != nil) 
	{
		NSRect aSuperLayerFrame = [aSuperLayer frame];
		aPointToReturn.x-=aSuperLayerFrame.origin.x;
		aPointToReturn.y-=aSuperLayerFrame.origin.y;
		aSuperLayer = [aSuperLayer superlayer];
	}
	// subtract our own frame origin
	aPointToReturn.x-=[self frame].origin.x;
	aPointToReturn.y-=[self frame].origin.y;
	return aPointToReturn;
}


#pragma mark Rotation
- (void)setRotation:(CGFloat)theRotation
{
	mRotation = theRotation;
	// rotate our sublayers as well?
}

- (void)setAnchorPoint:(NSPoint)theAnchorPoint
{
	mAnchorPoint = theAnchorPoint;
}




#pragma mark Events
//=========================================================== 
// - hitTest
//===========================================================
- (KTOpenGLLayer*)hitTest:(NSPoint)thePoint
{
	KTOpenGLLayer * aLayerToReturn = nil;
	
	NSInteger aSublayerCount = [[self sublayers] count];
	NSInteger i;
	for(i = 0; i < aSublayerCount; i++)
	{
		KTOpenGLLayer * aSublayer = [[self sublayers] objectAtIndex:i];
		if([aSublayer hitTest:thePoint])
			aLayerToReturn = aSublayer;
	}
	
	if(aLayerToReturn == nil)
	{
		thePoint = [self convertViewPointToLayerPoint:thePoint];
		NSRect aLayerRect = [self bounds];
		aLayerRect.origin = [self position];
		if(NSPointInRect(thePoint, aLayerRect))
			aLayerToReturn = self;
	}
	return aLayerToReturn;
}

//=========================================================== 
// - updateTrackingAreas:
//===========================================================
- (void)updateTrackingAreas
{
//	for(KTOpenGLLayer * aSublayer in mSublayers)
//	{
//		if([aSublayer respondsToSelector:@selector(updateTrackingAreas)])
//			[aSublayer updateTrackingAreas];
//	}
	// subclasses make sure to call super!
}

//=========================================================== 
// - viewWillMoveToWindow:
//===========================================================
- (void)viewWillMoveToWindow:(NSWindow*)theWindow
{
	for(KTOpenGLLayer * aSublayer in mSublayers)
	{
		if([aSublayer respondsToSelector:@selector(viewWillMoveToWindow:)])
			[aSublayer viewWillMoveToWindow:theWindow];
	}
	
	// subclasses make sure to call super!
}



#pragma mark KTLayoutManager protocol
//=========================================================== 
// - setFrame
//===========================================================
- (void)setFrame:(NSRect)theFrame
{
	mFrame = theFrame;
	for(KTOpenGLLayer * aSublayer in [self sublayers])
		[[aSublayer viewLayoutManager] refreshLayout];
}

//=========================================================== 
// - frame
//===========================================================
- (NSRect)frame
{
	// our frame is dependent on our rotation
	// and anchor point
	/*
		r = a * (1 - pow(2, E)) / (1 + E*cos(theta))
		-------
		a = half width
		b = half height
		E = sqr( pow(2,a) - pow(2, b)) / a
		or
		E = sqr( 1 - ( pow(2, b) / pow(2, a)))
	*/

	return mFrame;
}

//=========================================================== 
// - updateBoundsForNewFrame
//===========================================================
- (void)updateBoundsForNewFrame:(NSRect)theFrame
{
	/*
		we need to adjust our size if it's different
	*/
	//	NSPoint anAnchorPoint = [self anchorPoint];
	//return NSMakeRect(-aFrame.size.width*anAnchorPoint.x, -aFrame.size.height*anAnchorPoint.y, aFrame.size.width, aFrame.size.height);

}


//=========================================================== 
// - bounds
//===========================================================
- (NSRect)bounds
{
	NSRect aFrame = [self frame];
	return NSMakeRect(0, 0, aFrame.size.width, aFrame.size.height);
}

//=========================================================== 
// - parent
//===========================================================
- (id<KTViewLayout>)parent
{
	id<KTViewLayout> aParent = nil;
	if(mSuperlayer!=nil)
		aParent = mSuperlayer;
	else if(wView != nil)
		aParent = wView;
	return aParent;
}

//=========================================================== 
// - children
//===========================================================
- (NSArray*)children
{
	return mSublayers;
}


@end