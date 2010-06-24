//
//  KTLayoutDynamicImplementation.h
//  KTUIKit
//
//  Created by Jonathan on 11/03/2009.
//  Copyright 2009 espresso served here. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//const char *const KTViewLayoutManagerIvarName = "mLayoutManager";
extern NSString *const KTViewLayoutManagerKey;

extern id layoutManagerDynamicMethodIMP(id self, SEL _cmd);

extern void setLayoutManagerDynamicMethodIMP(id self, SEL _cmd, id layoutManager);

extern id parentDynamicMethodIMP(id self, SEL _cmd);

extern id childrenDynamicMethodIMP(id self, SEL _cmd);

extern id initWithFrameDynamicIMP(id self, SEL _cmd, NSRect frame);

extern id initWithCoderDynamicIMP(id self, SEL _cmd, NSCoder *coder);

extern void encodeWithCoderDynamicIMP(id self, SEL _cmd, NSCoder *coder);

extern void deallocDynamicIMP(id self, SEL _cmd);
