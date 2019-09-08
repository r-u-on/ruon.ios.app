//
//  Color.h
//  R-U-ON
//
//  Created by yuvalperlov on 8/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MY_RED    [UIColor colorWithRed:.8  green:.2   blue:0  alpha:1]  // cd3301
#define MY_ORANGE [UIColor colorWithRed:.93 green:0.61 blue:.2 alpha:1]  // ed9c33
#define MY_YELLOW [UIColor colorWithRed:.95  green:.76 blue:0  alpha:1]  // f2c200

#define MY_BLUE   [UIColor colorWithRed:.34 green:.54  blue:.69 alpha:1]  // 5689af
#define MY_GREEN  [UIColor colorWithRed:.54 green:.69  blue:.34 alpha:1]  // 89af56

#define MY_TINT MY_GREEN


@interface Colors : NSObject {

}

+ (UIColor*) colorForKey:(NSString*)key;
+ (UIColor*) colorForItem:(NSDictionary*)item;

@end
