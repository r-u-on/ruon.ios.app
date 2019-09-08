//
//  Group.m
//  R-U-ON
//
//  Created by yuvalperlov on 8/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Group.h"


@implementation Group

@synthesize name;
@synthesize items;


- (Group *) initWithName:(NSString *)theName {
	self = [super init];
	if (self) {
		name = theName;
		items = [[NSMutableArray alloc]init];
	}
	return self;
}

- (void) add:(NSObject *)item {
	[items addObject:item];
}


@end
