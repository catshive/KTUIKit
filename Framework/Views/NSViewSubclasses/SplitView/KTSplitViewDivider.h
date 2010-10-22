//
//  KTSplitViewDivider.h
//  KTUIKit
//
//  Created by Cathy on 30/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTView.h"

@class KTSplitView;

@interface KTSplitViewDivider : KTView 
{
	KTSplitView *		wSplitView;
	BOOL				mIsInDrag;
	NSTrackingArea *	mTrackingArea;
	NSCursor *			mCurrentCursor;
	CGSize				mInitialMouseOffset;
}
@property (nonatomic, readwrite, assign) KTSplitView * splitView;
@property (nonatomic, readonly) BOOL isInDrag;
- (id)initWithSplitView:(KTSplitView*)theSplitView;

- (NSCursor *)cursorForCurrentPosition;
@end
