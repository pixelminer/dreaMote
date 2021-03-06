//
//  AutoTimer.m
//  dreaMote
//
//  Created by Moritz Venn on 18.03.11.
//  Copyright 2011-2012 Moritz Venn. All rights reserved.
//

#import "AutoTimer.h"
#import "UIDevice+SystemVersion.h"

@interface AutoTimer()
- (id)initWithAutoTimer:(AutoTimer *)autotimer;
@end

@implementation AutoTimer

@synthesize name, match, enabled, idno, from, to, offsetBefore, offsetAfter, encoding, searchType, searchCase, overrideAlternatives, services, bouquets, tags, maxduration, location, justplay, setEndtime, before, after, avoidDuplicateDescription, searchForDuplicateDescription, afterEventAction, afterEventFrom, afterEventTo, vps_enabled, vps_overwrite;

+ (AutoTimer *)timer
{
	AutoTimer *timer = [[AutoTimer alloc] init];
	timer.encoding = @"ISO8859-15";
	timer.overrideAlternatives = YES;
	return timer;
}

+ (AutoTimer *)timerFromEvent:(NSObject<EventProtocol> *)event
{
	AutoTimer *timer = [AutoTimer timer];
	timer.name = event.title;
	timer.match = event.title;
	timer.enabled = YES;
	timer.idno = -1;
	timer.from = [event.begin dateByAddingTimeInterval:-60*60];
	timer.to = [event.end dateByAddingTimeInterval:60*60];
	timer.searchCase = CASE_SENSITIVE;
	timer.searchType = SEARCH_TYPE_EXACT;
	timer.overrideAlternatives = YES;
	if(event.service)
		[timer.services addObject:event.service];
	timer.afterEventAction = kAfterEventMax;
	return timer;
}

+ (AutoTimer *)timerFromTimer:(NSObject<TimerProtocol> *)rtimer
{
	AutoTimer *timer = [AutoTimer timer];
	timer.name = rtimer.title;
	timer.match = rtimer.title;
	timer.enabled = YES;
	timer.idno = -1;
	timer.from = [rtimer.begin dateByAddingTimeInterval:-60*60];
	timer.to = [rtimer.end dateByAddingTimeInterval:60*60];
	timer.searchCase = CASE_SENSITIVE;
	timer.searchType = SEARCH_TYPE_EXACT;
	timer.overrideAlternatives = YES;
	if(rtimer.service)
		[timer.services addObject:rtimer.service];
	timer.afterEventAction = rtimer.afterevent;
	timer.tags = [rtimer.tags copy];
	timer.justplay = rtimer.justplay;
	timer.location = rtimer.location;
	timer.vps_enabled = rtimer.vpsplugin_enabled;
	timer.vps_overwrite = rtimer.vpsplugin_overwrite;
	return timer;
}

- (id)init
{
	if((self = [super init]))
	{
		services = [[NSMutableArray alloc] init];
		bouquets = [[NSMutableArray alloc] init];
		enabled = YES;
		searchType = SEARCH_TYPE_PARTIAL;
		searchCase = CASE_INSENSITIVE;
		afterEventAction = kAfterEventMax;
		maxduration = -1;
		offsetBefore = -1;
		offsetAfter = -1;
		idno = -1;
		setEndtime = YES;
		searchForDuplicateDescription = autoTimerSearchEdesc;
	}
	return self;
}

- (id)initWithAutoTimer:(AutoTimer *)autotimer
{
	if((self = [super init]))
	{
		name = [autotimer.name copy];
		match = [autotimer.match copy];
		enabled = autotimer.enabled;
		idno = autotimer.idno;
		from = [autotimer.from copy];
		to = [autotimer.to copy];
		offsetBefore = autotimer.offsetBefore;
		offsetAfter = autotimer.offsetAfter;
		encoding = [autotimer.encoding copy];
		searchType = autotimer.searchType;
		searchCase = autotimer.searchCase;
		overrideAlternatives = autotimer.overrideAlternatives;
		services = [autotimer.services mutableCopy];
		bouquets = [autotimer.bouquets mutableCopy];
		tags = [autotimer.tags copy];
		maxduration = autotimer.maxduration;
		location = [autotimer.location copy];
		justplay = autotimer.justplay;
		before = [autotimer.before copy];
		after = [autotimer.after copy];
		avoidDuplicateDescription = autotimer.avoidDuplicateDescription;
		afterEventAction = autotimer.afterEventAction;
		afterEventFrom = [autotimer.afterEventFrom copy];
		afterEventTo = [autotimer.afterEventTo copy];
		includeTitle = [autotimer.includeTitle mutableCopy];
		includeShortdescription = [autotimer.includeShortdescription mutableCopy];
		includeDescription = [autotimer.includeDescription mutableCopy];
		includeDayOfWeek = [autotimer.includeDayOfWeek mutableCopy];
		excludeTitle = [autotimer.excludeTitle mutableCopy];
		excludeShortdescription = [autotimer.excludeShortdescription mutableCopy];
		excludeDescription = [autotimer.excludeDescription mutableCopy];
		excludeDayOfWeek = [autotimer.excludeDayOfWeek mutableCopy];
		vps_enabled = autotimer.vps_enabled;
		vps_overwrite = autotimer.vps_overwrite;
	}
	return self;
}


- (NSComparisonResult)compare: (AutoTimer *)otherAT
{
	return [otherAT.name caseInsensitiveCompare:name];
}

- (void)addInclude:(NSString *)include where:(autoTimerWhereType)where
{
	switch(where)
	{
		case autoTimerWhereTitle:
			[self.includeTitle addObject:include];
			break;
		case autoTimerWhereShortdescription:
			[self.includeShortdescription addObject:include];
			break;
		case autoTimerWhereDescription:
			[self.includeDescription addObject:include];
			break;
		case autoTimerWhereDayOfWeek:
			[self.includeDayOfWeek addObject:include];
			break;
		default:
			NSLog(@"Invalid 'where' received: %d", (NSInteger)where);
#if IS_DEBUG()
			[NSException raise:NSInvalidArgumentException format:@"invalid where"];
#endif
			break;
	}
}

- (void)addExclude:(NSString *)exclude where:(autoTimerWhereType)where
{
	switch(where)
	{
		case autoTimerWhereTitle:
			[self.excludeTitle addObject:exclude];
			break;
		case autoTimerWhereShortdescription:
			[self.excludeShortdescription addObject:exclude];
			break;
		case autoTimerWhereDescription:
			[self.excludeDescription addObject:exclude];
			break;
		case autoTimerWhereDayOfWeek:
			[self.excludeDayOfWeek addObject:exclude];
			break;
		default:
			NSLog(@"Invalid 'where' received: %d", (NSInteger)where);
#if IS_DEBUG()
			[NSException raise:NSInvalidArgumentException format:@"invalid where"];
#endif
			break;
	}
}

#pragma mark - Getter/Setter

- (BOOL)valid
{
	return match != nil;
}

- (NSMutableArray *)includeTitle
{
	@synchronized(self)
	{
		if(includeTitle == nil)
			includeTitle = [[NSMutableArray alloc] init];
	}
	return includeTitle;
}

- (NSMutableArray *)includeShortdescription
{
	@synchronized(self)
	{
		if(includeShortdescription == nil)
			includeShortdescription = [[NSMutableArray alloc] init];
	}
	return includeShortdescription;
}

- (NSMutableArray *)includeDescription
{
	@synchronized(self)
	{
		if(includeDescription == nil)
			includeDescription = [[NSMutableArray alloc] init];
	}
	return includeDescription;
}

- (NSMutableArray *)includeDayOfWeek
{
	@synchronized(self)
	{
		if(includeDayOfWeek == nil)
			includeDayOfWeek = [[NSMutableArray alloc] init];
	}
	return includeDayOfWeek;
}

- (NSMutableArray *)excludeTitle
{
	@synchronized(self)
	{
		if(excludeTitle == nil)
			excludeTitle = [[NSMutableArray alloc] init];
	}
	return excludeTitle;
}

- (NSMutableArray *)excludeShortdescription
{
	@synchronized(self)
	{
		if(excludeShortdescription == nil)
			excludeShortdescription = [[NSMutableArray alloc] init];
	}
	return excludeShortdescription;
}

- (NSMutableArray *)excludeDescription
{
	@synchronized(self)
	{
		if(excludeDescription == nil)
			excludeDescription = [[NSMutableArray alloc] init];
	}
	return excludeDescription;
}

- (NSMutableArray *)excludeDayOfWeek
{
	@synchronized(self)
	{
		if(excludeDayOfWeek == nil)
			excludeDayOfWeek = [[NSMutableArray alloc] init];
	}
	return excludeDayOfWeek;
}

#pragma mark -
#pragma mark	Copy
#pragma mark -

- (id)copyWithZone:(NSZone *)zone
{
	id newElement = [[[self class] alloc] initWithAutoTimer: self];
	return newElement;
}

@end
