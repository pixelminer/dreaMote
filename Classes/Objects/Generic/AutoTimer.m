//
//  AutoTimer.m
//  dreaMote
//
//  Created by Moritz Venn on 18.03.11.
//  Copyright 2011 Moritz Venn. All rights reserved.
//

#import "AutoTimer.h"

@interface AutoTimer()
- (id)initWithAutoTimer:(AutoTimer *)autotimer;
@end

@implementation AutoTimer

@synthesize name, match, enabled, idno, from, to, offsetBefore, offsetAfter, encoding, searchType, searchCase, overrideAlternatives, services, bouquets, tags, maxduration, location, justplay, before, after, avoidDuplicateDescription, afterEventAction;

+ (AutoTimer *)timer
{
	AutoTimer *timer = [[AutoTimer alloc] init];
	timer.encoding = @"ISO8859-15";
	return [timer autorelease];
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
		overrideAlternatives = YES;
		afterEventAction = kAfterEventMax;
		maxduration = -1;
		offsetBefore = -1;
		offsetAfter = -1;
		idno = -1;
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
		includeTitle = [autotimer.includeTitle mutableCopy];
		includeShortdescription = [autotimer.includeShortdescription mutableCopy];
		includeDescription = [autotimer.includeDescription mutableCopy];
		includeDayOfWeek = [autotimer.includeDayOfWeek mutableCopy];
		excludeTitle = [autotimer.excludeTitle mutableCopy];
		excludeShortdescription = [autotimer.excludeShortdescription mutableCopy];
		excludeDescription = [autotimer.excludeDescription mutableCopy];
		excludeDayOfWeek = [autotimer.excludeDayOfWeek mutableCopy];
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[match release];
	[from release];
	[to release];
	[encoding release];
	[services release];
	[bouquets release];
	[tags release];
	[includeTitle release];
	[includeShortdescription release];
	[includeDescription release];
	[includeDayOfWeek release];
	[excludeTitle release];
	[excludeShortdescription release];
	[excludeDescription release];
	[excludeDayOfWeek release];
	[location release];
	[before release];
	[after release];

	[super dealloc];
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
