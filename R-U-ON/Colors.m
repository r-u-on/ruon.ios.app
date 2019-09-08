//
//  Color.m
//  R-U-ON
//
//  Created by yuvalperlov on 8/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Colors.h"
#import "Settings.h"


@implementation Colors

+ (UIColor*) colorForKey:(NSString*)key {
	static NSDictionary *colors = nil;
	if (colors==nil) {
		colors = [[NSDictionary alloc] initWithObjectsAndKeys:
				  MY_RED,    @"Critical",
				  MY_ORANGE, @"Major",
				  MY_YELLOW, @"Minor",
				  MY_BLUE,   @"Resolved",
				  MY_GREEN,  @"Okay",
				  MY_GREEN,  @"Closed",
				  nil
				  ];
	}
	UIColor *color = nil;
	if (key!=nil) {
		color  = [colors objectForKey:key];
	}
	return color==nil?[UIColor whiteColor]:color;
}

+ (UIColor*) colorForItem:(NSDictionary*)item {
	NSString *key = [item objectForKey:@"Status"];
	if (!key || [key isEqualToString:@"Open"]) {
		key = [item objectForKey:@"Severity"];
	}
	return [self colorForKey:key];
}

@end
