//
//  KTControl.h
//  KTUIKit
//
//  Created by Cathy on 28/10/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTViewLayout.h"

@class KTLayoutManager;

@interface KTControl : NSControl <KTViewLayout>
{
	KTLayoutManager *		mLayoutManager;	
}

@end
