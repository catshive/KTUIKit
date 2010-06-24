//
//  KTOpenGLViewIntegration.m
//  KTUIKit
//
//  Created by Cathy on 21/09/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <KTUIKit/KTOpenGLView.h>
#import "KTLayoutManagerInspector.h"
#import "KTStyleInspector.h"

@implementation KTOpenGLView ( KTOpenGLViewIntegration )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];

	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:/* @"MyFirstProperty", @"MySecondProperty",*/ nil]];
}


- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
	// Replace "KTScrollViewIntegrationInspector" with the name of your inspector class.
    [classes addObject:[KTLayoutManagerInspector class]];
	[classes addObject:[KTStyleInspector class]];
}

@end
