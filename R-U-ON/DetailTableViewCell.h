//
//  DetailTableViewCell.h
//  R-U-ON
//
//  Created by Mendy Barouk on 12/09/2019.
//  Copyright © 2019 ruon. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

NS_ASSUME_NONNULL_END
