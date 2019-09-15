//
//  RuonTableViewCell.m
//  R-U-ON
//
//  Created by Mendy Barouk on 15/09/2019.
//  Copyright © 2019 ruon. All rights reserved.
//

#import "RuonTableViewCell.h"
#import "Colors.h"

@interface RuonTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *m1Label;
@property (weak, nonatomic) IBOutlet UILabel *m2Label;
@property (weak, nonatomic) IBOutlet UILabel *s1Label;
@property (weak, nonatomic) IBOutlet UILabel *s2Label;

@end

@implementation RuonTableViewCell

- (NSArray<UILabel *> *)allLabels
{
    return @[self.m1Label,self.m2Label,self.s1Label,self.s2Label];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (UILabel *label in [self allLabels])
    {
        label.highlightedTextColor = UIColor.blackColor;
        label.textColor = UIColor.whiteColor;
    }
}

- (void)configureWithData:(NSDictionary *)data type:(NSString *)type
{
    self.backgroundColor = [Colors colorForItem:data];
    NSString* usermessage = [data objectForKey:@"usermessage"];
    if (usermessage) {
        for (UILabel *label in [self allLabels])
        {
            label.text = nil;
        }
        self.m1Label.text = usermessage;
        return;
    } else if ([type isEqualToString:@"alarms"]) {
        self.m1Label.text = [data objectForKey:@"Agent"];
        self.m2Label.text = [data objectForKey:@"Resource"];
        self.s1Label.text = [data objectForKey:@"Description"];
        self.s2Label.text = nil;
    } else if ([type isEqualToString:@"agents"]) {
        self.m1Label.text = [data objectForKey:@"title"];
        NSString *state = [data objectForKey:@"State"];
        if (state && [state isEqualToString:@"OFF"]) {
            self.m1Label.text = [[NSString alloc] initWithFormat:@"%@ (OFF)", self.m1Label.text];
        }
        self.m2Label.text = [data objectForKey:@"Type"];
        self.s1Label.text = [data objectForKey:@"IP"];
        NSString *publicIp = [data objectForKey:@"Public IP"];
        if (publicIp && ![publicIp isEqualToString:self.s1Label.text]) {
            if (self.s1Label.text==nil) {
                self.s1Label.text = publicIp;
            } else {
                self.s1Label.text = [[NSString alloc]initWithFormat:@"%@/%@", self.s1Label.text, publicIp];
            }
        }
        self.s2Label.text = [data objectForKey:@"OS"];
    } else if ([type isEqualToString:@"tickets"]) {
        self.m1Label.text = [data objectForKey:@"Description"];
        self.m2Label.text = nil;
        self.s1Label.text = [[NSString alloc] initWithFormat:@"%@ - %@", [data objectForKey:@"TRK"], [data objectForKey:@"Opened At"]];
        self.s2Label.text = [data objectForKey:@"Opened By"];
    } else {
        self.m1Label.text = self.s1Label.text = @"-";
        self.m2Label.text = self.s2Label.text = nil;
    }
}

@end
