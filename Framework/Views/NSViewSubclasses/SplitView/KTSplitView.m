//
//  KTSplitView.m
//  KTUIKit
//
//  Created by Cathy on 30/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTSplitView.h"
#import "KTSplitViewDivider.h"



@interface KTSplitView ()
@property (readwrite, nonatomic, assign) CGFloat preferredFirstViewMinSize;
@property (readwrite, nonatomic, assign) CGFloat preferredSecondViewMinSize;
@property (readwrite, nonatomic, assign) CGFloat preferredMaxSize;
@property (readwrite, nonatomic, assign) KTSplitViewFocusedViewFlag preferredMaxSizeRelativeView;

@end

@interface KTSplitView (Private)
- (void)animateDividerToPosition:(float)thePosition time:(float)theTimeInSeconds;
//- (KTView*)firstViewContainer;
//- (KTView*)secondViewContainer;
@end

@implementation KTSplitView
//=========================================================== 
// - synths
//===========================================================
@synthesize delegate = wDelegate;
@synthesize dividerOrientation = mDividerOrientation;
@synthesize resizeBehavior = mResizeBehavior;
@synthesize userInteractionEnabled = mUserInteractionEnabled;
@synthesize divider = mDivider;

@synthesize	preferredFirstViewMinSize = mPreferredFirstViewMinSize;
@synthesize	preferredSecondViewMinSize = mPreferredSecondViewMinSize;
@synthesize	preferredMaxSize = mPreferredMaxSize;
@synthesize	preferredMaxSizeRelativeView = mPreferredMaxSizeRelativeView;

//=========================================================== 
// - initWithFrame:dividerOrientation
//===========================================================
- (id)initWithFrame:(NSRect)theFrame dividerOrientation:(KTSplitViewDividerOrientation)theDividerOrientation
{
	if(self = [self initWithFrame:theFrame])
	{
		[self setDividerOrientation:theDividerOrientation];
	}
	return self;
}


//=========================================================== 
// - initWithFrame
//===========================================================
- (id)initWithFrame:(NSRect)theFrame
{
//	NSLog(@"Split View initWithFrame:%@", NSStringFromRect(theFrame));
	if(self = [super initWithFrame:theFrame])
	{
		mFirstView = [[KTView alloc] initWithFrame:NSZeroRect];
		[self addSubview:mFirstView];
		mSecondView = [[KTView alloc] initWithFrame:NSZeroRect];
		[self addSubview:mSecondView];
		mDivider = [[KTSplitViewDivider alloc] initWithSplitView:self];
		[self addSubview:mDivider];
		
		//	This flag won't change until the first time the split view has a width/height.
		//	If the position is set before the flag changes, we'll cache the value and apply it later.
		mCanSetDividerPosition = NO; 
		[self setUserInteractionEnabled:YES];
		
		[mDivider setLabel:@"KTSplitView Divider view"];
		[mFirstView setLabel:@"KTSplitView first view"];
		[mSecondView setLabel:@"KTSplitView second view"];
		
		mPreferredMaxSize = CGFLOAT_MAX;
		mPreferredMaxSizeRelativeView = KTSplitViewFocusedViewFlag_Unknown;
	}
	return self;
}


//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{

	if (![super initWithCoder:theCoder])
		return nil;

	mCanSetDividerPosition = NO; 
	mFirstView = [[theCoder decodeObjectForKey:@"firstView"] retain];
	if(mFirstView)
		[mFirstView removeFromSuperview];
	else
		mFirstView = [[KTView alloc] initWithFrame:NSZeroRect];
	mSecondView = [[theCoder decodeObjectForKey:@"secondView"] retain];
	if(mSecondView)
		[mSecondView removeFromSuperview];
	else
		mSecondView = [[KTView alloc] initWithFrame:NSZeroRect];
	mDivider = [[theCoder decodeObjectForKey:@"divider"] retain];
	if(mDivider)
	{
		[mDivider setSplitView:self];
		[mDivider removeFromSuperview];
	}
	else
		mDivider = [[KTSplitViewDivider alloc] initWithSplitView:self];
	
	[self addSubview:mFirstView];
	[self addSubview:mSecondView];
	[self addSubview:mDivider];
	NSNumber * aDividerOrientationAsNSNumber = [theCoder decodeObjectForKey:@"dividerOrienation"];
	if(aDividerOrientationAsNSNumber)
		[self setDividerOrientation:[aDividerOrientationAsNSNumber intValue]];
	else
		[self setDividerOrientation:KTSplitViewDividerOrientation_Vertical];
	NSNumber * aUserInteractionEnabledAsNSNumber = [theCoder decodeObjectForKey:@"userInteractionEnabled"];
	if(aUserInteractionEnabledAsNSNumber)
		[self setUserInteractionEnabled:[aUserInteractionEnabledAsNSNumber boolValue]];
	else
		[self setUserInteractionEnabled:YES];
		
	[mDivider setLabel:@"KTSplitView Divider view"];
	[mFirstView setLabel:@"KTSplitView first view"];
	[mSecondView setLabel:@"KTSplitView second view"];
		
	mPreferredMaxSize = CGFLOAT_MAX;
	mPreferredMaxSizeRelativeView = KTSplitViewFocusedViewFlag_Unknown;
	
	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	[theCoder encodeObject:mFirstView forKey:@"firstView"];
	[theCoder encodeObject:mSecondView forKey:@"secondView"];
	[theCoder encodeObject:mDivider forKey:@"divider"];
	[theCoder encodeObject:[NSNumber numberWithBool:[self userInteractionEnabled]] forKey:@"userInteractionEnabled"];
	[theCoder encodeObject:[NSNumber numberWithInt:[self dividerOrientation]] forKey:@"dividerOrientation"];
}



//=========================================================== 
// - dealloc
//===========================================================
- (void)dealloc
{
	[mFirstView release];
	[mSecondView release];
	[mDivider release];
	[mAnimator setDelegate:nil];
	[mAnimator release];
	[super dealloc];
}

//=========================================================== 
// - viewWillMoveToSuperview
//===========================================================
- (void)viewWillMoveToSuperview:(NSView *)theNewSuperview
{
	if([mAnimator isAnimating])
		[mAnimator stopAnimation];
}


#pragma mark -
#pragma mark Resizing 
//=========================================================== 
// - setFrameSize
//===========================================================
- (void)setFrame:(NSRect)theFrame
{
	[super setFrame:theFrame];
}

//=========================================================== 
// - setFrameSize
//===========================================================
- (void)setFrameSize:(NSSize)theNewFrameSize
{
//	NSLog(@"%@ setFrame", self);
	// when the split view's frame is set, we need to 
	// check the desired resizing behavior to determine where to position the divider
	// after the frame is set, we'll refresh our layout so that all the views are sized/positioned correctly

	// Save old dimensions first
	NSRect anOldViewBounds = [self bounds];
	NSRect anOldDividerFrame = [[self divider] frame];
	
	// We need to have a width and height to do this
	if(		theNewFrameSize.width <= 0
		||	theNewFrameSize.height <= 0 
		||	anOldViewBounds.size.width <= 0
		||	anOldViewBounds.size.height <= 0)
	{
		[super setFrameSize:theNewFrameSize];
		return;
	}
	
	// Constraining the divider position calls [self bounds], so we need to set the new size here.
	[super setFrameSize:theNewFrameSize];
	
	// if we've been waiting to set the divider position, do it now
	if(	mCanSetDividerPosition == NO )
	{
		mCanSetDividerPosition = YES;
		[self setDividerPosition:mDividerPositionToSet relativeToView:mPositionRelativeToViewFlag];
		anOldDividerFrame = [[self divider] frame];
	}
	

	// Now check the resize behavior and the orientation of the divider to set the divider's position within our new frame
	switch([self resizeBehavior])
	{
		case KTSplitViewResizeBehavior_MaintainProportions:
		{
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			{
				// if this is the first resize after the divider last moved, we need to cache the information
				// we need to calculate the position of the divider during a live resize
				if(mResetResizeInformation == YES)
				{	
					mResizeInformation = floor(((anOldDividerFrame.origin.y+anOldDividerFrame.size.height*.5) / anOldViewBounds.size.height) * 100.0);
					mResetResizeInformation = NO;
				}
				CGFloat aDividerPosition = ((theNewFrameSize.height*mResizeInformation)/100.0) - (anOldDividerFrame.size.height*.5);
				aDividerPosition = floor(aDividerPosition);
				[[self divider] setFrame:NSMakeRect(anOldDividerFrame.origin.x, aDividerPosition, theNewFrameSize.width, anOldDividerFrame.size.height)];
			}
			else
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = floor(((anOldDividerFrame.origin.x+anOldDividerFrame.size.width*.5) / anOldViewBounds.size.width) * 100.0);
					mResetResizeInformation = NO;
				}
				CGFloat aDividerPosition = ((theNewFrameSize.width*mResizeInformation)/100.0) - (anOldDividerFrame.size.width*.5);
				aDividerPosition = floor(aDividerPosition);
				[[self divider]  setFrame:NSMakeRect(aDividerPosition, anOldDividerFrame.origin.y, anOldDividerFrame.size.width, theNewFrameSize.height)];
			}
		}
		break;
		
		
		case KTSplitViewResizeBehavior_MaintainFirstViewSize:
		{
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = [[self firstViewContainer] frame].size.height;
					mResetResizeInformation = NO;
				}
				CGFloat aNewYOrdinate = theNewFrameSize.height-mResizeInformation;
				CGFloat aConstrainedYOrdinate = [self dividerPositionForProposedPosition:aNewYOrdinate];
				mResizeInformation = theNewFrameSize.height - aConstrainedYOrdinate;
				[[self divider] setFrame:NSMakeRect(anOldDividerFrame.origin.x, aConstrainedYOrdinate, theNewFrameSize.width, anOldDividerFrame.size.height)];
			}
			else
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = NSMaxX([[self firstViewContainer] frame]) /*[[self firstViewContainer] frame].origin.x+[[self firstViewContainer]  frame].size.width*/;
					mResetResizeInformation = NO;
				}
				// We override the resize information with the constrain, losing the original size. If you don't want to lose it try constraining a local var only. However this behaviour would be very different, so try it out.
				mResizeInformation = [self dividerPositionForProposedPosition:mResizeInformation];
				[[self divider] setFrame:NSMakeRect(mResizeInformation, anOldDividerFrame.origin.y, anOldDividerFrame.size.width, theNewFrameSize.height)];
			}
		}		
		break;
		
		case KTSplitViewResizeBehavior_MaintainSecondViewSize:
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = [[self secondViewContainer] frame].size.height;
					mResetResizeInformation = NO;
				}
				mResizeInformation = [self dividerPositionForProposedPosition:mResizeInformation];
				[[self divider] setFrame:NSMakeRect(anOldDividerFrame.origin.x, mResizeInformation, theNewFrameSize.width, anOldDividerFrame.size.height)];
			}
			else
			{
				if(mResetResizeInformation == YES)
				{
					mResizeInformation = [[self secondViewContainer] frame].size.width;
					mResetResizeInformation = NO;
				}
				CGFloat anXOrdinate = theNewFrameSize.width - mResizeInformation - NSWidth(anOldDividerFrame);
				CGFloat aConstrainedXOrdinate = [self dividerPositionForProposedPosition:anXOrdinate];
				mResizeInformation = theNewFrameSize.width - aConstrainedXOrdinate - NSWidth(anOldDividerFrame);
				[[self divider] setFrame:NSMakeRect(aConstrainedXOrdinate, anOldDividerFrame.origin.y, anOldDividerFrame.size.width, theNewFrameSize.height)];
			}		
		
		break;
		
		default:
		break;
	}
}



//=========================================================== 
// - layoutViews
//===========================================================
- (void)layoutViews
{
	NSRect aSplitViewBounds = [self bounds];
	
	if(		aSplitViewBounds.size.width < 0
		||	aSplitViewBounds.size.height < 0)
			return;
			

	NSRect aDividerFrame = [[self divider] frame];
	NSRect aFirstViewFrame;
	NSRect aSecondViewFrame;
	if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
	{
				
		aFirstViewFrame = NSMakeRect(aSplitViewBounds.origin.x,
									 aDividerFrame.origin.y + aDividerFrame.size.height,
									 aSplitViewBounds.size.width,
									 aSplitViewBounds.size.height - NSMaxY(aDividerFrame));
		
		
		aSecondViewFrame = NSMakeRect(aSplitViewBounds.origin.x,
									  aSplitViewBounds.origin.y,
									  aSplitViewBounds.size.width,
									  aDividerFrame.origin.y);
	
	}
	else
	{
		CGFloat aHeight = aSplitViewBounds.size.height;
		CGFloat aWidth = aDividerFrame.origin.x;

		
		aFirstViewFrame = NSMakeRect(aSplitViewBounds.origin.x,
									 aSplitViewBounds.origin.y,
									 aWidth,
									 aHeight);
										 
		aSecondViewFrame = NSMakeRect(aWidth+aDividerFrame.size.width,
									  aSplitViewBounds.origin.y,
									  aSplitViewBounds.size.width - NSMaxX(aDividerFrame),
									  aSplitViewBounds.size.height);
	}
	
	if(aFirstViewFrame.size.width < 0)
		aFirstViewFrame.size.width = 0;
	if(aFirstViewFrame.size.height < 0)
		aFirstViewFrame.size.height = 0;
	if(aSecondViewFrame.size.height < 0)
		aSecondViewFrame.size.height = 0;
	if(aSecondViewFrame.size.width < 0)
		aSecondViewFrame.size.width = 0;
		
	if(NSEqualRects(aFirstViewFrame, [[self firstViewContainer] frame]) == NO)
		[[self firstViewContainer] setFrame:aFirstViewFrame];
	if(NSEqualRects(aSecondViewFrame, [[self secondViewContainer] frame]) == NO)
		[[self secondViewContainer] setFrame:aSecondViewFrame];
}


//=========================================================== 
// - resetResizeInformation
//===========================================================
- (void)resetResizeInformation
{
	mResetResizeInformation = YES;
	mResizeInformation = 0;
}

#pragma mark -
#pragma mark Constraints

- (void)setPreferredMinSize:(CGFloat)theFloat relativeToView:(KTSplitViewFocusedViewFlag)theView;
{
	if (theView == KTSplitViewFocusedViewFlag_FirstView) {
		[self setPreferredFirstViewMinSize:theFloat];
	} else if (theView == KTSplitViewFocusedViewFlag_SecondView) {
		[self setPreferredSecondViewMinSize:theFloat];		
	}
}

- (void)setPreferredMaxSize:(CGFloat)theFloat relativeToView:(KTSplitViewFocusedViewFlag)theView;
{
	[self setPreferredMaxSize:theFloat];
	[self setPreferredMaxSizeRelativeView:theView];		
}

- (void)disableMaxSizeConstraint;
{
	[self setPreferredMaxSize:CGFLOAT_MAX];
	[self setPreferredMaxSizeRelativeView:KTSplitViewFocusedViewFlag_Unknown];
}

#pragma mark -
#pragma mark Divider Position

// Note that if the [self preferredMaxSizeRelativeView] == KTSplitViewFocusedViewFlag_Unknown this returns CGFLOAT_MAX
- (CGFloat)_calculatedMaxSize;
{
	CGFloat anActualMaxSize = [self preferredMaxSize];
	if ([self preferredMaxSizeRelativeView] == KTSplitViewFocusedViewFlag_FirstView) {
		// Ensure the max size never smaller than the min size.
		anActualMaxSize = MAX([self preferredFirstViewMinSize], [self preferredMaxSize]);
	} else if ([self preferredMaxSizeRelativeView] == KTSplitViewFocusedViewFlag_SecondView) {
		anActualMaxSize = MAX([self preferredSecondViewMinSize], [self preferredMaxSize]);
	}
	return anActualMaxSize;
}

// |thePosition| is an x or y value
// if the [self preferredMaxSizeRelativeView] == KTSplitViewFocusedViewFlag_Unknown the max constraint is ignored.
- (CGFloat)dividerPositionForProposedPosition:(CGFloat)thePosition;
{
	CGFloat aNewPosition = thePosition;
	if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal) {

		// Here first and second are swapped (w.r.t the vertical case) as first is laid out above second.
		aNewPosition = MAX(aNewPosition, NSMinY([self bounds]) + [self preferredSecondViewMinSize]);
		aNewPosition = MIN(aNewPosition, NSMaxY([self bounds]) - [self preferredFirstViewMinSize]);
		
		if ([self preferredMaxSizeRelativeView] == KTSplitViewFocusedViewFlag_FirstView) {
			aNewPosition = MIN(aNewPosition, NSMaxY([self bounds]) - [self _calculatedMaxSize]);
		} else if ([self preferredMaxSizeRelativeView] == KTSplitViewFocusedViewFlag_SecondView) {
			aNewPosition = MAX(aNewPosition, NSMinY([self bounds]) + [self _calculatedMaxSize]);
		}
		
		// Force |aNewPosition| within the bounds of the split view
		aNewPosition = MIN(MAX(aNewPosition, 0.0), NSMaxY([self bounds]));
	} else {
		// First limit the position such that the views cannot be shrunk further than their mins.
		aNewPosition = MAX(aNewPosition, NSMinX([self bounds]) + [self preferredFirstViewMinSize]);
		aNewPosition = MIN(aNewPosition, NSMaxX([self bounds]) - [self preferredSecondViewMinSize]);
		
		if ([self preferredMaxSizeRelativeView] == KTSplitViewFocusedViewFlag_FirstView) {
			aNewPosition = MIN(aNewPosition, NSMinX([self bounds]) + [self _calculatedMaxSize]);
		} else if ([self preferredMaxSizeRelativeView] == KTSplitViewFocusedViewFlag_SecondView) {
			aNewPosition = MAX(aNewPosition, NSMaxX([self bounds]) - [self _calculatedMaxSize]);
		}
		
		// Force |aNewPosition| within the bounds of the split view
		aNewPosition = MIN(MAX(aNewPosition, 0.0), NSMaxX([self bounds]));
	}
	return aNewPosition;
}

/*
	The divider position must be set with a "focused view". 
	This allows users to specify a divider position relative to any side of the split view
	We'll take care of calculating what that position is really
*/

//=========================================================== 
// - setDividerPosition:relativeToView
//===========================================================
- (void)setDividerPosition:(CGFloat)thePosition relativeToView:(KTSplitViewFocusedViewFlag)theView
{
	if(mCanSetDividerPosition == NO) // we can't set the divider's position until the split view has a width & height
	{
		// save the position and the relative view so that we can set it 
		// when we are certain that the split view has dimensions
		mDividerPositionToSet = thePosition;
		mPositionRelativeToViewFlag = theView;
	}	
	else // we have a width & height, so we are free to update the divider's position
	{
		NSRect aDividerFrame = [[self divider] frame];
		if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
		{
			if(theView == KTSplitViewFocusedViewFlag_FirstView)
				thePosition = [self bounds].size.height - thePosition;

			thePosition = [self dividerPositionForProposedPosition:thePosition];
			[[self divider] setFrame:NSMakeRect(aDividerFrame.origin.x, thePosition, aDividerFrame.size.width, aDividerFrame.size.height)];
		}
		else
		{
			if(theView == KTSplitViewFocusedViewFlag_SecondView)
				thePosition = [self bounds].size.width - thePosition;

			thePosition = [self dividerPositionForProposedPosition:thePosition];
			[[self divider] setFrame:NSMakeRect(thePosition, aDividerFrame.origin.y, aDividerFrame.size.width, aDividerFrame.size.height)];
		}
		
		[self resetResizeInformation];
	}
}


//=============================================================== 
// - setDividerPosition:relativeToView:animate:animationDuration
//===============================================================
- (void)setDividerPosition:(CGFloat)thePosition relativeToView:(KTSplitViewFocusedViewFlag)theView animate:(BOOL)theBool animationDuration:(float)theTimeInSeconds;
{
	if(theBool == NO)
		[self setDividerPosition:thePosition relativeToView:theView];
	else
	{
		if(mCanSetDividerPosition == NO) // we can't set the divider's position until the split view has a width & height
		{
			// save the position and the relative view so that we can set it 
			// when we are certain that the split view has dimensions
			mDividerPositionToSet = thePosition;
			mPositionRelativeToViewFlag = theView;
			[self resetResizeInformation];
		}
		else // we have a width & height, so we are free to update the divider's position
		{	
			if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			{
				if(theView == KTSplitViewFocusedViewFlag_FirstView)
					thePosition = [self bounds].size.height - thePosition;
					
				[self animateDividerToPosition:thePosition time:theTimeInSeconds];
			}
			else
			{
				if(theView == KTSplitViewFocusedViewFlag_SecondView)
					thePosition = [self bounds].size.width - thePosition;
				[self  animateDividerToPosition:thePosition time:theTimeInSeconds];
			}
		}
	}
}


//=============================================================== 
// - dividerPositionRelativeToView
//===============================================================
- (CGFloat)dividerPositionRelativeToView:(KTSplitViewFocusedViewFlag)theFocusedViewFlag
{
	float aDividerPosition = 0;
	
	if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
	{
		if(theFocusedViewFlag == KTSplitViewFocusedViewFlag_FirstView)
			aDividerPosition = [self bounds].size.height - [[self divider]  frame].origin.y;
		else if (theFocusedViewFlag == KTSplitViewFocusedViewFlag_SecondView)
			aDividerPosition = [[self divider] frame].origin.y;
	}
	else
	{
		if(theFocusedViewFlag == KTSplitViewFocusedViewFlag_FirstView)
			aDividerPosition = [[self divider]  frame].origin.x;
		else if (theFocusedViewFlag == KTSplitViewFocusedViewFlag_SecondView)
			aDividerPosition = [self bounds].size.width - [[self divider]  frame].origin.x;
	}
	return aDividerPosition;	
}


//=========================================================== 
// - animateDividerToPosition:time
//===========================================================
- (void)animateDividerToPosition:(float)thePosition time:(float)theTimeInSeconds
{		
	if([mAnimator isAnimating])
	{
		[mAnimator stopAnimation];
		[mAnimator setDelegate:nil];
		[mAnimator release];
		mAnimator = nil;
		[self resetResizeInformation];
	}
	if(mAnimator == nil)
	{
		CGFloat aConstrainedOrdinate = [self dividerPositionForProposedPosition:thePosition];
		
		CGPoint aPositionToSet = NSPointToCGPoint([mDivider frame].origin);
		if([self dividerOrientation] == KTSplitViewDividerOrientation_Horizontal)
			aPositionToSet.y = aConstrainedOrdinate;
		else
			aPositionToSet.x = aConstrainedOrdinate;

		NSRect aNewFrame = [mDivider frame];
		aNewFrame.origin = NSPointFromCGPoint(aPositionToSet);
											
		NSArray * anAnimationArray = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:mDivider, NSViewAnimationTargetKey,
																										 [NSValue valueWithRect:[mDivider frame]], NSViewAnimationStartFrameKey,
																										 [NSValue valueWithRect:aNewFrame], NSViewAnimationEndFrameKey, nil]];
		mAnimator = [[NSViewAnimation alloc] initWithViewAnimations:anAnimationArray];			
		[mAnimator setDelegate:self];																						
		[mAnimator setDuration: theTimeInSeconds];
		[mAnimator setAnimationCurve:NSAnimationEaseInOut];
		[mAnimator setAnimationBlockingMode:NSAnimationNonblocking];
		[mAnimator startAnimation];
	}
}


//=========================================================== 
// - animationDidEnd
//===========================================================
- (void)animationDidEnd:(NSAnimation *)theAnimation
{
	if(theAnimation == mAnimator)
	{
		[mAnimator setDelegate:nil];
		[mAnimator release];
		mAnimator = nil;	
		[self resetResizeInformation];	
		if([[self delegate] respondsToSelector:@selector(splitViewDivderAnimationDidEnd:)])
			[[self delegate] splitViewDivderAnimationDidEnd:self];
	}
}

//=========================================================== 
// - dividerAnimationDidEnd
//===========================================================
- (void)dividerAnimationDidEnd
{
	if([[self delegate] respondsToSelector:@selector(splitViewDivderAnimationDidEnd:)])
		[[self delegate] splitViewDivderAnimationDidEnd:self];
}



#pragma mark -
#pragma mark Building the SplitView

//=========================================================== 
// - setFirstView
//===========================================================
- (void)setFirstView:(NSView<KTView>*)theView
{
	[[self firstViewContainer] setSubviews:[NSArray array]];
	if(theView!=nil)
		[[self firstViewContainer] addSubview:theView];
	[self layoutViews];
	[[[self firstViewContainer] viewLayoutManager] refreshLayout];
}

//=========================================================== 
// - setSecondView
//===========================================================
- (void)setSecondView:(NSView<KTView>*)theView
{
	[[self secondViewContainer] setSubviews:[NSArray array]];
	if(theView!=nil)
		[[self secondViewContainer] addSubview:theView];	
	[self layoutViews];
	[[[self secondViewContainer] viewLayoutManager] refreshLayout];
}

//=========================================================== 
// - setFirstView:secondView:
//===========================================================
- (void)setFirstView:(NSView<KTView>*)theFirstView secondView:(NSView<KTView>*)theSecondView
{
	[self setFirstView:theFirstView];
	[self setSecondView:theSecondView];
	[self layoutViews];
}

- (KTView*)firstViewContainer
{
	return mFirstView;
}

//=========================================================== 
// - firstView
//===========================================================
- (KTView*)firstView
{
	KTView * aViewToReturn = nil;
	if([[mFirstView subviews] count] > 0)
		aViewToReturn = [[mFirstView subviews] objectAtIndex:0];
	return aViewToReturn;
}



- (KTView*)secondViewContainer
{
	return mSecondView;
}

//=========================================================== 
// - secondView
//===========================================================
- (KTView*)secondView
{
	KTView * aViewToReturn = nil;
	if([[mSecondView subviews] count] > 0)
		aViewToReturn = [[mSecondView subviews] objectAtIndex:0];
	return aViewToReturn;
}

//=========================================================== 
// - setDivider:
//===========================================================
- (void)setDivider:(KTSplitViewDivider*)theDivider
{
	if(theDivider != mDivider)
	{
		[theDivider retain];
		[mDivider removeFromSuperview];
		[mDivider release];
		mDivider = theDivider;
		[self addSubview:mDivider];
	}
}



#pragma mark -
#pragma mark Configuring the Divider
//=========================================================== 
// - setDividerOrientation
//===========================================================
- (void)setDividerOrientation:(KTSplitViewDividerOrientation)theOrientation
{
	CGFloat aCurrentDividerThickness = [self dividerThickness];
	if(mDividerOrientation != theOrientation)
	{
		mDividerOrientation = theOrientation;
		if(mDividerOrientation==KTSplitViewDividerOrientation_Horizontal)
		{
			NSRect aFrame = NSMakeRect(0, [self frame].size.height*.5, [self frame].size.width, aCurrentDividerThickness);
			[[self divider] setFrame:aFrame];
			//[self setDividerPosition:[self frame].size.height*.5 relativeToView:KTSplitViewFocusedViewFlag_FirstView];
		}
		else if(mDividerOrientation==KTSplitViewDividerOrientation_Vertical)
		{
			NSRect aFrame = NSMakeRect([self frame].size.width*.5, 0, aCurrentDividerThickness, [self frame].size.height);
			[[self divider] setFrame:aFrame];
			//[self setDividerPosition:[self frame].size.width*.5 relativeToView:KTSplitViewFocusedViewFlag_FirstView];
		}
		[self resetResizeInformation];
	}
}

//=========================================================== 
// - setResizeBehavior
//===========================================================
- (void)setResizeBehavior:(KTSplitViewResizeBehavior)theResizeBehavior
{
	mResizeBehavior = theResizeBehavior;
	
	if(theResizeBehavior==KTSplitViewResizeBehavior_MaintainProportions)
	{
		[self resetResizeInformation];
//		[self setNeedsDisplay:YES];
	}
}


//=========================================================== 
// - setDividerThickness
//===========================================================
- (void)setDividerThickness:(CGFloat)theThickness
{
	NSRect aDividerFrame = [mDivider frame];
	if(mDividerOrientation==KTSplitViewDividerOrientation_Horizontal)
		aDividerFrame.size.height = theThickness;
	else
		aDividerFrame.size.width = theThickness;
	[mDivider setFrame:aDividerFrame];	
	[self resetResizeInformation];
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - dividerThickness
//===========================================================
- (CGFloat)dividerThickness
{
	CGFloat aThicknessToReturn = 0;
	if(mDividerOrientation==KTSplitViewDividerOrientation_Horizontal)
		aThicknessToReturn = [mDivider frame].size.height;
	else
		aThicknessToReturn = [mDivider frame].size.width;
	return aThicknessToReturn;
}

//=========================================================== 
// - setDividerFillColor
//===========================================================
- (void)setDividerFillColor:(NSColor*)theColor
{
	[[[self divider] styleManager] setBackgroundColor:theColor];
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setDividerBackgroundGradient
//===========================================================
- (void)setDividerBackgroundGradient:(NSGradient*)theGradient
{
	[[[self divider] styleManager] setBackgroundGradient:theGradient angle:180];	
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setDividerStrokeColor
//===========================================================
- (void)setDividerStrokeColor:(NSColor*)theColor
{
	KTStyleManager * aDividerStyleManager = [mDivider styleManager];
	if(mDividerOrientation == KTSplitViewDividerOrientation_Horizontal)
	{
		[aDividerStyleManager setBorderWidthTop:1 right:0 bottom:1 left:0];
		[aDividerStyleManager setBorderColorTop:theColor right:nil bottom:theColor left:nil];
	}
	else
	{
		[aDividerStyleManager setBorderWidthTop:0 right:1 bottom:0 left:1];
		[aDividerStyleManager setBorderColorTop:nil right:theColor bottom:nil left:theColor];	
	}
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setDividerFirstStrokeColor
//===========================================================
- (void)setDividerFirstStrokeColor:(NSColor*)theFirstColor secondColor:(NSColor*)theSecondColor
{
	KTStyleManager * aDividerStyleManager = [mDivider styleManager];
	if(mDividerOrientation == KTSplitViewDividerOrientation_Horizontal)
	{
		[aDividerStyleManager setBorderWidthTop:1 right:0 bottom:1 left:0];
		[aDividerStyleManager setBorderColorTop:theFirstColor right:nil bottom:theSecondColor left:nil];
	}
	else
	{
		[aDividerStyleManager setBorderWidthTop:0 right:1 bottom:0 left:1];
		[aDividerStyleManager setBorderColorTop:nil right:theFirstColor bottom:nil left:theSecondColor];	
	}
	[self setNeedsDisplay:YES];
}
@end
