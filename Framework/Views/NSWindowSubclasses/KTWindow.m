//
//  KTWindow.m
//  KTUIKit
//
//  Created by Cathy Shive on 11/16/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KTWindow.h"


@implementation KTWindow
- (void)setCanBecomeKeyWindow:(BOOL)theBool
{
	mCanBecomeKeyWindow = theBool;
}

- (BOOL)canBecomeKeyWindow
{
	return mCanBecomeKeyWindow;
}
@end
