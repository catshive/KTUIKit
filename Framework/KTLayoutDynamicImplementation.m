//
//  KTLayoutDynamicImplementation.m
//  KTUIKit
//
//  Created by Jonathan on 11/03/2009.
//  Copyright 2009 espresso served here. All rights reserved.
//

#import "KTLayoutDynamicImplementation.h"
#import "KTLayoutManager.h"
#import <objc/objc-runtime.h>

NSString *const KTViewLayoutManagerKey = @"viewLayoutManager";

id layoutManagerDynamicMethodIMP(id self, SEL _cmd) {
	Ivar mLayoutManagerAsIvar = class_getInstanceVariable([self class], "mLayoutManager");
	return object_getIvar(self, mLayoutManagerAsIvar);
}

void setLayoutManagerDynamicMethodIMP(id self, SEL _cmd, id layoutManager) {
	Ivar mLayoutManagerAsIvar = class_getInstanceVariable([self class], "mLayoutManager");
	id mLayoutManager = object_getIvar(self, mLayoutManagerAsIvar);
	
	if (mLayoutManager == layoutManager)
		return;
	[mLayoutManager release];
	mLayoutManager = [layoutManager retain];
}

id parentDynamicMethodIMP(id self, SEL _cmd) {
	if([[self superview] conformsToProtocol:@protocol(KTViewLayout)])
		return (id <KTViewLayout> )[self superview];
	return nil;	
}

id childrenDynamicMethodIMP(id self, SEL _cmd) {
	return nil;
}

id initWithFrameDynamicIMP(id self, SEL _cmd, NSRect frame) {
	struct objc_super s = {self, [self superclass]};
	if (self = objc_msgSendSuper(&s, _cmd, frame))
		[self setViewLayoutManager:[[[KTLayoutManager alloc] initWithView:self] autorelease]];
	return self;
}

id initWithCoderDynamicIMP(id self, SEL _cmd, NSCoder *coder) {
	struct objc_super s = {self, [self superclass]};	
	if (self = objc_msgSendSuper(&s, _cmd, coder)) {
		KTLayoutManager * aLayoutManager = [coder decodeObjectForKey:KTViewLayoutManagerKey];
		if(aLayoutManager == nil)
			aLayoutManager = [[[KTLayoutManager alloc] initWithView:self] autorelease];
		else
			[aLayoutManager setView:self];
		[self setViewLayoutManager:aLayoutManager];
	}
	return self;
}

void encodeWithCoderDynamicIMP(id self, SEL _cmd, NSCoder *coder) {
	struct objc_super s = {self, [self superclass]};	
	(void)objc_msgSendSuper(&s, _cmd, coder);
	[coder encodeObject:[self viewLayoutManager] forKey:KTViewLayoutManagerKey];
}

void deallocDynamicIMP(id self, SEL _cmd) {
	Ivar mLayoutManagerAsIvar = class_getInstanceVariable([self class], "mLayoutManager");
	[object_getIvar(self, mLayoutManagerAsIvar) release];
	
	struct objc_super s = {self, [self superclass]};	
	(void)objc_msgSendSuper(&s, _cmd);
}
