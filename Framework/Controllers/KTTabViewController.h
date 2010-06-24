//
//  KTTabViewController.h
//  KTUIKit
//
//  Created by Cathy on 18/03/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTViewController.h"

@class KTView;
@class KTTabItem;

@interface KTTabViewController : KTViewController 
{
	@private
	KTView *				wContentView;
	NSArrayController *		mTabItemArrayController;
	KTTabItem *				wCurrentSelectedTab;
	BOOL					mReleaseViewControllersWhenNotSeletcted;
	BOOL					mShouldResizeTabViews;
	id						wDelegate;
}

@property (nonatomic, readonly) NSArrayController * tabItemArrayController;
@property (nonatomic, readwrite, assign) BOOL releaseViewControllersWhenNotSeletcted;
@property (nonatomic, readwrite, assign) BOOL shouldResizeTabViews;
@property (nonatomic, readwrite, assign) id delegate;


// adding/removing/getting tabs
- (void)addTabItem:(KTTabItem*)theTabItem;
- (void)addTabItem:(KTTabItem *)theTabItem select:(BOOL)theBool;
- (void)removeTabItem:(KTTabItem*)theTabItem;
- (void)insertTabItem:(KTTabItem*)theTabItem atIndex:(NSInteger)theIndex;
- (NSArray*)tabItems;
- (KTTabItem*)tabItemForIdentifier:(id)theIdentifier;
- (KTTabItem*)tabItemForViewController:(KTViewController*)theViewController;
- (KTTabItem*)tabItemForIndex:(NSInteger)theIndex;

// selection
- (KTTabItem*)selectedTabItem;
- (NSInteger)selectedTabIndex;
- (void)selectTabAtIndex:(NSInteger)theTabIndex;
- (void)selectTabItem:(KTTabItem*)theTabItem;
- (BOOL)canSelectNextTabItem;
- (BOOL)canSelectPreviousTabItem;
- (void)selectNextTabItem;
- (void)selectPreviousTabItem;
@end