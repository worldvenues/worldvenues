//
//  Additions.m
//  FlavorInfusion
//
//  Created by Sherwin Zadeh on 12/19/11.
//  Copyright (c) 2011 KUSC Interactive. All rights reserved.
//

#import "Additions.h"

@implementation NSDictionary (Additions)
- (id)notNullObjectForKey:(id)aKey {
	id obj = [self objectForKey:aKey];
	if ([obj isKindOfClass:[NSNull class]]) {
		return nil;
	}
	return obj;
}

- (NSString *)stringForKey:(id)aKey {
	return [NSString stringWithFormat:@"%@", [self objectForKey:aKey]];
}

- (NSNumber *)numberForKey:(id)aKey {
    id obj = [self objectForKey:aKey];
	if (![obj isKindOfClass:[NSNumber class]]) {
		return nil;
	}
	return obj;
}

-(NSArray*)arrayForKey:(id)aKey
{
	id object = [self objectForKey:aKey];

	if ([object isKindOfClass:[NSArray class]])
	{
		return (NSArray*)object;
	}
	else
	{
		return @[object];
	}
}


@end
