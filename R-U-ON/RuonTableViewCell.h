//
//  RuonTableViewCell.h
//  R-U-ON
//
//  Created by Mendy Barouk on 15/09/2019.
//  Copyright © 2019 ruon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RuonTableViewCell : UITableViewCell

- (void)configureWithData:(NSDictionary *)data type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
