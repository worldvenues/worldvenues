//
//  Additions.h
//  FlavorInfusion
//
//  Created by Sherwin Zadeh on 12/19/11.
//  Copyright (c) 2011 KUSC Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (additions)
- (id)notNullObjectForKey:(id)aKey;
- (NSString *)stringForKey:(id)aKey;
- (NSNumber *)numberForKey:(id)aKey;
-(NSArray*)arrayForKey:(id)aKey;
@end
