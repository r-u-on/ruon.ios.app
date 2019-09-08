//
//  Util.h
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/1/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef TEST
#define WWWBASE @"http://127.0.0.1:8080"
#define RSSBASE @"http://127.0.0.1:8080"
#else
#define WWWBASE @"https://www.r-u-on.com"
#define RSSBASE @"https://rss.r-u-on.com"
#endif

NSString *urlencode(NSString * url);
NSString *SS(NSString *a, NSString *b);
NSString *SI(NSString *a, int b);


@interface Util : NSObject

@end
