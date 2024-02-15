//
//  NotificationsRegister.m
//  R-U-ON
//
//  Created by yuvalperlov on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NotificationsRegister.h"
#import "Util.h"

@implementation NotificationsRegister


- (id) init:(NSData*)aDeviceToken {
	self = [super init];
	if (self != nil) {
		deviceToken = aDeviceToken;
	}
	return self;
}

- (NSString *) encodeDeviceToken:(NSData*)bytes {
	NSMutableString *string = [NSMutableString stringWithCapacity:[bytes length] * 2];  
	const uint8_t *bb = [bytes bytes];  
	
	for (int i = 0; i < [bytes length]; i++) { 
		[string appendFormat:@"%02x", bb[i]]; 
	}
	
	return string;  
}

- (void) registerNotifications {
	NSMutableString *url = [[NSMutableString alloc]init];
	
	NSString *email = [Settings get:@"email"];
	NSString *password = [Settings get:@"password"];
	
	[url appendString:WWWBASE@"/iphoneNotif?device="];	
	[url appendString:urlencode([self encodeDeviceToken:deviceToken])];
	[url appendString:@"&email="];
	[url appendString:urlencode(email)];
	[url appendString:@"&name="];
	[url appendString:urlencode([UIDevice currentDevice].name)];
	[url appendString:@"&password="];
	[url appendString:urlencode(password)];
	
	NSURL *xmlURL = [NSURL URLWithString:url];
	NSXMLParser *xml = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	[xml setDelegate:self];
	[xml setShouldProcessNamespaces:NO];
	[xml setShouldReportNamespacePrefixes:NO];
	[xml setShouldResolveExternalEntities:NO];
	
	xmlItem = [[NSMutableString alloc]init];
	
	[xml parse];
}

- (void) message: (NSString *)messageString {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Puch Notification Register" message:messageString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:closeAction];
        
        UIWindow *keyWindow = nil;
        NSSet *connectedScenes = UIApplication.sharedApplication.connectedScenes;
        for (UIScene *scene in connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
            if (keyWindow != nil) {
                break;
            }
        }
                
        [keyWindow.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	[xmlItem appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"error"]) {
		[self message:xmlItem];
	} else if ([elementName isEqualToString:@"okay"]) {
		[self message:xmlItem];
		[Settings set:@"notificationsOn" value:@"yes"];
	} else {
		[xmlItem setString:@""];
	}
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString * errorString = [parseError localizedDescription];
	switch ([parseError code]) {
		case 5: 
			errorString = @"Can't connect to R-U-ON";
			break;
	}
	[self message:errorString];
}


+ (void) registerNotifications:(NSData*)deviceToken {
	NotificationsRegister *nr = [[NotificationsRegister alloc] init:deviceToken];
	[nr registerNotifications];
}

@end
