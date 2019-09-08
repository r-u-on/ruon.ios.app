//
//  LoginView.h
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/1/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIViewController<NSXMLParserDelegate>

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *throbber;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *errMessage;
@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UILabel *copyright;

@end
