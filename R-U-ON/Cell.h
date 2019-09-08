#import <UIKit/UIKit.h>

@class CellView;

@interface Cell : UITableViewCell {
	CellView *cellView;
}

@property (nonatomic, retain) CellView *cellView;
- (void) setData:(NSDictionary *)data type:(NSString *)type;
- (void) setNeedsDisplay;	

@end
