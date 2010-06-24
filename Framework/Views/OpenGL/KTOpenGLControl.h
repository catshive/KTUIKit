//
//  KTOpenGLControl.h
//  KTUIKit
//
//  Created by Cathy on 20/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTOpenGLLayer.h"

@interface KTOpenGLControl : KTOpenGLLayer 
{
	@private
		BOOL		mEnabled;
		BOOL		mHighlighted;
		id			wTarget;
		SEL			wAction;
		CGFloat		mFloatValue;
		NSInteger	mIntValue;
		id			mObjectValue;
}

@property (readwrite, assign) BOOL enabled;
@property (readwrite, assign) BOOL highlighted;
@property (readwrite, assign) id target;
@property (readwrite, assign) SEL action;
@property (readwrite, assign) CGFloat floatValue;
@property (readwrite, assign) NSInteger intValue;
@property (readwrite, retain) id objectValue;

- (void)performAction;

@end
