//
//  AboutViewController.m
//  WorldVenues
//
//  Created by David Engler on 8/29/12.
//
//

#import <QuartzCore/QuartzCore.h>

#import "AboutViewController.h"
#import "ViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *urlAddress = @"http://worldvenu.es/about/";
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
    
	self.view.layer.shadowColor = [UIColor blackColor].CGColor;
	self.view.layer.shadowRadius = 5;
	self.view.layer.shadowOpacity = 0.5;
	self.view.clipsToBounds = NO;
	self.view.layer.shadowOffset = CGSizeMake(-5, 0);

}

-(void)changeFonts
{
	for (UIView* view in self.view.subviews)
	{
		if ([view isKindOfClass:[UILabel class]])
		{
			UILabel* label = (UILabel*)view;
			NSLog(@"%@", label.font.fontName);
			
			if ([label.font.fontName rangeOfString:@"Bold"].location != NSNotFound)
			{
				label.font = [UIFont fontWithName:@"Archer-Bold" size:label.font.pointSize];
			}
			else
			{
				label.font = [UIFont fontWithName:@"Archer-Medium" size:label.font.pointSize];
			}
			
		}
		else if ([view isKindOfClass:[UITextView class]])
		{
			UITextView* textView = (UITextView*)view;
			textView.font = [UIFont fontWithName:@"Archer-Book" size:textView.font.pointSize];
		}
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self zoomToFit];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"expected:%d, got:%d", UIWebViewNavigationTypeLinkClicked, navigationType);
	if (navigationType == UIWebViewNavigationTypeLinkClicked)  {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	
	return YES;
}


-(void)zoomToFit
{    
    if ([webView respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scroll=[webView scrollView];
        
        float zoom=webView.bounds.size.width/scroll.contentSize.width;
        [scroll setZoomScale:zoom animated:YES];
    }
}

- (IBAction) hideMe
{
    ViewController *rootVC = (ViewController *)[[ModelManager sharedModelManager] rootVC];
    [rootVC about];
}

#pragma mark - Gesture

- (IBAction)swipeAction:(id)sender
{
	[self hideMe];
}


@end
