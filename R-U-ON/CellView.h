
#import <UIKit/UIKit.h>


@interface CellView : UIView {
	BOOL highlighted;
	NSDictionary *data;
	NSString *s1,*s2,*m1,*m2, *usermessage;
	UIColor *bgColor;
}

@property (nonatomic, getter=isHighlighted) BOOL highlighted;
- (void) setData:(NSDictionary *)aData type:(NSString *)type;

@end
