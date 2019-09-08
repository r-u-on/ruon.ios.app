//
//  NotificationsRegister.h
//  R-U-ON
//
//  Created by yuvalperlov on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Settings.h"

@interface NotificationsRegister : NSObject<NSXMLParserDelegate> {
	NSData *deviceToken;
	NSMutableString *xmlItem;
}
+ (void) registerNotifications:(NSData*)deviceToken;
@end
