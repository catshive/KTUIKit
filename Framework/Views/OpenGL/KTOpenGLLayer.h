//
//  KTOpenGLLayer.h
//  KTUIKit
//
//  Created by Cathy on 19/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTViewLayout.h"

@class KTOpenGLView;
@class KTLayoutManager;

@interface KTOpenGLLayer : NSResponder <KTViewLayout> 
{
	@private
		KTLayoutManager *		mLayoutManager;
		NSRect					mFrame;
		CGFloat					mRotation;
		NSPoint					mAnchorPoint;
		CGFloat					mAlpha;
		NSMutableArray *		mSublayers;
		KTOpenGLLayer *			mSuperlayer;
		KTOpenGLView *			wView;
		BOOL					mDrawDebuggingRects;
}

@property (readwrite, assign) NSRect frame;
@property (readwrite, assign) CGFloat rotation;
@property (readwrite, assign) NSPoint anchorPoint;
@property (readwrite, assign) CGFloat alpha;
@property (readwrite, retain) KTLayoutManager * viewLayoutManager;
@property (readwrite, assign) KTOpenGLView * view;
@property (readwrite, assign) KTOpenGLLayer * superlayer;
@property (readwrite, retain) NSMutableArray * sublayers;
@property (readwrite, assign) BOOL	drawDebuggingRects;


- (id)initWithFrame:(NSRect)theFrame;
- (NSRect)bounds;
- (NSPoint)position;
- (void)notifiyLayersViewDidReshape;
- (void)viewDidReshape;

- (void)addSublayer:(KTOpenGLLayer*)theSublayer;
- (void)removeSublayer:(KTOpenGLLayer*)theSublayer;


- (void)drawLayers;
- (void)draw;
- (void)drawOverlays;
- (void)setNeedsDisplay:(BOOL)theBool;
- (void)display;
- (void)viewWillMoveToWindow:(NSWindow*)theWindow;

- (KTOpenGLLayer*)hitTest:(NSPoint)thePoint;
- (void)updateTrackingAreas;

// converting coordinates
- (NSRect)convertRect:(NSRect)theRect fromLayer:(KTOpenGLLayer*)theLayer;
- (NSPoint)convertPoint:(NSPoint)thePoint fromLayer:(KTOpenGLLayer*)theLayer;
- (NSRect)convertRectToViewRect:(NSRect)theRect;
- (NSPoint)convertPointToViewPoint:(NSPoint)thePoint;
- (NSPoint)convertViewPointToLayerPoint:(NSPoint)thePoint;

@end
