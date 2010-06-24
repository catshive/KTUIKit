//
//  KTSharedContextOpenGLView.m
//  KTUIKit
//
//  Created by Cathy on 23/10/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTSharedContextOpenGLView.h"


static NSOpenGLContext * gSharedOpenGLContext = nil;

@implementation KTSharedContextOpenGLView
+ (NSOpenGLPixelFormat*)defaultPixelFormat
{
	NSOpenGLPixelFormatAttribute anAttributes[] = {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAColorSize, (NSOpenGLPixelFormatAttribute)32,
		(NSOpenGLPixelFormatAttribute)0
	};
    return [[(NSOpenGLPixelFormat *)[NSOpenGLPixelFormat alloc] initWithAttributes:anAttributes] autorelease];
}


+ (NSOpenGLContext*)_createNewNSOpenGLContextWithSharedContext
{

	if(!gSharedOpenGLContext)
	{
		gSharedOpenGLContext = [[NSOpenGLContext alloc] initWithFormat:[[self class] defaultPixelFormat] shareContext:nil];
		NSLog(@"ORIGINAL cgl share context: %p", [gSharedOpenGLContext CGLContextObj]);
		return gSharedOpenGLContext;
	}
	else 
	{
//		CGLGetPixelFormat(gSharedOpenGLContext);
		return [[NSOpenGLContext alloc] initWithFormat:[[self class] defaultPixelFormat] shareContext:gSharedOpenGLContext];
		NSLog(@"cgl share context: %p", [gSharedOpenGLContext CGLContextObj]);
	}
}


- (id)initWithFrame:(NSRect)theFrame pixelFormat:(NSOpenGLPixelFormat*)theFormat
{
    self = [super initWithFrame:theFrame];
    if (self != nil) {
        _pixelFormat   = [theFormat retain];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_surfaceNeedsUpdate:) name:NSViewGlobalFrameDidChangeNotification object:self];
    return self;
}

- (void)dealloc
{   
	// get rid of the context and pixel format
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewGlobalFrameDidChangeNotification object:self];
    [self clearGLContext];
    [_pixelFormat release];
    
    [super dealloc];
}

- (void)setOpenGLContext:(NSOpenGLContext*)context
{
    [self clearGLContext];
    _openGLContext = [context retain];
}



- (NSOpenGLContext*)openGLContext
{
     if (_openGLContext == NULL) {
		_openGLContext = [[self class] _createNewNSOpenGLContextWithSharedContext];
        [_openGLContext makeCurrentContext];
		[self prepareOpenGL]; // call to initialize OpenGL state here
    }
    return _openGLContext;
}



- (void)clearGLContext
{
    if (_openGLContext != nil) {
        if ([_openGLContext view] == self) {
            [_openGLContext clearDrawable];
        }
        [_openGLContext release];
        _openGLContext = nil;
    }
}

- (void)prepareOpenGL
{
	// for overriding to initialize OpenGL state, occurs after context creation
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)setPixelFormat:(NSOpenGLPixelFormat*)pixelFormat
{
    [_pixelFormat release];
    _pixelFormat = [pixelFormat retain];
}

- (NSOpenGLPixelFormat*)pixelFormat
{
    return _pixelFormat;
}

- (void)lockFocus
{
    // get context. will create if we don't have one yet
    NSOpenGLContext* context = [self openGLContext];
    
    // make sure we are ready to draw
    [super lockFocus];

    // when we are about to draw, make sure we are linked to the view
    if ([context view] != self) {
        [context setView:self];
    }

    // make us the current OpenGL context
    [context makeCurrentContext];
}


- (void)reshape
{
}

- (void)update
{
    if ([_openGLContext view] == self) {
        [_openGLContext update];
    }
}

- (void) _surfaceNeedsUpdate:(NSNotification*)notification
{
	[self reshape];
    [self update];
}

- (void)encodeWithCoder:(NSCoder *)coder 
{

    [super encodeWithCoder:coder];
    if (![coder allowsKeyedCoding]) {
		[coder encodeValuesOfObjCTypes:"@iii", &_pixelFormat];
    } else {
		[coder encodeObject:_pixelFormat forKey:@"NSPixelFormat"];
    }
}

- (id)initWithCoder:(NSCoder *)coder 
{

    self = [super initWithCoder:coder];

    if (![coder allowsKeyedCoding]) {
		[coder decodeValuesOfObjCTypes:"@iii", &_pixelFormat];
    } else {
		_pixelFormat = [[coder decodeObjectForKey:@"NSPixelFormat"] retain];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_surfaceNeedsUpdate:) name:NSViewGlobalFrameDidChangeNotification object:self];
    
    return self;
}

@end
