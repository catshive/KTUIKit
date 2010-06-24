//
//  KTView.m
//  KTUIKit
//
//  Created by Cathy Shive on 05/20/2008.
//
// Copyright (c) Cathy Shive
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "KTUIKit" by Cathy Shive" will do.

#import "KTView.h"

@interface KTView (Private)
- (void)_drawDebugginRect;
@end

@implementation KTView

@synthesize mouseDownCanMoveWindow = mMouseDownCanMoveWindow;
@synthesize opaque = mOpaque;
@synthesize canBecomeKeyView = mCanBecomeKeyView;
@synthesize canBecomeFirstResponder = mCanBecomeFirstResponder;
@synthesize acceptsFirstMouse = mAcceptsFirstMouse;
@synthesize drawAsImage = mDrawAsImage;
@synthesize cachedImage = mCachedImage;
@synthesize drawDebuggingRect = mDrawDebuggingRect;

//=========================================================== 
// - initWithFrame:
//=========================================================== 
- (id)initWithFrame:(NSRect)theFrame
{
	if(![super initWithFrame:theFrame])
		return nil;
	
	// Layout
	KTLayoutManager * aLayoutManger = [[[KTLayoutManager alloc] initWithView:self] autorelease];
	[self setViewLayoutManager:aLayoutManger];
	[self setAutoresizesSubviews:NO];
	
	// Styles
	KTStyleManager * aStyleManager = [[[KTStyleManager alloc] initWithView:self] autorelease];
	[self setStyleManager:aStyleManager];
	
	// For Debugging
	[self setLabel:@"KTView"];
	
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
		KTLayoutManager * aLayoutManager = [theCoder decodeObjectForKey:@"layoutManager"];
		if(aLayoutManager == nil)
			aLayoutManager = [[[KTLayoutManager alloc] initWithView:self] autorelease];
		else
			[aLayoutManager setView:self];
		[self setViewLayoutManager:aLayoutManager];
		[self setAutoresizesSubviews:NO];
		[self setAutoresizingMask:NSViewNotSizable];
		
		KTStyleManager * aStyleManager = [theCoder decodeObjectForKey:@"styleManager"];
		if(aStyleManager == nil)
			aStyleManager = [[[KTStyleManager alloc] initWithView:self] autorelease];
		else
			[aStyleManager setView:self];
		[self setStyleManager:aStyleManager];
		[self setOpaque:NO];
		
		NSString * aLabel = [theCoder decodeObjectForKey:@"label"];
		if(aLabel == nil)
			aLabel = [self description];
		[self setLabel:[theCoder decodeObjectForKey:@"label"]];
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
	[mCachedImage release];
	[super dealloc];
}

//=========================================================== 
// - isOpaque
//=========================================================== 
- (BOOL)isOpaque
{
	return mOpaque;
}

//=========================================================== 
// - canBecomeKeyView
//=========================================================== 
- (BOOL)canBecomeKeyView
{
	return mCanBecomeKeyView;
}

//=========================================================== 
// - canBecomeFirstResponder
//=========================================================== 
- (BOOL)canBecomeFirstResponder
{
	return mCanBecomeFirstResponder;
}


//=========================================================== 
// - mouseDownCanMoveWindow
//=========================================================== 
- (BOOL)mouseDownCanMoveWindow
{
	return mMouseDownCanMoveWindow;
}

//=========================================================== 
// - setMouseDownCanMoveWindow:
//=========================================================== 
- (void)setMouseDownCanMoveWindow:(BOOL)theBool
{
	mMouseDownCanMoveWindow = theBool;
	if(mMouseDownCanMoveWindow == YES)
	{
		if([[self superview] isKindOfClass:[KTView class]])
			[(KTView*)[self superview] setMouseDownCanMoveWindow:YES];
	}
}

//=========================================================== 
// - acceptsFirstMouse
//=========================================================== 
- (BOOL)acceptsFirstMouse
{
	return mAcceptsFirstMouse;
}

//=========================================================== 
// - drawAsImage
//=========================================================== 
- (void)drawAsImage:(BOOL)theBool
{
//	mDrawAsImage = theBool;
//	if(mDrawAsImage)
//	{
//		[self lockFocus];
//		NSBitmapImageRep * aBitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]] autorelease];
//		[self unlockFocus];
//		NSImage * anImage = [[[NSImage alloc] initWithData:[aBitmap TIFFRepresentation]] autorelease];
//		if(mCachedImage!=nil)
//			[mCachedImage release];
//		mCachedImage = [anImage retain];
//	}
//	else
//	{
//		[mCachedImage release];
//		mCachedImage = nil;
//	}
}


#pragma mark -
#pragma mark Drawing
//=========================================================== 
// - drawRect:
//=========================================================== 
- (void)drawRect:(NSRect)theRect
{	
	CGContextRef aContext = [[NSGraphicsContext currentContext] graphicsPort];
	if([self drawDebuggingRect])
		[self _drawDebugginRect];
		
//	if(mDrawAsImage)
//	{
//		[mCachedImage drawInRect:theRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
////		NSLog(@"drawing cached image of view");
//	}
//	else
//	{
		[mStyleManager drawStylesInRect:theRect context:aContext view:self];
		[self drawInContext:aContext];
//	}
}

//=========================================================== 
// - drawInContext:
//=========================================================== 
- (void)drawInContext:(CGContextRef)theContext
{
	// subclasses can override this to do custom drawing over the styles
}


//=========================================================== 
// - _drawDebugginRect:
//=========================================================== 
- (void)_drawDebugginRect
{
	[[NSColor colorWithCalibratedRed:0 green:1 blue:0 alpha:.5] set];
	NSRect anInsetBounds = NSInsetRect([self bounds], 10, 10);
	[NSBezierPath fillRect:anInsetBounds];
	
	NSRect anOriginSquare = NSMakeRect(0, 0, 10, 10);
	[[NSColor colorWithCalibratedRed:1 green:0 blue:0 alpha:.5] set];
	[NSBezierPath fillRect:anOriginSquare];
}


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
}


//=========================================================== 
// - setFrameSize:
//===========================================================
- (void)setFrameSize:(NSSize)theSize
{
	[super setFrameSize:theSize];
	NSArray * aSubviewList = [self children];
	int aSubviewCount = [aSubviewList count];
	int i;
	for(i = 0; i < aSubviewCount; i++)
	{
		NSView * aSubview = [aSubviewList objectAtIndex:i];
		
		// if the subview conforms to the layout protocol, tell its layout
		// manager to refresh its layout
		if( [aSubview conformsToProtocol:@protocol(KTViewLayout)] )
		{
			[[(KTView*)aSubview viewLayoutManager] refreshLayout];
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
	return [super subviews];
}

//=========================================================== 
// - addSubview:
//===========================================================
- (void)addSubview:(NSView*)theView
{
	[super addSubview:theView];
	if(		[theView conformsToProtocol:@protocol(KTViewLayout)] == NO
		&&	[theView autoresizingMask] != NSViewNotSizable)
		[self setAutoresizesSubviews:YES];
	if([theView isKindOfClass:[KTView class]])
	{
		if([theView mouseDownCanMoveWindow])
			[self setMouseDownCanMoveWindow:YES];
	}
}



#pragma mark -
#pragma mark KTStyle protocol
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
