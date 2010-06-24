//
//  BWAnimator.m
//  Photoshoot
//
//  Created by Cathy Shive on 7/24/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "KTAnimator.h"

NSString *const KTAnimatorAnimationNameKey = @"KTAnimatorAnimationNameKey";
NSString *const KTAnimatorAnimationObjectKey = @"KTAnimatorAnimationObjectKey";
NSString *const KTAnimatorAnimationKeyPathKey = @"KTAnimatorAnimationKeyPathKey";
NSString *const KTAnimatorAnimationDurationKey = @"KTAnimatorAnimationDurationKey";
NSString *const KTAnimatorAnimationSpeedKey = @"KTAnimatorAnimationSpeedKey";
NSString *const KTAnimatorAnimationStartValueKey = @"KTAnimatorAnimationStartValueKey";
NSString *const KTAnimatorAnimationEndValueKey = @"KTAnimatorAnimationEndValueKey";
NSString *const KTAnimatorAnimationLocationKey = @"KTAnimatorAnimationLocationKey";
NSString *const KTAnimatorAnimationTypeKey = @"KTAnimatorAnimationTypeKey";
NSString *const KTAnimatorAnimationStartDateKey = @"KTAnimatorAnimationStartDateKey";
NSString *const KTAnimatorAnimationCurveKey = @"KTAnimatorAnimationCurveKey";
NSString *const KTAnimatorFloatAnimation = @"KTAnimatorFloatAnimation";
NSString *const KTAnimatorRectAnimation = @"KTAnimatorRectAnimation";
NSString *const KTAnimatorPointAnimation = @"KTAnimatorPointAnimation";

@interface NSObject (KTAnimatorDelegate)
- (void)animatorIsUpdatingAnimation:(NSDictionary*)theAnimation;
- (BOOL)isAnimationOverForStartValue:(CGFloat)theStartValue endValue:(CGFloat)theEndValue newValue:(CGFloat)theNewValue;
- (void)animatorStarted;
- (void)animatorEnded;
@end


@interface KTAnimator (Private)
- (void)updateAnimation;
- (void)startTimer;
- (void)endTimer;
@end

@implementation KTAnimator
@synthesize framesPerSecond = mFramesPerSecond;
@synthesize delegate = wDelegate;
- (id)init
{
	if(self = [super init])
	{
		mAnimationTimer = nil;	
		mAnimationQueue = [[NSMutableArray alloc] init];
		mFramesPerSecond = 30.0;
	}
	return self;
}

- (void)dealloc
{
	if([mAnimationTimer isValid])
		[mAnimationTimer invalidate];
	[mAnimationTimer release];
	[mAnimationQueue release];
	wDelegate = nil;
	[super dealloc];
}

- (void)removeAllAnimations
{
	[self endTimer];
	[mAnimationQueue removeAllObjects];
}

- (void)animateObject:(NSMutableDictionary*)theAnimationProperties
{
	// animations can either be set with a duration or a speed
	// if the speed is set, we ignore a duration if it's set as well
	if([theAnimationProperties valueForKey:KTAnimatorAnimationSpeedKey]!=nil)
	{
		// CS: at the moment, speed-based animations are not implemented
		// if the speed is set, we'll raise an exception telling the programmer to set a duration instead
		[NSException raise:@"KTAnimator" format:@"Speed configurations are not yet supported, please set a duration instead."];
		
		// once we implement the speed-based updating, we'll uncomment out the code below and remove the exception
		
		/*
		if([theAnimationProperties valueForKey:KTAnimatorAnimationDurationKey]!=nil)
		{
			NSLog(@"%@ found a speed setting and a durration setting, removing the durations", self);
			[theAnimationProperties removeObjectForKey:KTAnimatorAnimationDurationKey];
		}
		*/
	}
	
	
//	if([theAnimationProperties valueForKey:KTAnimatorAnimationDurationKey]!=nil)
//	{
//		NSNumber * aCurrentValue = [[theAnimationProperties valueForKey:@"object"] valueForKey:[theAnimationProperties valueForKey:@"keyPath"]];
//		NSNumber * aStartValue = [theAnimationProperties valueForKey:KTAnimatorAnimationStartValueKey];
//		NSNumber * anEndValue = [theAnimationProperties valueForKey:KTAnimatorAnimationEndValueKey];
//		// adjust the duration if it's necessary - this allows for interruptions in an animation, not sure if this is what the
//		// animator should do...
//		if([aCurrentValue floatValue] != [aStartValue floatValue])
//		{
//			float aDistance = [anEndValue floatValue] - [aStartValue floatValue];
//			float aDiff = [aCurrentValue floatValue] - [aStartValue floatValue];
//			float aPct = 0;
//			if(aDistance!=0)
//				aPct = aDiff/aDistance;
//			float aDuration = [[theAnimationProperties valueForKey:KTAnimatorAnimationDurationKey]floatValue];
//			aDuration *= aPct;
//			[theAnimationProperties setValue:[NSNumber numberWithFloat:aPct] forKey:KTAnimatorAnimationDurationKey];
//		}
//	}
	
	// check to see if we're already animating this value for this object
	id	anAnimationToRemove = nil;
	for(NSDictionary * anAnimationToCheck in mAnimationQueue)
	{
		id	anObject = [theAnimationProperties valueForKey:KTAnimatorAnimationObjectKey];
		id	aCurrentObject = [anAnimationToCheck valueForKey:KTAnimatorAnimationObjectKey];
		if(aCurrentObject == anObject)
		{
			if([[theAnimationProperties valueForKey:KTAnimatorAnimationKeyPathKey] isEqualToString:[anAnimationToCheck valueForKey:KTAnimatorAnimationKeyPathKey]])
			{
				// we have the same object and the same keypath
				// remove the animation in the queue, we don't care about this animation anymore
				anAnimationToRemove = [[anAnimationToCheck retain] autorelease];
				if([wDelegate respondsToSelector:@selector(animator:didEndAnimation:)])
					[wDelegate animator:self didEndAnimation:anAnimationToRemove];
				break;
			}
		}
	}
	
	if(anAnimationToRemove!=nil)
	{
		[mAnimationQueue removeObject:anAnimationToRemove];
	}
	
	// add object to queue
	[mAnimationQueue addObject:theAnimationProperties];
	// if this is the first object and the timer isn't already going, start the timer
	if(		[mAnimationQueue count] == 1 
		&&  ![mAnimationTimer isValid] )	  
	{
		[self startTimer];
	}
}


- (void)performUpdateAnimation:(NSTimer*)theTimer
{
	[self updateAnimation];
	// [self performSelectorOnMainThread:@selector(updateAnimation) withObject:nil waitUntilDone:NO];
}


- (void)updateAnimation
{
	/*
		CS:  All of the animaitons get updated every time the timer fires.  We have different options for how we calculate the new value 
		in the animation:
			• based on the kind of animation (linear, eased)
			• based on the type of *value* we're animating (frame or a float).  
			• based on whether the animation is speed or duration based.
		I plan to break this down into several methods to keep the logic more readable.
	*/ 
	//	NSLog(@"***************************************UPDATE KTANIMATION************************************************");
	// get ready to build a list of animations that are finished after this frame and can be removed from the queue
	NSMutableArray *	aListOfAnimationsToRemove = [[NSMutableArray alloc] init];
	
	// update each animation in the queue	
	NSArray * anAnimationQueue = [[mAnimationQueue copy] autorelease];
	for(NSDictionary * anAnimationObject in anAnimationQueue)
	{
		// get the info we need to calculate a new value
		id		aNewValue = nil;
		BOOL	anAnimationIsComplete = NO;
		
		// speed-based animation
		if([anAnimationObject valueForKey:KTAnimatorAnimationSpeedKey]!=nil)
		{
			// not implemented yet
		}
		
		// duration-based animation
		else if([anAnimationObject valueForKey:KTAnimatorAnimationDurationKey]!=nil)
		{
			// if there's no start date, make one
			if([anAnimationObject valueForKey:KTAnimatorAnimationStartDateKey]==nil)
			{
				[anAnimationObject setValue:[NSDate date] forKey:KTAnimatorAnimationStartDateKey]; 
				if([[self delegate] respondsToSelector:@selector(animator:didStartAnimation:)])
					[[self delegate] animator:self didStartAnimation:anAnimationObject];
			}
			KTAnimationType	anAnimationCurveType = [[anAnimationObject valueForKey:KTAnimatorAnimationCurveKey] intValue];
			CGFloat			aDuration = [[anAnimationObject valueForKey:KTAnimatorAnimationDurationKey]floatValue];
			CFTimeInterval	anElapsedTime = -[[anAnimationObject valueForKey:KTAnimatorAnimationStartDateKey] timeIntervalSinceNow];
			CGFloat			aNormalizedLocationInAnimation = (anElapsedTime / aDuration);	
			CGFloat			aLocationInAnimation = aNormalizedLocationInAnimation;
			
			switch(anAnimationCurveType)
			{
				case kKTAnimationType_EaseInAndOut:
					// apply the ease curve
					aLocationInAnimation = 1.0 - (.5 * sin((aNormalizedLocationInAnimation+.5) * ((3.14*2) / 2.0)) + .5);
				break;
			}
			
			// set the location in the animation objct info
			[anAnimationObject setValue:[NSNumber numberWithFloat:aLocationInAnimation] forKey:KTAnimatorAnimationLocationKey];
			
			// For a duration based animtation, we know that the animation should be over if the duration < the time that has passed
			// if this is the case we just use the end value for the new value - it the animation is not smooth, this could cause a jumpy effect at the
			// end of the animation
			anAnimationIsComplete = (fabs(anElapsedTime) > aDuration);
			if(anAnimationIsComplete)
			{
				aNewValue = [anAnimationObject valueForKey:KTAnimatorAnimationEndValueKey];
			}
			else
			{
				// is this a frame animation?
				if([[anAnimationObject valueForKey:KTAnimatorAnimationTypeKey] isEqualToString:KTAnimatorRectAnimation])
				{
					NSRect		aStartingRect = [[anAnimationObject valueForKey:KTAnimatorAnimationStartValueKey] rectValue];
					NSRect		anEndingRect = [[anAnimationObject valueForKey:KTAnimatorAnimationEndValueKey] rectValue];
					NSRect		aFrameToSet = NSZeroRect;
					

					
					// frame animation - animate each part of the rect individually
					CGFloat aStartValue;
					CGFloat anEndValue;
					CGFloat aDistanceOfAnimation;
					
					// x pos
					aStartValue = aStartingRect.origin.x;
					anEndValue = anEndingRect.origin.x;
					aDistanceOfAnimation = (anEndValue - aStartValue);
					aFrameToSet.origin.x = aStartValue + (aLocationInAnimation * aDistanceOfAnimation);
					
					// y pos
					aStartValue = aStartingRect.origin.y;
					anEndValue = anEndingRect.origin.y;
					aDistanceOfAnimation = (anEndValue - aStartValue);
					aFrameToSet.origin.y = aStartValue + (aLocationInAnimation * aDistanceOfAnimation);
					
					// width
					aStartValue = aStartingRect.size.width;
					anEndValue = anEndingRect.size.width;
					aDistanceOfAnimation = (anEndValue - aStartValue);
					aFrameToSet.size.width = aStartValue + (aLocationInAnimation * aDistanceOfAnimation);
					
					// height
					aStartValue = aStartingRect.size.height;
					anEndValue = anEndingRect.size.height;
					aDistanceOfAnimation = (anEndValue - aStartValue);
					aFrameToSet.size.height = aStartValue + (aLocationInAnimation * aDistanceOfAnimation);					
								
					// set the new value as an NSValue with a rect
					aNewValue = [NSValue valueWithRect:aFrameToSet];						
				}
				else if([[anAnimationObject valueForKey:KTAnimatorAnimationTypeKey] isEqualToString:KTAnimatorPointAnimation])
				{
					NSPoint		aStartingPoint = [[anAnimationObject valueForKey:KTAnimatorAnimationStartValueKey] pointValue];
					NSPoint		anEndingPoint = [[anAnimationObject valueForKey:KTAnimatorAnimationEndValueKey] pointValue];
					NSPoint		aPointToSet = NSZeroPoint;
					
					CGFloat aStartValue;
					CGFloat anEndValue;
					CGFloat aDistanceOfAnimation;
					
					// x pos
					aStartValue = aStartingPoint.x;
					anEndValue = anEndingPoint.x;
					aDistanceOfAnimation = (anEndValue - aStartValue);
					aPointToSet.x = aStartValue + (aLocationInAnimation * aDistanceOfAnimation);
					
					// y pos
					aStartValue = aStartingPoint.y;
					anEndValue = anEndingPoint.y;
					aDistanceOfAnimation = (anEndValue - aStartValue);
					aPointToSet.y = aStartValue + (aLocationInAnimation * aDistanceOfAnimation);			
								
					// set the new value as an NSValue with a rect
					aNewValue = [NSValue valueWithPoint:aPointToSet];					
				}
				else // this is animating just a float value
				{
					CGFloat	anEndValue = [[anAnimationObject valueForKey:KTAnimatorAnimationEndValueKey] floatValue];
					CGFloat	aStartValue = [[anAnimationObject valueForKey:KTAnimatorAnimationStartValueKey] floatValue];
					CGFloat	aDistanceOfAnimation = (anEndValue - aStartValue);
					CGFloat aFloatValueToSet = anEndValue;

					aFloatValueToSet = aStartValue + (aLocationInAnimation * aDistanceOfAnimation);
					
					// set the new value to an NSNumber from a float
					aNewValue = [NSNumber numberWithFloat:aFloatValueToSet];
				}
			}
		}
		else
		{
			NSLog(@"cannot update animation, there is no duration or speed set");
		}
		
		// set the value
		[[anAnimationObject valueForKey:KTAnimatorAnimationObjectKey] setValue:aNewValue forKey:[anAnimationObject valueForKey:KTAnimatorAnimationKeyPathKey]];
		// let delegate know we've updated
		if(wDelegate)
		{
			if([wDelegate respondsToSelector:@selector(animator:didUpdateAnimation:)])
				[wDelegate animator:self didUpdateAnimation:anAnimationObject];
		}
	
	
		// if we have determined that this animation is complete, add it to list of animations to remove and adjust this new value so that it is the requested end value
		if(anAnimationIsComplete)
		{
			[aListOfAnimationsToRemove addObject:anAnimationObject];
			if([wDelegate respondsToSelector:@selector(animator:didEndAnimation:)])
				[wDelegate animator:self didEndAnimation:anAnimationObject];
		}
	}
	
	// We've finished updating all the animations 

	// remove any objects that need to be removed
	if([aListOfAnimationsToRemove count] > 0)
	{
		//NSLog(@"removing %d animations from queue", [aListOfAnimationsToRemove count]);
		[mAnimationQueue removeObjectsInArray:aListOfAnimationsToRemove];
	}
	[aListOfAnimationsToRemove release];
	
	// if we don't have any more animations to update, stop the timer
	if([mAnimationQueue count] == 0)
	{
		[self endTimer];
	}
}

- (BOOL)isAnimationOverForStartValue:(CGFloat)theStartValue endValue:(CGFloat)theEndValue newValue:(CGFloat)theNewValue
{
	BOOL aBoolToReturn = NO;
	
	if(theStartValue < theEndValue)
	{
		if(	theNewValue >= theEndValue)
			aBoolToReturn = YES;
	}
	else
	{
		if(	theNewValue <= theEndValue)
			aBoolToReturn = YES;
	}
	return aBoolToReturn;
}


- (void)startTimer
{
	// start the timer
	mAnimationTimer = [[NSTimer timerWithTimeInterval:(1.0/mFramesPerSecond)
											   target:self 
											 selector:@selector(performUpdateAnimation:)
											 userInfo:nil
											  repeats:YES] retain];

	[[NSRunLoop currentRunLoop] addTimer:mAnimationTimer forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:mAnimationTimer forMode:NSModalPanelRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer:mAnimationTimer forMode:NSEventTrackingRunLoopMode];
	if([wDelegate respondsToSelector:@selector(animatorDidStartAnimating:)])
		[wDelegate animatorDidStartAnimating:self];
}


- (void)endTimer
{
	if([mAnimationTimer isValid])
	{
		[mAnimationTimer invalidate];
		[mAnimationTimer release];
		mAnimationTimer=nil;
		if([wDelegate respondsToSelector:@selector(animatorDidEndAllAnimations:)])
			[wDelegate animatorDidEndAllAnimations:self];
	}
}

- (void)setDelegate:(id)theDelegate
{
	wDelegate = theDelegate;
}


- (void)doubleDurationOfAllAnimations
{
	mDoubleDuration = YES;
}


@end
