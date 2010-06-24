//
//  KTOpenGLTexture.h
//  KTUIKit
//
//  Created by Cathy on 19/02/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/glu.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>


@interface KTOpenGLTexture : NSObject 
{
	GLuint				mTextureName;
	GLuint				mOriginalPixelsWide;
	GLuint				mOriginalPixelsHigh;
	id					mBitmapSource;
	NSOpenGLContext *	mOpenGLContext;
	BOOL				mHasAlpha;
}

@property (nonatomic, readwrite, retain) id bitmapSource;
@property (nonatomic, readwrite, retain) NSOpenGLContext * openGLContext;


- (void)uploadTextureWithNSImage:(NSImage *)theImage openGLContext:(NSOpenGLContext *)theContext;
- (void)createTextureFromNSBitmapImageRep:(NSBitmapImageRep*)theNSBitmapImageRep openGLContext:(NSOpenGLContext*)theContext;
- (void)drawInRect:(NSRect)theRect alpha:(CGFloat)theAlpha;
- (void)drawInRect:(NSRect)theRect anchorPoint:(NSPoint)theAnchorPoint alpha:(CGFloat)theAlpha;
- (void)deleteTexture;
- (NSSize)size;
- (BOOL)hasAlpha;
- (GLuint)textureName;

@end
