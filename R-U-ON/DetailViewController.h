
#import <UIKit/UIKit.h>
#import "Settings.h"

@interface DetailViewController : UITableViewController 

-(DetailViewController*)initWithData:(NSDictionary*)record type:(NSString*)type;

@end
