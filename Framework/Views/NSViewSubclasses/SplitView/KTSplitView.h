//
//  KTSplitView.h
//  KTUIKit
//
//  Created by Cathy on 30/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTView.h"


@class KTSplitView;

@protocol KTSplitView
- (void)layoutViews;
- (void)resetResizeInformation;
@end

@protocol KTSplitViewDelegate <NSObject>
@optional
- (void)splitViewDivderAnimationDidEnd:(KTSplitView*)theSplitView;
- (void)dividerPositionDidChangeForSplitView:(KTSplitView*)theSplitView;
@end
//animationDidEndForSplitView
typedef enum
{
	KTSplitViewResizeBehavior_MaintainProportions = 0,
	KTSplitViewResizeBehavior_MaintainFirstViewSize,
	KTSplitViewResizeBehavior_MaintainSecondViewSize,
	
}KTSplitViewResizeBehavior;

typedef enum
{	
	KTSplitViewDividerOrientation_NoSet = 0,
	KTSplitViewDividerOrientation_Horizontal,
	KTSplitViewDividerOrientation_Vertical
	
}KTSplitViewDividerOrientation;

typedef enum
{
	KTSplitViewFocusedViewFlag_Unknown = 0,
	KTSplitViewFocusedViewFlag_FirstView = 1,
	KTSplitViewFocusedViewFlag_SecondView = 2
	
}KTSplitViewFocusedViewFlag;

@class KTSplitViewDivider;

@interface KTSplitView : KTView <KTSplitView
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
, NSAnimationDelegate
#endif
>
{
	@private
	id<KTSplitViewDelegate>				wDelegate;
	
	KTSplitViewDivider *				mDivider;
	KTView *							mFirstView;
	KTView *							mSecondView;
	
	KTSplitViewDividerOrientation		mDividerOrientation;
	KTSplitViewResizeBehavior			mResizeBehavior;
	BOOL								mAdjustable;
	BOOL								mUserInteractionEnabled;
	
	KTSplitViewFocusedViewFlag			mPositionRelativeToViewFlag;
	BOOL								mCanSetDividerPosition;
	CGFloat								mDividerPositionToSet;
	BOOL								mResetResizeInformation;
	CGFloat								mResizeInformation;
	CGFloat								mAbsoluteResizeInformation;
	CGFloat								mProportionalResizeInformation;
	NSViewAnimation *					mAnimator;
	
	CGFloat								mPreferredFirstViewMinSize;
	CGFloat								mPreferredSecondViewMinSize;
	CGFloat								mPreferredMaxSize;
	KTSplitViewFocusedViewFlag			mPreferredMaxSizeRelativeView;
}

@property (nonatomic, readwrite, assign) IBOutlet id <KTSplitViewDelegate> delegate;
@property (nonatomic, readwrite, assign) KTSplitViewDividerOrientation dividerOrientation;
@property (nonatomic, readwrite, assign) KTSplitViewResizeBehavior resizeBehavior;
@property (nonatomic, readwrite, assign) BOOL userInteractionEnabled;
@property (nonatomic, readwrite, assign) CGFloat dividerThickness;
@property (nonatomic, readwrite, retain) KTSplitViewDivider * divider;

- (id)initWithFrame:(NSRect)theFrame dividerOrientation:(KTSplitViewDividerOrientation)theDividerOrientation;
- (void)setFirstView:(NSView<KTView>*)theView;
- (void)setSecondView:(NSView<KTView>*)theView;
- (KTView*)firstView;
- (KTView*)secondView;
- (KTView*)firstViewContainer;
- (KTView*)secondViewContainer;
- (void)setFirstView:(NSView<KTView>*)theFirstView secondView:(NSView<KTView>*)theSecondView;
- (void)setPreferredMinSize:(CGFloat)theFloat relativeToView:(KTSplitViewFocusedViewFlag)theView;
- (void)setPreferredMaxSize:(CGFloat)theFloat relativeToView:(KTSplitViewFocusedViewFlag)theView;
- (void)disableMaxSizeConstraint;

- (void)setDividerPosition:(CGFloat)thePosition relativeToView:(KTSplitViewFocusedViewFlag)theView;
- (void)setDividerPosition:(CGFloat)thePosition relativeToView:(KTSplitViewFocusedViewFlag)theView animate:(BOOL)theBool animationDuration:(float)theTimeInSeconds;
- (CGFloat)dividerPositionRelativeToView:(KTSplitViewFocusedViewFlag)theFocusedViewFlag;
- (void)setDividerFillColor:(NSColor*)theColor;
- (void)setDividerBackgroundGradient:(NSGradient*)theGradient;
- (void)setDividerStrokeColor:(NSColor*)theColor;
- (void)setDividerFirstStrokeColor:(NSColor*)theFirstColor secondColor:(NSColor*)theSecondColor;
//- (void)setDivider:(KTSplitViewDivider*)theDivider;

// Called from the divider's mouse handling code
- (CGFloat)dividerPositionForProposedPosition:(CGFloat)thePosition;
- (BOOL)canResizeRelativeToView:(KTSplitViewFocusedViewFlag)theView;
@end
