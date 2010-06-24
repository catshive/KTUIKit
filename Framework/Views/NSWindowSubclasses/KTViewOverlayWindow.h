//
//  KTViewOverlayWindow.h
//  KTUIKit
//
//  Created by Cathy on 22/09/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTWindow.h"
#import "KTViewLayout.h"

@class KTView;
@class KTLayoutManager;

@interface KTViewOverlayWindow : KTWindow <KTViewLayout>
{
	@private
	KTLayoutManager *		mLayoutManager;
	id<KTViewLayout>		wParentView;
}
- (void)setParentView:(id<KTViewLayout>)theParentView;

@end
