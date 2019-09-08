
#import "CellView.h"
#import "Colors.h"

@implementation CellView

@synthesize highlighted;


- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		self.opaque = YES;
		data = nil;
		m1 = m2 = s1 = s2 = nil;
	}
	return self;
}

- (void)setHighlighted:(BOOL)lit {
	if (highlighted != lit) {
		highlighted = lit;	
		[self setNeedsDisplay];
	}
}


typedef enum {		
    left = 0,
    right,   
    center
} Align;

- (void)drawText:(NSString*)text font:(UIFont *)font atPoint:(CGPoint)atPoint width:(int) width align:(Align)align color:(UIColor*) color {
    
    
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attr = @{
               NSFontAttributeName:font,
               NSParagraphStyleAttributeName:ps,
               NSForegroundColorAttributeName:color
               };
    
    CGSize size = [text sizeWithAttributes:attr];
	if (align!=left) {
		if (size.width<width) {
			atPoint.x = atPoint.x + (width - size.width)/(align==right?1:2);
		}
	}
    
    [text drawWithRect: CGRectMake(atPoint.x, atPoint.y, width, size.height)
                 options:NSStringDrawingUsesLineFragmentOrigin
              attributes:attr
                 context:nil];
}

- (void)drawRect:(CGRect)rect {
	

//	static UIImage *bg = nil; 
//	if (bg==nil) {
//		bg = [UIImage imageNamed:@"glassify.png"];
//	}
//	[bg drawAtPoint:CGPointMake(0,0)];


#define PADDINGX 10
	
#define UPPER_ROW_TOP 8
#define LOWER_ROW_TOP 34
#define USERMESSAGE_TOP 17
	
#define MAIN_FONT_SIZE 18
#define SECONDARY_FONT_SIZE 12

	// Color and font for the main text items (time zone name, time)
	UIColor *color = nil;
	UIFont *mainFont = [UIFont systemFontOfSize:MAIN_FONT_SIZE];

	// Color and font for the secondary text items (GMT offset, day)

	UIFont *secondaryFont = [UIFont systemFontOfSize:SECONDARY_FONT_SIZE];
	
	[self setBackgroundColor:bgColor];

	
	// Choose font color based on highlighted state.
    color = self.highlighted ? [UIColor blackColor]:[UIColor whiteColor];
	
	CGRect contentRect = self.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGFloat boundsW = contentRect.size.width - 2*PADDINGX;
	CGPoint point;

	point.x = boundsX + PADDINGX;
	
	if (usermessage) {
		point.y = USERMESSAGE_TOP;
		[self drawText:usermessage font:mainFont atPoint:point width:boundsW align:center color:color];
		return;
	}
	point.y = UPPER_ROW_TOP;
	[self drawText:m1 font:mainFont atPoint:point width:m2?boundsW/2:boundsW align:left color:color];

	if (m2) {
		point.x = boundsX + PADDINGX + boundsW/2 + PADDINGX;
		[self drawText:m2 font:mainFont atPoint:point width:boundsW/2-PADDINGX align:right color:color];
	}
	
	point.x = boundsX + PADDINGX;
	point.y = LOWER_ROW_TOP;
	[self drawText:s1 font:secondaryFont atPoint:point width:s2?boundsW/2:boundsW align:left color:color];
	
	if (s2) {
		point.x = boundsX + PADDINGX + boundsW/2 + PADDINGX;
		[self drawText:s2 font:secondaryFont atPoint:point width:boundsW/2-PADDINGX align:right color:color];
	}
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextSetLineWidth(currentContext, 0.5f);
    CGContextSetRGBStrokeColor(currentContext, 0.0f, 0.0f, 0.0f, 0.2f);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, 0, rect.size.height);
    CGContextAddLineToPoint(currentContext, rect.size.width, rect.size.height);
    CGContextStrokePath(currentContext);
    CGContextRestoreGState(currentContext);
}

- (void) setData:(NSDictionary *)aData type:(NSString*)type{
	if (data != aData) {
		data = aData;
		
		usermessage = [data objectForKey:@"usermessage"];
		if (usermessage) {
			m1 = m2 = s1 = s2 = nil;
		} else if ([type isEqualToString:@"alarms"]) {
			m1 = [data objectForKey:@"Agent"];
			m2 = [data objectForKey:@"Resource"];
			s1 = [data objectForKey:@"Description"];
			s2 = nil;
		} else if ([type isEqualToString:@"agents"]) {
			m1 = [data objectForKey:@"title"];
			NSString *state = [data objectForKey:@"State"];
			if (state && [state isEqualToString:@"OFF"]) {
				m1 = [[NSString alloc] initWithFormat:@"%@ (OFF)", m1];
			}
			m2 = [data objectForKey:@"Type"];
			s1 = [data objectForKey:@"IP"];
			NSString *publicIp = [data objectForKey:@"Public IP"];
			if (publicIp && ![publicIp isEqualToString:s1]) {
				if (s1==nil) {
					s1 = publicIp;
				} else {
					s1 = [[NSString alloc]initWithFormat:@"%@/%@", s1, publicIp];
				}
			}
			s2 = [data objectForKey:@"OS"];
		} else if ([type isEqualToString:@"tickets"]) {
			m1 = [data objectForKey:@"Description"];
			m2 = nil;
			s1 = [[NSString alloc] initWithFormat:@"%@ - %@", [data objectForKey:@"TRK"], [data objectForKey:@"Opened At"]];
			s2 = [data objectForKey:@"Opened By"];
		} else {
			m1 = s1 = @"-";
			m2 = s2 = nil;
		}

		bgColor = [Colors colorForItem:data];

		[self setBackgroundColor:bgColor];
		[self setNeedsDisplay];
	}
}



@end
