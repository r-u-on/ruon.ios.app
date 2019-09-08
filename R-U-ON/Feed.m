//
//  Feed.m
//  R-U-ON
//
//  Created by yuvalperlov on 8/24/08.
//  Copyright 2008 R-U-ON, LLC. All rights reserved.
//

#import "Feed.h"
#import "Group.h"
#import "Util.h"

@implementation Feed {
	// Model
	NSString *type;
	NSMutableArray *items;
	NSArray *groups;
	
	// For Parsing
	NSMutableDictionary *currentItem;
	NSMutableString *currentContent;
}


-(id) initWithError:(NSString*) error {
	if ((self = [super init])) {
		items = [NSMutableArray array];
        [self errorMessage:error];
    }
    return self;
}

-(id) initWithData:(NSData*)data type:(NSString*) atype {
	if ((self = [super init])) {
		type = atype;
		items = [NSMutableArray array];
		groups = nil;
        [self parse:data];
	}
	return self;
}

- (void) parse:(NSData*) data {

	NSXMLParser * rssParser = [[NSXMLParser alloc] initWithData:data];
	@try {
		[rssParser setDelegate:self];
	
		[rssParser setShouldProcessNamespaces:NO];
		[rssParser setShouldReportNamespacePrefixes:NO];
		[rssParser setShouldResolveExternalEntities:NO];
	
		[rssParser parse];
		
		if ([items count]==0) {
			NSDictionary *msg;
			if ([type isEqualToString:@"agents"]) {
				msg = [[NSDictionary alloc] initWithObjectsAndKeys:@"No agents deployed", @"usermessage", nil];
			} else if ([type isEqualToString:@"alarms"]) {
				msg = [[NSDictionary alloc] initWithObjectsAndKeys:@"There are no alarms :-)", @"usermessage",
					   @"Okay", @"Severity", nil];
			} else if ([type isEqualToString:@"tickets"]) {
				msg = [[NSDictionary alloc] initWithObjectsAndKeys:@"You have no open or resolved tickets", @"usermessage", nil];
			}
			if (msg) {
				NSDictionary *empty = [[NSDictionary alloc]initWithObjectsAndKeys:@"", @"usermessage", nil];
				[items addObject:empty];
				[items addObject:msg];
			}
		}
	} @catch (NSException * e) {
        [self errorMessage:e.reason];
	} @finally {
	}
}

-(void) errorMessage:(NSString*)message {
    NSDictionary *empty = [[NSDictionary alloc]initWithObjectsAndKeys:@"", @"usermessage", nil];
    NSDictionary *msg = [[NSDictionary alloc] initWithObjectsAndKeys:message, @"usermessage",
                         @"Critical", @"Severity", nil];
    
    [items addObject:empty];
    [items addObject:msg];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
	NSString * errorString = [parseError localizedDescription];
	switch ([parseError code]) {
		case 5: 
			errorString = @"Can't connect to R-U-ON";
			break;
	}

	@throw [NSException 
		exceptionWithName: @"Error loading feed"
		reason: errorString
		userInfo:nil
	];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	currentItem = nil;
	currentContent = nil;
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	if ([elementName isEqualToString:@"item"]) {
		currentItem = [[NSMutableDictionary alloc] init];
	} else if (currentItem && ![elementName isEqualToString:@"description"]) { // description is taken care of by the CDATA method
		currentContent = [[NSMutableString alloc] init];
		[currentItem setObject:currentContent forKey:elementName];
	}
}

-(void)parseTitle {
    NSArray *ticketsNames = @[@"TRK", @"Description"];
	NSArray *alarmsNames = @[@"Agent", @"Severity"];

	NSRange splitAt;
	
	NSString *title = [currentItem objectForKey:@"title"];
    NSArray * names = nil;
	if ([type isEqualToString:@"tickets"]) {
		names = ticketsNames; 
		splitAt = [title rangeOfString:@": "];
	} else if ([type isEqualToString:@"alarms"]) {
		names = alarmsNames;
		splitAt = [title rangeOfString:@": " options:NSBackwardsSearch];
	}
	
	if (names && splitAt.location!=NSNotFound) {
        currentItem[names[0]] = [title substringToIndex:splitAt.location];
		currentItem[names[1]] = [title substringFromIndex:splitAt.location+splitAt.length];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if (currentContent) {
		currentContent = nil;
	} else if ([elementName isEqualToString:@"item"]) {
		if ([[currentItem objectForKey:@"title"] isEqualToString:@"R-U-ON Feed Exception"]) {
			[currentItem setObject:@"Critical" forKey:@"Severity"];
			[currentItem setObject:[currentItem objectForKey:@"Description"] forKey:@"usermessage"]; 
			NSDictionary *empty = [[NSDictionary alloc]initWithObjectsAndKeys:@"", @"usermessage", nil];
			[items addObject:empty];
		} else {
			[self parseTitle];
		}
		[items addObject:currentItem];
		currentItem = nil;
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
		[currentContent appendString:string];
}
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
	if (currentItem) {
		NSString *data = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
		NSArray *array = [data componentsSeparatedByString:@"<br>"];
		int nolabel = 0;
		for (int i=0;i<[array count];++i) {
			NSString *line = [array objectAtIndex:i];
			NSArray *a2 = [line componentsSeparatedByString:@": "];
            NSString *name = [a2 objectAtIndex:0];
			if ([a2 count]==1 || ([type isEqualToString:@"alarms"] && ![name isEqualToString:@"Resource"] && ![name isEqualToString:@"Group"])) {
				[currentItem setObject:line forKey:(nolabel++==0?@"Description":@"Time Up")];
			} else if ([a2 count]>1){
				NSMutableString *value = [[NSMutableString alloc]init];
				for (int j=1;j<[a2 count];++j) {
					[value appendString:[a2 objectAtIndex:j]];
				}
				if ([value isEqualToString:@"None"] && [name isEqualToString:@"Group"]) {
					value = [NSMutableString string];
				}
				[currentItem setObject:value forKey:name];
				if ([name isEqualToString:@"Category"]) {
					[currentItem setObject:value forKey:@"Group"];
				}
			}
		}
	}
}

- (int) count {
	return items?(int)items.count:0;
}
- (NSDictionary *) objectAtIndex:(NSUInteger)index {
	return items?[items objectAtIndex:index]:nil;
}

NSInteger sortGroups(id g1, id g2, void *reverse)
{
    NSString *name1 = [g1 name];
    NSString *name2 = [g2 name];
	
    NSComparisonResult comparison = [name1 localizedCaseInsensitiveCompare:name2];
    if ((BOOL *)reverse == NO) {
        return -comparison;
    }
    return comparison;
}


- (NSArray *) groups {
	if (!groups) {
		NSMutableArray *gg = [[NSMutableArray alloc]init];
		NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
		
		for (int i=0;i<[self count];i++) {
			NSDictionary *item = [self objectAtIndex:i];
			NSString *groupName = [item objectForKey:@"Group"];
			if (groupName==nil) {
				groupName = @"";
			}
			Group *group = [map objectForKey:groupName];
			if (group==nil) {
				group = [[Group alloc]initWithName:groupName];
				[gg addObject:group];
				[map setObject:group forKey:groupName];
			}
			[group add:item];
		}
		BOOL reverseSort = YES;
		groups = [gg sortedArrayUsingFunction:sortGroups context:&reverseSort];
	}
	return groups;
}

- (NSString *) type {
	return type;
}


+ (Feed *) load: (NSData*) data type:(NSString *)type {
	return [[Feed alloc] initWithData:data type:type];
}
+ (Feed *) feedWithError:(NSString*)error {
	return [[Feed alloc] initWithError:error];
}



@end
