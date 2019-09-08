//
//  SplashViewController.m
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/15/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import "Splash.h"
#import "Settings.h"

@implementation Splash

-(BOOL) needLogin {
    NSString *aid = [Settings get:@"accountid"];
    if (aid.length>0) {
        id reset = [Settings get:@"reset_user"];
        return [reset boolValue];
    } else {
        return YES;
    }
}


-(void) viewDidAppear:(BOOL)animated {
    [self performSegueWithIdentifier:[self needLogin]?@"SplashToLogin":@"SplashToMain"
                              sender:self];

}

@end
