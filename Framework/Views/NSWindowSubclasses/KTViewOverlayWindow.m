//
//  KTViewOverlayWindow.m
//  KTUIKit
//
//  Created by Cathy on 22/09/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTViewOverlayWindow.h"
#import "KTView.h"
#import "KTLayoutManager.h"

@implementation KTViewOverlayWindow
//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (id)initWithContentRect:(NSRect)theContentRect styleMask:(NSUInteger)theStyleMask backing:(NSBackingStoreType)theBacking defer:(BOOL)theDefer
{
	if(self = [super initWithContentRect:theContentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO])
	{
		[self setBackgroundColor:[NSColor clearColor]];
		[self setMovableByWindowBackground:NO];
		[self setExcludedFromWindowsMenu:YES];
		[self useOptimizedDrawing:YES];
		[self setReleasedWhenClosed:NO];
		[self setHidesOnDeactivate:NO];
		KTLayoutManager * aLayoutManger = [[[KTLayoutManager alloc] initWithView:self] autorelease];
		[self setViewLayoutManager:aLayoutManger];
		
//		KTView * aDebugView = [[[KTView alloc] initWithFrame:theContentRect] autorelease];
//		[[self contentView] addSubview:aDebugView];
//		[[aDebugView styleManager] setBackgroundColor:[[NSColor greenColor] colorWithAlphaComponent:.5]];
	}
	return self;
}

//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (void)dealloc
{
	[mLayoutManager release];
	[super dealloc];
}


//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (void)setParentView:(id<KTViewLayout>)theParentView
{
	wParentView = theParentView;
}


#pragma mark -
#pragma mark KTViewLayout Protocol Methods
//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (void)setViewLayoutManager:(KTLayoutManager*)theLayoutManager
{
	if(theLayoutManager != mLayoutManager)
	{
		[theLayoutManager retain];
		[mLayoutManager release];
		mLayoutManager = theLayoutManager;
	}
}

//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (KTLayoutManager*)viewLayoutManager
{
	return mLayoutManager;
}

//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (void)setFrame:(NSRect)theFrame
{
	// the frame passed in will be in terms of the parent view's coordiinate system
	// we need to translate this to screen coordinates
	// and call NSWindow's setFrame:display:
//	NSLog(@"OverlayWindow setFrame %@", self);
//	NSLog(@"current frame: %@", NSStringFromRect([self frame]));
	NSRect aFrameToSet = theFrame;
	// convert from the parent view's coords to its its window's coords
	if(		wParentView 
		&&	[wParentView isKindOfClass:[NSView class]])
	{
		// now get the screen origin from the parent's window
		NSPoint aBasePoint = [(NSView*)wParentView convertPointToBase:aFrameToSet.origin];
		NSPoint aScreenPoint = [[(NSView*)wParentView window] convertBaseToScreen:aBasePoint];
		aFrameToSet.origin = aScreenPoint;
		aFrameToSet.size = theFrame.size;
//		NSLog(@"a frame to set: %@", NSStringFromRect(aFrameToSet));
	}
	[self setFrame:aFrameToSet display:YES animate:NO];
	//NSLog(@"new frame: %@", NSStringFromRect([self frame]));
}
//
//- (void)setFrameOrigin:(NSPoint)point
//{
//	NSLog(@"setFrameOrigin:%s", NSStringFromPoint(point));
//}
//
//- (void)setFrameTopLeftPoint:(NSPoint)point
//{
//	NSLog(@"set frame top left point");
//}

//
// -(void)setFrame:(NSRect)windowFrame display:(BOOL)displayViews
// {
//	NSLog(@"set Frame: display:");
//	[super setFrame:windowFrame display:displayViews];
// }
// 
//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (NSRect)frame
{
	// our frame is in terms of screen coordinates
	return [super frame];
}

//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (id<KTViewLayout>)parent
{
	return wParentView;
}

//----------------------------------------------------------------------------------------
// initWithContentRect
//----------------------------------------------------------------------------------------
- (NSArray*)children
{
	return nil;
}

@end
