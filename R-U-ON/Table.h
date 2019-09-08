//
//  Table.h
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/3/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Table : UITableViewController
@property (nonatomic, readwrite) NSString *type;
@end


@interface AlarmsTable : Table
+(void)startRefresh;
@end
@interface AgentsTable : Table @end
@interface TicketsTable : Table @end
