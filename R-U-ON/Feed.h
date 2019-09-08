//
//  Feed.h
//  R-U-ON
//
//  Created by yuvalperlov on 8/24/08.
//  Copyright 2008 R-U-ON. All rights reserved.
//


@interface Feed : NSObject <NSXMLParserDelegate>




+ (Feed *) load:(NSData *)data type:(NSString*)type;
+ (Feed *) feedWithError:(NSString*)error;

-(NSDictionary*) objectAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) NSArray *groups;
@property (nonatomic, readonly) int count;




@end
