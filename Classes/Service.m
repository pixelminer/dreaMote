//
//  Service.m
//  Untitled
//
//  Created by Moritz Venn on 08.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Service.h"

@implementation Service

@synthesize sref = _sref;
@synthesize sname = _sname;

- (id)initWithService:(Service *)service
{
	self = [super init];
	
	if (self) {
		_sref = [service.sref copy];
		_sname = [service.sname copy];
	}

	return self;
}

- (void)dealloc
{
	[_sref release];
	[_sname release];

	[super dealloc];
}

- (BOOL)isValid
{
	return _sref != nil;
}

#pragma mark -
#pragma mark	Copy
#pragma mark -

- (id)copyWithZone:(NSZone *)zone
{
	id newElement = [[[self class] alloc] initWithService:self];

	return newElement;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@> Name: '%@'.\n Ref: '%@'.\n", [self class], self.sname, self.sref];
}

@end
