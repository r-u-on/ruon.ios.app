//
//  DetailViewController.m
//  R-U-ON
//
//  Created by yuvalperlov on 8/24/08.
//  Copyright 2008 R-U-ON. All rights reserved.
//

#import "DetailViewController.h"
#import "Colors.h"
#import "Util.h"



#define ROW_HEIGHT 35
#define PADDING 10
#define COL2 100
#define MAIN_FONT_SIZE 18.0
#define LABEL_HEIGHT 26.0



NSDictionary *metaData() {
	static NSDictionary *md = nil;
	if (md==nil) {
		md = [[NSDictionary alloc] initWithObjectsAndKeys:
			// Alarms Meta Data
			[[NSArray alloc]initWithObjects:
				@"Agent", 
			    [[NSArray alloc]initWithObjects: @"Resource", nil],
				[[NSArray alloc]initWithObjects: @"Description", nil],
				[[NSArray alloc]initWithObjects: @"", @"Agent", @"Severity", @"Time Up", nil],
			    nil], 
		        @"alarms",
			
			// Agents Meta Data
			[[NSArray alloc]initWithObjects:
				@"title", 
			    [[NSArray alloc]initWithObjects: @"Agent Type", @"Type", @"OS", @"Group", nil],
			    [[NSArray alloc]initWithObjects: @"Agent State", @"State", @"Severity", @"Last contact", @"Uptime", nil],
			    [[NSArray alloc]initWithObjects: @"Network", @"IP", @"Public IP", nil],
			    nil], 
			    @"agents",
			  
			// Tickets Meta Data
			[[NSArray alloc]initWithObjects:
				@"TRK", 
				[[NSArray alloc]initWithObjects: @"Description", nil],
				[[NSArray alloc]initWithObjects: @"",  @"TRK", @"Category", @"Opened By", @"Opened At", @"Status", @"Severity", @"Assigned To", nil],
				nil], 
			    @"tickets",

		  nil];
	}
	return md;
}

@implementation DetailViewController {
	NSArray *meta;
	NSDictionary *data;
}


- (NSString *)getData:(NSString *)key {
	NSString *d = [data objectForKey:key];
	return d?d:key;
}

NSString *target(NSString *uri) {
	NSRange range = [uri rangeOfString:@"www.r-u-on.com"];
	return [uri substringFromIndex:range.location+range.length];
}

- (IBAction)toBrowser:(id)sender {
	NSString *uri = [data objectForKey:@"link"];
	if (uri) {
        uri = [NSString stringWithFormat:@"https://www.r-u-on.com/ctrl?action=login&TARGET=%@&USERNAME=%@&PASSWORD=%@",
               urlencode(target(uri)),
               urlencode([Settings get:@"email"]),
               urlencode([Settings get:@"password"])
               ];
        
        NSURL *url = [NSURL URLWithString:uri];
        [[UIApplication sharedApplication] openURL:url];
	}
}

- (void)bindWitRecord:(NSDictionary*)record type:(NSString*)type
{
    meta = [metaData() objectForKey:type];
    data = record;
    self.title = [self getData:[meta objectAtIndex:0]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [meta count] - 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[meta objectAtIndex:section+1] count] - 1;
}


#define NAME_TAG  1
#define VALUE_TAG 2


- (UITableViewCell*) cellWithIdentifier:(NSString*)identifier {
	CGRect rect;
	
	int width = self.view.bounds.size.width;// <=400?290:450;
	
	rect = CGRectMake(0.0, 0.0, width, ROW_HEIGHT);
	
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

	UILabel *label;
	
	rect = CGRectMake(PADDING, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, COL2, LABEL_HEIGHT);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = NAME_TAG;
	label.font = [UIFont boldSystemFontOfSize:MAIN_FONT_SIZE];
	label.adjustsFontSizeToFitWidth = YES;
	[cell.contentView addSubview:label];
	label.highlightedTextColor = [UIColor whiteColor];
	
	rect = CGRectMake(COL2+PADDING, (ROW_HEIGHT - LABEL_HEIGHT) / 2.0, width-COL2-2*PADDING, LABEL_HEIGHT);
	label = [[UILabel alloc] initWithFrame:rect];
	label.tag = VALUE_TAG;
	label.font = [UIFont systemFontOfSize:MAIN_FONT_SIZE];
	label.adjustsFontSizeToFitWidth = YES;
	label.textAlignment = NSTextAlignmentRight;
	[cell.contentView addSubview:label];
	label.highlightedTextColor = [UIColor whiteColor];
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *cellIdentifier;
	cellIdentifier =  [[self view] bounds].size.width <=400 ? @"dvc_p" : @"dvc_l";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [self cellWithIdentifier:cellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	NSString *key = [[meta objectAtIndex:[indexPath section]+1] objectAtIndex:[indexPath row]+1];
	NSString *value = [data objectForKey:key];
	
	UILabel *label;
	
	UIColor *background = [UIColor clearColor];
	if ([key isEqualToString:@"Severity"]) {
		background = [Colors colorForKey:value];
	} else if ([key isEqualToString:@"Status"]) {
		UIColor *c = [Colors colorForKey:value];
		if (c) {
			background = c;
		}
	}

	label = (UILabel *)[cell viewWithTag:NAME_TAG];
	[label setText:key];
	[label setBackgroundColor:background];

	label = (UILabel *)[cell viewWithTag:VALUE_TAG];
	[label setText:value];
	[label setBackgroundColor:background];
	
	[[cell contentView] setBackgroundColor:background];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return [self getData:[[meta objectAtIndex:section+1] objectAtIndex:0]];
}

@end
