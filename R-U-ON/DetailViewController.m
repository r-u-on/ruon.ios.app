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
#import "DetailTableViewCell.h"


#define ROW_HEIGHT 35
#define PADDING 10
#define COL2 100
#define MAIN_FONT_SIZE 18.0
#define LABEL_HEIGHT 26.0

NSString *const detailCellIdentifier = @"detailCell";

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
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
	}
}

- (void)bindWithRecord:(NSDictionary*)record type:(NSString*)type
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:detailCellIdentifier forIndexPath:indexPath];
    
	NSString *key = [[meta objectAtIndex:[indexPath section]+1] objectAtIndex:[indexPath row]+1];
	NSString *value = [data objectForKey:key];
	
	UIColor *background = [UIColor clearColor];
	if ([key isEqualToString:@"Severity"]) {
		background = [Colors colorForKey:value];
	} else if ([key isEqualToString:@"Status"]) {
		UIColor *c = [Colors colorForKey:value];
		if (c) {
			background = c;
		}
	}
    
	[cell.nameLabel setText:key];
	[cell.nameLabel setBackgroundColor:background];

	[cell.valueLabel setText:value];
	[cell.valueLabel setBackgroundColor:background];
	
	[[cell contentView] setBackgroundColor:background];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	return [self getData:[[meta objectAtIndex:section+1] objectAtIndex:0]];
}

@end
