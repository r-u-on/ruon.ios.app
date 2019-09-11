//
//  LoginView.m
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/1/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import "LoginView.h"
#import "Util.h"
#import "Settings.h"

@implementation LoginView {
    NSMutableString *xmlItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _email.text = [Settings get:@"email"]?:@"";
    _version.text = [NSString stringWithFormat:@"%@ %@",_version.text, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    _copyright.text = [NSString stringWithFormat:@"Copyright © 2008-%@",
                       [formatter stringFromDate:[NSDate date]]];
    
    
    xmlItem = [NSMutableString string];
}


- (IBAction)doneEmail:(id)sender {
    [_password becomeFirstResponder];

}
- (IBAction)donePassword:(id)sender {
    [self login];
}

- (IBAction)login:(id)sender {
    [self login];
}

- (IBAction)openSite:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.r-u-on.com/"];
    [[UIApplication sharedApplication] openURL:url];

}



-(void) login {
    
    _errMessage.text = @"";
    
    if (_email.text.length==0) {
        [_email becomeFirstResponder];
        _errMessage.text = @"Please supply your email";
        [self.view endEditing:YES];
        return;
    }

    if (_password.text.length==0) {
        [_password becomeFirstResponder];
        _errMessage.text = @"Please supply your password";
        [self.view endEditing:YES];
        return;
    }
    _loginButton.enabled = _password.enabled = _email.enabled = NO;
    [_throbber startAnimating];
    [self serverAuthentication];
}

-(void) serverAuthentication {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/resolveGUID?email=%@&password=%@", WWWBASE, urlencode(_email.text), urlencode(_password.text)]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    [NSURLSession.sharedSession dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self loginFailed:@"Can't reach the R-U-ON Server"];
            } else {
                if (data) {
                    NSXMLParser *xml = [[NSXMLParser alloc] initWithData:data];
                    xml.delegate = self;
                    xml.shouldProcessNamespaces = xml.shouldReportNamespacePrefixes = xml.shouldResolveExternalEntities = NO;
                    [xml parse];
                } else {
                    [self loginFailed:@"Login Failed"];
                }
           }
        });
    }];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	[xmlItem appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"error"]) {
		[self loginFailed:xmlItem];
	} else if ([elementName isEqualToString:@"guid"]) {
		[Settings set:@"accountid" value:xmlItem commit:NO];
		[Settings set:@"accountidemail" value:_email.text commit:NO];
		[Settings set:@"email" value:_email.text commit:NO];
		[Settings set:@"password" value:_password.text commit:NO];
		[Settings set:@"reset_user" value:@NO commit:YES];
		[LoginView checkNotifications:YES];
        [self goToMain];
	}
    xmlItem.string = @"";
}

-(void) goToMain {
    [self performSegueWithIdentifier:@"ToMainPage" sender:self];
}

+ (void) checkNotifications:(BOOL)force {
	if (force) {
		UIApplication *application = [UIApplication sharedApplication];
		[application unregisterForRemoteNotifications];
	}
	
	NSString *notificationsOn = [Settings get:@"notificationsOn"];
	if (force || notificationsOn==nil) {
		UIApplication *application = [UIApplication sharedApplication];
		NSLog(@"Starting registerForRemoteNotifications");
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                             |UIUserNotificationTypeSound
                                                                                             |UIUserNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
	}
	
}



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self loginFailed:@"Login failed (-1)"];
}

-(void) loginFailed:(NSString*)message {
    _errMessage.text = message;
    _loginButton.enabled = _password.enabled = _email.enabled = YES;
    [_throbber stopAnimating];
}



@end
