
#import <UIKit/UIKit.h>
#import "Settings.h"

@interface DetailViewController : UITableViewController 

- (void)bindWithRecord:(NSDictionary*)record type:(NSString*)type;

@end
