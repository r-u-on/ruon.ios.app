//
//  Tabs.m
//  R-U-ON
//
//  Created by YUVAL PERLOV on 1/3/14.
//  Copyright (c) 2014 ruon. All rights reserved.
//

#import "Tabs.h"
#import "Settings.h"
#import "Colors.h"

@interface TabsDelegate :NSObject<UITabBarControllerDelegate>

@end
@implementation TabsDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [Settings set:@"activetab" value:@((int)tabBarController.selectedIndex)];
}
@end


@implementation Tabs {
    TabsDelegate *tabsDelegate;
}

static Tabs *tabs;

+(void) badgeUpdate {
    
    if (tabs) {
        UITabBarItem *alarmsTabItem = tabs.tabBar.items[0];
        NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
        alarmsTabItem.badgeValue = badge==0?nil:[NSString stringWithFormat:@"%ld", (long)badge];
    }
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tintColor = MY_TINT;
    self.delegate = tabsDelegate = [[TabsDelegate alloc] init];
    id at = [Settings get:@"activetab"];
    if (at) {
        self.selectedIndex = [at integerValue];
    }
    
    tabs = self;
    [Tabs badgeUpdate];
}




@end
