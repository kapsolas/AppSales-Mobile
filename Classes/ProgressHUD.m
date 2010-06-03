//
//  ProgressHUD.m
//  AppSales
//
//  Created by Ole Zorn on 05.12.08.
//  Copyright 2008 omz:software. All rights reserved.
//

#import "ProgressHUD.h"

@implementation ProgressHUD

static ProgressHUD *sharedHUD = nil;

+ (ProgressHUD *)sharedHUD
{
	if (sharedHUD == nil) {
		sharedHUD = [[ProgressHUD alloc] initWithFrame:CGRectZero];
	}
	
	return sharedHUD;
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
        //self.frame = CGRectMake(0,0,320,480);
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		self.frame = screenBounds;
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
		self.opaque = NO;
		CGSize frameSize = CGSizeMake(200, 125);
		hudFrameView = [[[UIImageView alloc] initWithFrame:CGRectMake(screenBounds.size.width/2 - frameSize.width/2, screenBounds.size.height/2 - frameSize.height/2, frameSize.width, frameSize.height)] autorelease];
		hudFrameView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		hudFrameView.image = [UIImage imageNamed:@"HUDFrame.png"];
		[self addSubview:hudFrameView];
		label = [[[UILabel alloc] initWithFrame:CGRectMake(8, 76, 185, 48)] autorelease];
		label.font = [UIFont boldSystemFontOfSize:18.0];
		label.textAlignment = UITextAlignmentCenter;
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
		label.numberOfLines = 2;
		[hudFrameView addSubview:label];
		UIActivityIndicatorView *activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		activityIndicator.frame = CGRectMake(84,31,32,32);
		[hudFrameView addSubview:activityIndicator];
		[activityIndicator startAnimating];
		self.alpha = 0.0;
    }
    return self;
}

- (void)setText:(NSString *)newText
{
	label.text = newText;
}

- (void)showInViewController:(UIViewController *)vc
{
	[self show];
}

- (void)show
{
	[self removeFromSuperview];
	UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
	self.frame = window.bounds;
	
	[window addSubview:self];
	[UIView beginAnimations:@"fadeIn" context:nil];
	self.alpha = 1.0;
	[UIView commitAnimations];
}

- (void)hide
{
	[UIView beginAnimations:@"fadeOut" context:nil];
	self.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)dealloc 
{
    [super dealloc];
}



@end
