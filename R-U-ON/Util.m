//
//  Util.m
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/1/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import "Util.h"

NSString *urlencode(NSString * url) {
    return [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"]];
}


NSString *SS(NSString *a, NSString *b) {
    return [NSString stringWithFormat:@"%@%@", a, b];
}
NSString *SI(NSString *a, int b) {
    return [NSString stringWithFormat:@"%@%d", a, b];
}


@implementation Util

@end
