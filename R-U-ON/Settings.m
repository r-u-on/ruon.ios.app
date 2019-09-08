//
//  Settings.m
//  R-U-ON
//
//  Created by yuvalperlov on 8/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"


@implementation Settings


+(void) set:(NSString*) key value:(id)value {
    [Settings set:key value:value commit:YES];
}
+(void) set:(NSString*) key value:(id)value commit:(BOOL)commit{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
+(id) get:(NSString*) key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+(void) defaults {
 
    
    NSString *pathStr = [[NSBundle mainBundle] bundlePath];
	NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
	NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
	
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
	
	NSMutableDictionary *defaults = [[NSMutableDictionary alloc]initWithCapacity:[prefSpecifierArray count]];
	for (NSDictionary *prefItem in prefSpecifierArray)
	{
		NSString *keyValue = prefItem[@"Key"];
		id defaultValue = prefItem[@"DefaultValue"];
		if (keyValue && defaultValue) {
			defaults[keyValue] = defaultValue;
		}
	}
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    

    
    
}

@end
