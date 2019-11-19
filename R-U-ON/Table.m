//
//  Table.m
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/3/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import "Table.h"
#import "Util.h"
#import "Settings.h"
#import "Feed.h"
#import "Group.h"
#import "RuonTableViewCell.h"
#import "DetailViewController.h"
#import "Tabs.h"

NSString *const showDetailSegueIdentifier = @"showDetailSegue";

@implementation Table {
    Feed *feed;
    BOOL showGroups;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self refresh];
    
	// Logo
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logotop.png"]];
	UINavigationItem *nav = [self navigationItem];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:imageView];
	[nav setLeftBarButtonItem:item];
	
    id sgs = [Settings get:[NSString stringWithFormat:@"%@_group", _type]];
    
    if ([sgs isKindOfClass:[NSString class]]) {
        showGroups = [sgs isEqualToString:@"YES"];
    } else {
        showGroups = [sgs boolValue];
    }
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RuonTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RuonTableViewCell class])];
}

- (void)refresh {
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@/rss%@?iphone&id=%@",
                   RSSBASE, _type, [Settings get:@"accountid"]]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    [self.refreshControl beginRefreshing];
    [[NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *http = (NSHTTPURLResponse*)response;
        NSInteger code = [http statusCode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self refreshFailed:error.localizedDescription dialog:YES];
            } else if (code!=200) {
                [self refreshFailed:[NSString stringWithFormat:@"%@ %d", @"HTTP Error ", (int)code] dialog:NO];
            } else {
                if (data) {
                    [self refreshOkay:data];
                } else {
                    [self refreshFailed:@"Login Failed" dialog:NO];
                }
            }
            [self.refreshControl endRefreshing];
        });
    }] resume];
}

-(void) refreshFailed:(NSString*)err dialog:(BOOL) dialog {
    feed = [Feed feedWithError:err];
    [self.tableView reloadData];
    if (dialog) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fetch Failed" message:err preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:closeAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void) refreshOkay:(NSData*) data {
    feed = [Feed load:data type:_type];
    [self.tableView reloadData];
    
	if ([_type isEqualToString:@"alarms"]) {
		int criticalMajorAlarms = 0;
		for (int i=0;i<[feed count];++i) {
			NSDictionary *item = [feed objectAtIndex:i];
			NSString *severity = [item objectForKey:@"Severity"];
			if ([severity isEqualToString:@"Critical"] || [severity isEqualToString:@"Major"]) {
				criticalMajorAlarms++;
			}
		}
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = criticalMajorAlarms;
        [Tabs badgeUpdate];
	}
}

- (nullable NSDictionary *)itemForSelectedIndexPath:(nullable NSIndexPath *)selectedIndexPath
{
    if (!selectedIndexPath)
    {
        return nil;
    }
    NSDictionary *item;
    int index = (int) [selectedIndexPath indexAtPosition: [selectedIndexPath length] - 1];
    
    if (showGroups) {
        NSArray *groups = [feed groups];
        Group *group = [groups objectAtIndex:[selectedIndexPath indexAtPosition:0]];
        item = [[group items] objectAtIndex:index];
    } else {
        item = [feed objectAtIndex:index];
    }
    return ![item objectForKey:@"usermessage"] ? item : nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:showDetailSegueIdentifier])
    {
        NSDictionary *item = [self itemForSelectedIndexPath:self.tableView.indexPathForSelectedRow];
        if (item)
        {
            DetailViewController *detailViewController = segue.destinationViewController;
            [detailViewController bindWithRecord:item type:_type];;
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self itemForSelectedIndexPath:indexPath] != nil ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:showDetailSegueIdentifier sender:[tableView cellForRowAtIndexPath:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self itemForSelectedIndexPath:indexPath] != nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger sections = 1;
	if (feed&&showGroups) {
		sections = [[feed groups]count];
		if (sections==0) {
			sections = 1;
		}
	}
	return sections;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (feed && showGroups) {
		NSArray *groups = [feed groups];
		if ([groups count]>0) {
			Group *group = [groups objectAtIndex:section];
			return [[group items] count];
		} else {
			return 0;
		}
	} else {
		return feed?[feed count]:0;
	}
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (feed && showGroups) {
		NSArray *groups = [feed groups];
		if ([groups count]) {
			Group *group = [groups objectAtIndex:section];
			return group.name.length>0?[NSString stringWithFormat:@"  %@",[group name]]:group.name;
		}
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int index = (int)[indexPath indexAtPosition: [indexPath length] - 1];
	NSDictionary *item;
	if (showGroups) {
		NSArray *groups = [feed groups];
		Group *group = [groups objectAtIndex:[indexPath indexAtPosition:0]];
		item = [[group items] objectAtIndex:index];
	} else {
		item = [feed objectAtIndex:index];
	}
	
	RuonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RuonTableViewCell class]) forIndexPath:indexPath];
    [cell configureWithData:item type:_type];
	return cell;
}

@end

@implementation AlarmsTable
static AlarmsTable *alarmsTable;

-(void) viewDidLoad {
    self.type = @"alarms";
    [super viewDidLoad];
    alarmsTable = self;
}
-(void) viewDid {
     alarmsTable = nil;
}
+(void)startRefresh {
    [alarmsTable refresh];
}
@end
@implementation AgentsTable
-(void) viewDidLoad {
    self.type = @"agents";
    [super viewDidLoad];
}
@end
@implementation TicketsTable
-(void) viewDidLoad {
    self.type = @"tickets";
    [super viewDidLoad];
}
@end


