//
//  KTOpenGLView.h
//  KTUIKit
//
//  Created by Cathy on 16/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <OpenGL/glext.h>

#import "KTSharedContextOpenGLView.h"
#import "KTViewProtocol.h"
#import "KTLayoutManager.h"
#import "KTStyleManager.h"

@class KTOpenGLLayer;
@class KTViewOverlayWindow;

@interface KTOpenGLView : NSOpenGLView <KTView>
{
	KTLayoutManager *			mLayoutManager;
	KTStyleManager *			mStyleManager;
	NSString *					mLabel;
	KTOpenGLLayer *				mOpenGLLayer;
	KTOpenGLLayer *				wCurrentMouseEventHandler;
	KTOpenGLLayer *				wCurrentKeyLayer;
	BOOL						mShouldAcceptFirstResponder;
	BOOL						mOpaque;
	NSMutableArray *			mOverlayWindows;
}

@property (readwrite, retain) KTOpenGLLayer * openGLLayer;
@property (readwrite, assign) BOOL shouldAcceptFirstResponder;
@property (nonatomic, readwrite, assign) BOOL opaque;

+ (NSOpenGLPixelFormat*)defaultPixelFormat;
- (void)drawInContext:(NSOpenGLContext*)theContext;

- (void)addOverlayWindow:(KTViewOverlayWindow*)theOverlayWindow;
- (void)removeOverlayWindow:(KTViewOverlayWindow*)theOverlayWindow;
@end
