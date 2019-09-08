//
//  Group.h
//  R-U-ON
//
//  Created by yuvalperlov on 8/26/08.
//  Copyright 2008 R-U-ON. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Group:NSObject {
	NSString *name;
	NSMutableArray *items;
}

- (Group *) initWithName:(NSString *)theName;
- (void) add:(NSObject *)item;

@property (readonly, retain) NSString *name;
@property (readonly, retain) NSArray *items;

@end