//
//  Settings.h
//  R-U-ON
//
//  Created by yuvalperlov on 8/26/08.
//  Copyright 2008 R-U-ON. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Settings : NSObject

+(void) defaults;

+(void) set:(NSString*) key value:(id)value;
+(void) set:(NSString*) key value:(id)value commit:(BOOL)commit;
+(id) get:(NSString*) key;


@end
