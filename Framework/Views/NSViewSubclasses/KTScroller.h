//
//  KTScroller.h
//  KTUIKit
//
//  Created by Jonathan on 11/03/2009.
//  Copyright 2009 espresso served here. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTViewLayout.h"

@class KTLayoutManager;
@interface KTScroller : NSScroller <KTViewLayout> {
	@private
	KTLayoutManager *mLayoutManager;
}

@end
