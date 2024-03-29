//
//  CallOutView.m
//  CallOutView
//
//  Created by Hendrik Holtmann on 18.01.10.
//  ported from MonoTouch

#import "CallOutView.h"

@interface CallOutView()
	-(void) initialize;
	-(void) setAnchorPoint:(CGPoint)pt;
	-(void) addButtonTarget:(id)target action:(SEL)selector;
	-(void) showWithAnimiation:(UIView*)parent;
@end


@implementation CallOutView

@synthesize text;
@synthesize userInfo;
#define CENTER_IMAGE_WIDTH  31
#define CALLOUT_HEIGHT  70
#define MIN_LEFT_IMAGE_WIDTH  16
#define MIN_RIGHT_IMAGE_WIDTH  16
#define CENTER_IMAGE_ANCHOR_OFFSET_X  15
#define MIN_ANCHOR_X  MIN_LEFT_IMAGE_WIDTH + CENTER_IMAGE_ANCHOR_OFFSET_X
#define BUTTON_WIDTH  29
#define BUTTON_Y  8
#define LABEL_HEIGHT  48
#define LABEL_FONT_SIZE  18
//#define ANCHOR_X  32
#define ANCHOR_Y  60


#define RECTFRAME CGRectMake (0, 0, 100, CALLOUT_HEIGHT)

static UIImage *CALLOUT_LEFT_IMAGE;
static UIImage *CALLOUT_CENTER_IMAGE;
static UIImage *CALLOUT_RIGHT_IMAGE;

float ANCHOR_X = 32;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self initialize];
    }
    return self;
}

-(id)initWithText:(NSString*)atext point:(CGPoint)point
{
	if (self = [super initWithFrame:RECTFRAME]) {
		[self setAnchorPoint:point];
		[self initialize];
		self.text = atext;
	}	
	return self;
}

-(id)initWithText:(NSString*)atext point:(CGPoint)point target:(id)object action:(SEL)selector
{
	if (self = [super initWithFrame:RECTFRAME]) {
		[self setAnchorPoint:point];
		[self initialize];
		self.text = atext;
		[self addButtonTarget:object action:selector];
	}	
	return self;
}


+ (CallOutView*) addCalloutView:(UIView*)parent text:(NSString*)text point:(CGPoint)pt target:(id)target action:(SEL)selector
{
	CallOutView *callout = [[CallOutView alloc] initWithText:text point:pt target:target action:selector];
	[callout showWithAnimiation:parent];
	return [callout autorelease];
}


-(void) showWithAnimiation:(UIView*)parent
{
	self.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationWillStartSelector:@selector(animationWillStart:context:)];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.1f];
	[parent addSubview:self];
	self.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
	[UIView commitAnimations];
}

- (void)animationWillStart:(NSString *)animationID context:(void *)context
{
	
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	self.transform = CGAffineTransformIdentity;
	
}

-(void)setText:(NSString *)aText{
	calloutLabel.text = aText;
	[calloutLabel setNeedsLayout];
}


- (void) initialize
{
	self.backgroundColor = [UIColor clearColor];
	self.opaque = false;
	
	if (CALLOUT_LEFT_IMAGE == nil) {
		CALLOUT_LEFT_IMAGE = [[[UIImage imageNamed:@"UICalloutViewLeftCap"] stretchableImageWithLeftCapWidth:15 topCapHeight:0] retain];
	}
	
	if (CALLOUT_CENTER_IMAGE == nil) {
		CALLOUT_CENTER_IMAGE = [[UIImage imageNamed:@"UICalloutViewBottomAnchor"] retain];
	}
	
	if (CALLOUT_RIGHT_IMAGE == nil) {
		CALLOUT_RIGHT_IMAGE = [[[UIImage imageNamed:@"UICalloutViewRightCap"] stretchableImageWithLeftCapWidth:1 topCapHeight:0] retain];
	}
	
	CGRect frame = self.frame;
	frame.size.height = CALLOUT_HEIGHT;
	if (frame.size.width < 100)
		frame.size.width = 100;
	self.frame = frame;
	
	if (ANCHOR_X < MIN_ANCHOR_X) {
		ANCHOR_X = MIN_ANCHOR_X;
	}
	
	
	float left_width = ANCHOR_X - CENTER_IMAGE_ANCHOR_OFFSET_X;
	float right_width = frame.size.width - left_width - CENTER_IMAGE_WIDTH;
	
	calloutLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, left_width, CALLOUT_HEIGHT)];
	calloutLeft.image = CALLOUT_LEFT_IMAGE;
	[self addSubview:calloutLeft];
	[calloutLeft release];
	
	calloutCenter = [[UIImageView alloc] initWithFrame:CGRectMake(left_width, 0, CENTER_IMAGE_WIDTH, CALLOUT_HEIGHT)];
	calloutCenter.image = CALLOUT_CENTER_IMAGE;
	[self addSubview:calloutCenter];
	[calloutCenter release];
	
	
	calloutRight = [[UIImageView alloc] initWithFrame:CGRectMake(left_width + CENTER_IMAGE_WIDTH, 0, right_width, CALLOUT_HEIGHT)];
	calloutRight.image = CALLOUT_RIGHT_IMAGE;
	[self addSubview:calloutRight];
	[calloutRight release];
	
	calloutLabel = [[UILabel alloc] initWithFrame:CGRectMake(MIN_LEFT_IMAGE_WIDTH, 0, frame.size.width - - MIN_LEFT_IMAGE_WIDTH - BUTTON_WIDTH - MIN_RIGHT_IMAGE_WIDTH - 2 , LABEL_HEIGHT)];
	calloutLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	calloutLabel.textColor = [UIColor whiteColor];
	calloutLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:calloutLabel];
	[calloutLabel release];
	
	
	calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	CGRect rect = calloutButton.frame;
	rect.origin.x = frame.size.width - BUTTON_WIDTH - MIN_RIGHT_IMAGE_WIDTH + 4;
	rect.origin.y = BUTTON_Y;
	calloutButton.frame = rect;
	calloutButton.adjustsImageWhenHighlighted = NO;
	[self addSubview:calloutButton];	
}


- (void) layoutSubviews
{
	[super layoutSubviews];
	
	CGSize size = [calloutLabel.text sizeWithFont:calloutLabel.font];
	
	CGRect frame = self.frame;
	frame.size.width = size.width + MIN_LEFT_IMAGE_WIDTH + BUTTON_WIDTH + MIN_RIGHT_IMAGE_WIDTH + 3;
	frame.size.height = CALLOUT_HEIGHT;
	self.frame = frame;
	
	if (ANCHOR_X < MIN_ANCHOR_X) {
		ANCHOR_X =  MIN_ANCHOR_X;
	}
	
	float left_width = ANCHOR_X - CENTER_IMAGE_ANCHOR_OFFSET_X;
	float right_width = frame.size.width - left_width - CENTER_IMAGE_WIDTH;
	
	calloutLeft.frame = CGRectMake(0, 0, left_width, CALLOUT_HEIGHT-13);
	calloutCenter.frame = CGRectMake(left_width, 0, CENTER_IMAGE_WIDTH, CALLOUT_HEIGHT);
	calloutRight.frame = CGRectMake(left_width+CENTER_IMAGE_WIDTH, 0, right_width, CALLOUT_HEIGHT-13);
	calloutLabel.frame = CGRectMake(MIN_LEFT_IMAGE_WIDTH, 0, size.width, LABEL_HEIGHT);
	
	CGRect f = calloutButton.frame;
	f.origin.x = frame.size.width - BUTTON_WIDTH - MIN_RIGHT_IMAGE_WIDTH + 4;
	f.origin.y = BUTTON_Y;
	calloutButton.frame = f;
    
	
}




-(void) setAnchorPoint:(CGPoint)pt {
	self.frame = CGRectMake(pt.x - ANCHOR_X, pt.y - ANCHOR_Y, self.frame.size.width, self.frame.size.height);
}

- (void) addButtonTarget:(id)target action:(SEL)selector
{
	[calloutButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}


- (void)dealloc {
	[text release];
    [userInfo release];
	text = nil;

    [super dealloc];
}


@end
