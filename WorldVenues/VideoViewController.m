//
//  VideoViewController.m
//  WorldVenues
//
//  Created by David Engler on 9/27/12.
//
//

#import <QuartzCore/QuartzCore.h>

#import "VideoViewController.h"
#import "VideoModel.h"
#import "ViewController.h"
#import "GANTracker.h"

@interface VideoViewController ()

@end

@implementation VideoViewController

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
    [self.toolBar setBackgroundImage:[UIImage imageNamed:@"TitleBarBackground.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    self.containerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BgPaper.png"]];
    
	self.containerView.layer.shadowOpacity = 1;
	self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.containerView.layer.shadowRadius = 10;
	
	[self changeFontsInView:self.view];
	
    [self loadVideo];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Analytics
	NSError* error = nil;
    VideoModel *video = [[_videos allObjects] objectAtIndex:_playIndex];	
	if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/video/%@", video.url]
										 withError:&error])
	{
		NSLog(@"error in trackPageview");
	}
	
}

- (void)loadVideo
{
    VideoModel *video = [[_videos allObjects] objectAtIndex:_playIndex];
    
    NSString *videoUrl;
    if ([video.url rangeOfString:@"vimeo"].location != NSNotFound) {
        videoUrl = [NSString stringWithFormat:@"http://player.vimeo.com/video/%@", video.id];
    } else {
        videoUrl = [NSString stringWithFormat:@"http://www.youtube.com/embed/%@", video.id];
    }
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:videoUrl];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
    [_urlLabel setText:video.url];
    [_titleLabel setText:[video.title uppercaseString]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (IBAction)closeMe
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self.view removeFromSuperview];
    ViewController *rootVC = (ViewController *)[[ModelManager sharedModelManager] rootVC];
    rootVC.vvc = nil;
}

- (IBAction)nextVideo
{
    _playIndex++;
    if (_playIndex >= _videos.count) _playIndex=0;
    [self loadVideo];
}

- (IBAction)prevVideo
{
    _playIndex--;
    if (_playIndex < 0) _playIndex = _videos.count - 1;
    [self loadVideo];
}

-(void)changeFontsInView:(UIView*)view
{
	// Will also do UIButton label recursively
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
	
	for (UIView* subView in view.subviews)
	{
		[self changeFontsInView:subView];
	}
}


@end
