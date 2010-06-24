//
//  KTOpenGLView.m
//  KTUIKit
//
//  Created by Cathy on 16/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KTOpenGLView.h"
#import "KTOpenGLLayer.h"
#import "KTViewOverlayWindow.h"

@interface KTOpenGLView (Private)

- (void)setup2DCamera;
- (void)setup3DCamera;

@end

@implementation KTOpenGLView

@synthesize openGLLayer = mOpenGLLayer;
@synthesize shouldAcceptFirstResponder = mShouldAcceptFirstResponder;
@synthesize opaque = mOpaque;

//=========================================================== 
// - defaultPixelFormat
//=========================================================== 
+ (NSOpenGLPixelFormat*)defaultPixelFormat
{
	NSOpenGLPixelFormatAttribute anAttributes[] = 
	{
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)32, 
		NSOpenGLPFAStencilSize,(NSOpenGLPixelFormatAttribute)1,		
		(NSOpenGLPixelFormatAttribute)0 // zero terminated array
	};
    return [[(NSOpenGLPixelFormat *)[NSOpenGLPixelFormat alloc] initWithAttributes:anAttributes] autorelease];
}


//=========================================================== 
// - initWithFrame:
//=========================================================== 
- (id)initWithFrame:(NSRect)theFrame
{
		
	NSOpenGLPixelFormat * aPixelFormat = [KTOpenGLView defaultPixelFormat];
	[super initWithFrame:theFrame pixelFormat:aPixelFormat];
	
	NSOpenGLContext * anOpenGLContext = [self openGLContext];
	[anOpenGLContext makeCurrentContext];
	
	// swap interval
	GLint swapInterval = 1;
	[anOpenGLContext setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];

	// Layout
	KTLayoutManager * aLayoutManger = [[[KTLayoutManager alloc] initWithView:self] autorelease];
	[self setViewLayoutManager:aLayoutManger];
	[self setAutoresizesSubviews:NO];
	
	// Styles
	KTStyleManager * aStyleManager = [[[KTStyleManager alloc] initWithView:self] autorelease];
	[self setStyleManager:aStyleManager];
	
	// overlay window
	mOverlayWindows = [[NSMutableArray alloc] init];
	
	// For Debugging
	[self setLabel:@"KTOpenGLView"];
	[self setOpaque:NO];
	
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	
	[theCoder encodeObject:[self viewLayoutManager] forKey:@"layoutManager"];
	[theCoder encodeObject:[self styleManager] forKey:@"styleManager"];
	[theCoder encodeObject:[self label] forKey:@"label"];

}

//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{
	if (self = [super initWithCoder:theCoder])
	{
		
		NSOpenGLPixelFormat * aPixelFormat = [KTOpenGLView defaultPixelFormat];
		[self setPixelFormat:aPixelFormat];
		
		NSOpenGLContext * anOpenGLContext = [self openGLContext];
		[anOpenGLContext makeCurrentContext];
		
		// swap interval
		GLint swapInterval = 1;
		[anOpenGLContext setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
			
		KTLayoutManager * aLayoutManager = [theCoder decodeObjectForKey:@"layoutManager"];
		[aLayoutManager setView:self];
		[self setViewLayoutManager:aLayoutManager];
		[self setAutoresizesSubviews:NO];
		[self setAutoresizingMask:NSViewNotSizable];
		
		KTStyleManager * aStyleManager = [theCoder decodeObjectForKey:@"styleManager"];
		[aStyleManager setView:self];
		[self setStyleManager:aStyleManager];
		
		// overlay window
		mOverlayWindows = [[NSMutableArray alloc] init];
		
		[self setLabel:[theCoder decodeObjectForKey:@"label"]];
		[self setOpaque:NO];
	}
	return self;
}




//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{	
	[mLayoutManager release];
	[mStyleManager release];
	[mLabel release];
	[mOpenGLLayer setView:nil];
	[mOpenGLLayer release];
	for(KTViewOverlayWindow * anOverlayWindow in mOverlayWindows)
		[self removeOverlayWindow:anOverlayWindow];
	[mOverlayWindows release];
	[super dealloc];
}


//=========================================================== 
// - renewGState
//=========================================================== 
- (void)renewGState 
{
    NSWindow *window = [self window];
    if ([window respondsToSelector:@selector(disableScreenUpdatesUntilFlush)]) {
        [window disableScreenUpdatesUntilFlush];
    }
    [super renewGState];
}


//=========================================================== 
// - isOpaque
//=========================================================== 
- (BOOL)isOpaque
{
	return mOpaque;
}

//=========================================================== 
// - prepareOpenGL
//=========================================================== 
- (void)prepareOpenGL
{
    glDisable (GL_ALPHA_TEST);
    glDisable (GL_DEPTH_TEST);
    glDisable (GL_SCISSOR_TEST);
    glDisable (GL_DITHER);
    glDisable (GL_CULL_FACE);
	glDisable(GL_STENCIL_TEST);
		
//    glColorMask (GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glDepthMask (GL_FALSE);
    glStencilMask (GL_FALSE);
	
    glHint (GL_TRANSFORM_HINT_APPLE, GL_FASTEST);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

//=========================================================== 
// - reshape
//=========================================================== 
- (void) reshape
{
	[super reshape];
	[self setup2DCamera];
	if(mOpenGLLayer)
		[mOpenGLLayer setFrame:[self bounds]];
}

//=========================================================== 
// - update
//=========================================================== 
- (void)update
{
	[super update];
}

#pragma mark -
#pragma mark Drawing
//=========================================================== 
// - drawRect:
//=========================================================== 
- (void)drawRect:(NSRect)theRect
{	
	// this is a bit hacky, but want to make sure
	// that the entire bounds are used and not an update rect 
	// from 'setNeedsDisplay:inRect:' because we're always
	// clearing all the pixels on every redraw in an openGLView
	theRect = [self bounds];
	
	NSOpenGLContext * aCurrentContext = [self openGLContext];
	[aCurrentContext makeCurrentContext];

//	if(mOpenGLViewType == kBW3DOpenGLView)
//		[self setup3DCamera];
//	else
		[self setup2DCamera];

	CGFloat aRed, aGreen, aBlue, anAlpha;
	[[[[self styleManager] backgroundColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&aRed green:&aGreen blue:&aBlue alpha:&anAlpha];
	glClearColor(aRed, aGreen, aBlue, anAlpha);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	[self drawInContext:aCurrentContext];
	[aCurrentContext flushBuffer];
		
}

//=========================================================== 
// - drawInContext:
//=========================================================== 
- (void)drawInContext:(NSOpenGLContext*)theContext
{
	// subclasses can override this to do custom drawing over the styles
	if(mOpenGLLayer)
		[mOpenGLLayer drawLayers];
}



//=========================================================== 
// - setup2DCamera
//=========================================================== 
- (void) setup2DCamera
{
	NSRect aVisibleRectBounds = [self visibleRect];
    // set viewing
	glViewport (0, 0, aVisibleRectBounds.size.width, aVisibleRectBounds.size.height);
	glMatrixMode (GL_PROJECTION);
	glLoadIdentity();
	glOrtho(aVisibleRectBounds.origin.x, 
			aVisibleRectBounds.origin.x+aVisibleRectBounds.size.width, 
			aVisibleRectBounds.origin.y,
			aVisibleRectBounds.origin.y+aVisibleRectBounds.size.height,
			-1, 1);
	
    // set modeling
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}


//=========================================================== 
// - setup3DCamera
//=========================================================== 
- (void) setup3DCamera
{	
    NSRect aBounds = [self bounds];
    int aWidth = aBounds.size.width;
    int aHeight = aBounds.size.height;
	if(aHeight==0)
		aHeight = 1;
		
    // set viewing
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glViewport(0, 0, aWidth, aHeight); 
	gluPerspective( 60, ((float)aWidth)/((float)(aHeight)), 0.1, 100000.0);
	
    // set modeling
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
	float aZPos = -1.0 * (aBounds.size.height*0.5) / tan( 3.14159 / 6.0 );
	glTranslatef(-aBounds.size.width*0.5, -aBounds.size.height*0.5, aZPos );
}

#pragma mark -
#pragma mark openGLLayers
//=========================================================== 
// - setOpenGLLayer:
//===========================================================
- (void)setOpenGLLayer:(KTOpenGLLayer*)theLayer
{
	[theLayer retain];
	
//	id aNextResponder = [self nextResponder];
//	// make the layer our next responder
//	[self setNextResponder:theLayer];
//	
//	if(aNextResponder != mOpenGLLayer)
//		[theLayer setNextResponder:aNextResponder];
//	else
//		[theLayer setNextResponder:[mOpenGLLayer nextResponder]];
	[theLayer setNextResponder:self];
	
	[mOpenGLLayer setView:nil];
	[mOpenGLLayer release];
	
	[theLayer setView:self];
	[theLayer setSuperlayer:nil];

	mOpenGLLayer = theLayer;
	[mOpenGLLayer setFrame:[self bounds]];
	[self setShouldAcceptFirstResponder:YES];
}




#pragma mark -
#pragma mark Overlay Windows
//=========================================================== 
// - addOverlayWindow:
//===========================================================
- (void)addOverlayWindow:(KTViewOverlayWindow*)theOverlayWindow
{	
	[theOverlayWindow setParentView:self];
	[mOverlayWindows addObject:theOverlayWindow];

	if([self window])
	{
		[[self window] addChildWindow:theOverlayWindow ordered:NSWindowAbove];
//		if([theOverlayWindow isVisible]==NO)
//			[theOverlayWindow orderOut:self];		
	}
}

//=========================================================== 
// - removeOverlayWindow:
//===========================================================
- (void)removeOverlayWindow:(KTViewOverlayWindow*)theOverlayWindow
{
	[theOverlayWindow setParentView:nil];
	[mOverlayWindows removeObject:theOverlayWindow];
	if([self window])
	{
//		if([theOverlayWindow isVisible])
//			[theOverlayWindow close];
		[[self window] removeChildWindow:theOverlayWindow];	
	}
}


//=========================================================== 
// - removeOverlayWindow:
//===========================================================
- (void)viewWillMoveToWindow:(NSWindow*)theWindow
{
	// remove the overlays from the current window
	NSWindow * aCurrentWindow = [self window];
	if(aCurrentWindow)
	{
		for(NSWindow * anOverlay in mOverlayWindows)
		{	
//			if([anOverlay isVisible])
//				[anOverlay close];
			[aCurrentWindow removeChildWindow:anOverlay];
		}
	}
	// and add them to the new window
	if(theWindow)
	{
		for(NSWindow * anOverlay in mOverlayWindows)
		{
			[theWindow addChildWindow:anOverlay ordered:NSWindowAbove];
//			if([anOverlay isVisible]==NO)
//				[anOverlay orderOut:self];
		}
	}
	
	
	// send the message to our layer
	if(mOpenGLLayer)
	{
		[mOpenGLLayer viewWillMoveToWindow:(NSWindow*)theWindow];
	}
}

#pragma mark -
#pragma mark Responder Chain
//=========================================================== 
// - setNextResponder:
//===========================================================
- (void)setNextResponder:(NSResponder*)theResponder
{
	if(mOpenGLLayer!=nil)
	{
		[super setNextResponder:mOpenGLLayer];
		[mOpenGLLayer setNextResponder:theResponder];
	}
	else
		[super setNextResponder:theResponder];
}

//=========================================================== 
// - acceptsFirstResponder:
//===========================================================
- (BOOL)acceptsFirstResponder
{
	return mShouldAcceptFirstResponder;	
}


//=========================================================== 
// - becomeFirstResponder:
//===========================================================
- (BOOL)becomeFirstResponder
{
	if(mOpenGLLayer!=nil)
	{
		if([mOpenGLLayer becomeFirstResponder])
			[mOpenGLLayer setNeedsDisplay:YES];
		return [mOpenGLLayer becomeFirstResponder];
	}
	return mShouldAcceptFirstResponder;
}


//=========================================================== 
// - resignFirstResponder:
//===========================================================
- (BOOL)resignFirstResponder
{
	if(mOpenGLLayer!=nil)
	{
		if([mOpenGLLayer resignFirstResponder])
			[mOpenGLLayer setNeedsDisplay:YES];
		return [mOpenGLLayer resignFirstResponder];
	}
	return YES;
}

//=========================================================== 
// - rightMouseDown:
//===========================================================
- (void)rightMouseDown:(NSEvent *)theEvent
{
	if(mOpenGLLayer)
	{
		NSPoint	aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		KTOpenGLLayer * aHitTestResult = [mOpenGLLayer hitTest:aMousePoint];
		if(aHitTestResult)
		{
			[aHitTestResult rightMouseDown:theEvent];
			wCurrentMouseEventHandler = aHitTestResult;
			return;
		}
	}
}


//=========================================================== 
// - mouseDown:
//===========================================================
- (void)mouseDown:(NSEvent*)theEvent
{
	if(mOpenGLLayer)
	{
		NSPoint	aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		KTOpenGLLayer * aHitTestResult = [mOpenGLLayer hitTest:aMousePoint];
		if(aHitTestResult)
		{
			if([aHitTestResult respondsToSelector:@selector(mouseDown:)])
			{
				[aHitTestResult mouseDown:theEvent];
				wCurrentMouseEventHandler = aHitTestResult;
			}
			return;
		}
	}
}

//=========================================================== 
// - mouseUp:
//===========================================================
- (void)mouseUp:(NSEvent*)theEvent
{
	if(mOpenGLLayer)
	{
		if(wCurrentMouseEventHandler!=nil)
		{
			[wCurrentMouseEventHandler mouseUp:theEvent];
			wCurrentMouseEventHandler = nil;
			return;
		}
		else
		{
			NSPoint	aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			KTOpenGLLayer * aHitTestResult = [mOpenGLLayer hitTest:aMousePoint];
			if(aHitTestResult)
			{
				[aHitTestResult mouseUp:theEvent];
				return;
			}
		}
	}
}

//=========================================================== 
// - mouseDragged:
//===========================================================
- (void)mouseDragged:(NSEvent*)theEvent
{
	if(mOpenGLLayer)
	{
		if(wCurrentMouseEventHandler!=nil)
		{
			[wCurrentMouseEventHandler mouseDragged:theEvent];
			return;
		}
		else
		{
			NSPoint	aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			KTOpenGLLayer * aHitTestResult = [mOpenGLLayer hitTest:aMousePoint];
			if(aHitTestResult)
			{
				[aHitTestResult mouseDragged:theEvent];
				wCurrentMouseEventHandler = aHitTestResult;
				return;
			}
		}
	}
}


//=========================================================== 
// - mouseMoved:
//===========================================================
//- (void)mouseMoved:(NSEvent*)theEvent
//{
//	if(mOpenGLLayer)
//	{
//		NSPoint	aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//		KTOpenGLLayer * aHitTestResult = [mOpenGLLayer hitTest:aMousePoint];
//		if(aHitTestResult)
//		{
//			[aHitTestResult mouseMoved:theEvent];
//			return;
//		}
//	}
//}


//=========================================================== 
// - scrollWheel:
//===========================================================
- (void)scrollWheel:(NSEvent *)theEvent
{
	if(mOpenGLLayer)
	{
		NSPoint	aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		KTOpenGLLayer * aHitTestResult = [mOpenGLLayer hitTest:aMousePoint];
		if(aHitTestResult)
		{
			[aHitTestResult scrollWheel:theEvent];
			return;
		}
	}
}


//=========================================================== 
// - updateTrackingAreas:
//===========================================================
//- (void)updateTrackingAreas
//{
//	if(mOpenGLLayer)
//	{
//		[mOpenGLLayer updateTrackingAreas];
//	}
//}



#pragma mark -
#pragma mark Layout protocol
//=========================================================== 
// - setViewLayoutManager:
//===========================================================
- (void)setViewLayoutManager:(KTLayoutManager*)theLayoutManager
{
	if(mLayoutManager != theLayoutManager)
	{
		[mLayoutManager release];
		mLayoutManager = [theLayoutManager retain];
	}
}

//=========================================================== 
// - viewLayoutManager
//===========================================================
- (KTLayoutManager*)viewLayoutManager
{
	return mLayoutManager;
}

//=========================================================== 
// - setFrame:
//===========================================================
- (void)setFrame:(NSRect)theFrame
{
	[super setFrame:theFrame];
	
	NSArray * aSubviewList = [self children];
	int aSubviewCount = [aSubviewList count];
	int i;
	for(i = 0; i < aSubviewCount; i++)
	{
		 id aSubview = [aSubviewList objectAtIndex:i];
		
		// if the subview conforms to the layout protocol, tell its layout
		// manager to refresh its layout
		if( [aSubview conformsToProtocol:@protocol(KTViewLayout)] )
		{
			[[(id<KTViewLayout>)aSubview viewLayoutManager] refreshLayout];
		}
	}
}

//=========================================================== 
// - frame
//===========================================================
- (NSRect)frame
{
	return [super frame];
}

//=========================================================== 
// - parent
//===========================================================
- (id<KTViewLayout>)parent
{
	if([[self superview] conformsToProtocol:@protocol(KTViewLayout)])
		return (id<KTViewLayout>)[self superview];
	else
		return nil;
}

//=========================================================== 
// - children
//===========================================================
- (NSArray*)children
{
	NSMutableArray *	aChildren = [NSMutableArray array];
	if(mOpenGLLayer!=nil)
		[aChildren addObject:mOpenGLLayer];
	if([mOverlayWindows count] > 0)
		[aChildren addObjectsFromArray:mOverlayWindows];
	return aChildren;
}



#pragma mark -
#pragma mark KTStyledView protocol
//=========================================================== 
// - setStyleManager:
//===========================================================
- (void)setStyleManager:(KTStyleManager*)theStyleManager
{
	if(mStyleManager != theStyleManager)
	{
		[mStyleManager release];
		mStyleManager = [theStyleManager retain];
	}
}

//=========================================================== 
// - styleManager
//===========================================================
- (KTStyleManager*)styleManager
{
	return mStyleManager;
}

//=========================================================== 
// - window
//===========================================================
- (NSWindow *)window
{
	return [super window];
}



#pragma mark -
#pragma mark KTView protocol
//=========================================================== 
// - setLabel:
//===========================================================
- (void)setLabel:(NSString*)theLabel
{
	if(mLabel != theLabel)
	{
		[mLabel release];
		mLabel = [[NSString alloc] initWithString:theLabel];
	}
}

//=========================================================== 
// - label
//===========================================================
- (NSString*)label
{
	return mLabel;
}

@end
