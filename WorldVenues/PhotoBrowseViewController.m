//
//  PhotoBrowseViewController.m
//  WorldVenues
//
//  Created by David Engler on 11/5/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>

#import "PhotoBrowseViewController.h"
#import "PhotoModel.h"
#import "WebService.h"
#import "ViewController.h"

#define THUMBNAIL_SIZE (40)
#define THUMBNAIL_SPACING (12)
#define SELECTED_THUMBNAIL_SCALE (1.3)

@interface PhotoBrowseViewController () <UIScrollViewDelegate>
@property NSMutableArray *isImageLoaded;
@end

@implementation PhotoBrowseViewController

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
//	[self changeFontsInView:self.view];
    [self loadPhotos];
}

- (void) loadPhotos
{
    CGSize contentSize = _mainScrollView.contentSize;
    contentSize.width = [_photos count] * 1024;
    _mainScrollView.contentSize = contentSize;
    
    contentSize = _bottomScrollView.contentSize;
    contentSize.width = [_photos count] * (THUMBNAIL_SIZE+THUMBNAIL_SPACING);
    _bottomScrollView.contentSize = contentSize;
    
    int max_thumbnails = _bottomScrollView.frame.size.width / (THUMBNAIL_SIZE+THUMBNAIL_SPACING);
    if ([_photos count] < max_thumbnails)
    {
        UIEdgeInsets sz = _bottomScrollView.contentInset;
        sz.left = (THUMBNAIL_SIZE+THUMBNAIL_SPACING) * (max_thumbnails - [_photos count]);
        _bottomScrollView.contentInset = sz;
    }
    
    _isImageLoaded = [[NSMutableArray alloc] initWithCapacity:[_photos count]];
    
    for (int i=0; i<[_photos count]; i++)
    {
        [_isImageLoaded setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:i];
        PhotoModel *photo = [[_photos allObjects] objectAtIndex:i];
        [self showFlickrThumbImage:photo.flickrID atIndex:[photo.order intValue]];
    }
    
    [self selectPhotoAtIndex:0];
}

- (void)showFlickrThumbImage:(NSNumber *)photo_id atIndex:(int)i
{
    NSString *api_key = @"8146d1f5ee6dd1ddea68bbddf8fb5765";
    NSString *auth_token = @"72157631893050725-ff69eb74958563e9";
    NSString *secret = @"02769559a6768be1";
    NSString *api_sig = [self md5:[NSString stringWithFormat:@"%@api_key%@auth_token%@formatjsonmethodflickr.photos.getInfonojsoncallback1photo_id%@", secret, api_key, auth_token, photo_id]];
    NSURL* jsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1&auth_token=%@&api_sig=%@", api_key, photo_id, auth_token, api_sig]];
    
	[self.spinner startAnimating];
    WebService* webService = [[WebService alloc] init];
	[webService beginRequestWithURL:jsonUrl finished:^(NSData* thumbResponse) {
		
		[self.spinner stopAnimating];
		
		if (thumbResponse == nil)
			return;
		
		NSString* json = [[NSString alloc] initWithData:thumbResponse encoding:NSASCIIStringEncoding];
		
		NSData* data =[json dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        NSDictionary* array = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        NSArray* photo = [array objectForKey:@"photo"];
        if (photo != nil)
        {
            NSString *url = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",
                             [photo valueForKey:@"farm"], [photo valueForKey:@"server"],
                             [photo valueForKey:@"id"], [photo valueForKey:@"secret"]];
            
			[self.spinner startAnimating];
            NSURL * imageURL = [NSURL URLWithString:url];
            WebService* webService = [[WebService alloc] init];
            [webService beginRequestWithURL:imageURL finished:^(NSData* responseData)
             {
				 [self.spinner stopAnimating];
				 
                 if (responseData != nil) {
                     UIImage * image = [UIImage imageWithData:responseData];
                     UIButton *thumbButton = [[UIButton alloc] init];
                     [thumbButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                     [thumbButton setImage:image forState:UIControlStateNormal];
                     thumbButton.frame = CGRectMake(i*(THUMBNAIL_SIZE+THUMBNAIL_SPACING),0,THUMBNAIL_SIZE,THUMBNAIL_SIZE);
					 thumbButton.tag = i;
					 
					 if (i == 0)
					 {
						 thumbButton.transform = CGAffineTransformMakeScale(SELECTED_THUMBNAIL_SCALE, SELECTED_THUMBNAIL_SCALE);
					 }
                     
                     thumbButton.layer.borderWidth = 2.0;
                     thumbButton.layer.borderColor = [UIColor whiteColor].CGColor;
                     
                     [self.bottomScrollView addSubview:thumbButton];
					 
					 // Adjust width of title
					 CGRect titleRect = self.titleLabel.frame;
					 CGPoint thumbOrigin = [self.titleLabel.superview convertPoint:thumbButton.frame.origin fromView:thumbButton.superview];
					 titleRect.size.width = MIN(titleRect.size.width, thumbOrigin.x - titleRect.origin.x - 20);
					 self.titleLabel.frame = titleRect;
                 }
             }];
        }
	}];
}

- (void)showFlickrImage:(NSNumber *)photo_id atIndex:(int)i
{
    [_isImageLoaded setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:i];
    
    NSString *api_key = @"8146d1f5ee6dd1ddea68bbddf8fb5765";
    NSString *auth_token = @"72157631893050725-ff69eb74958563e9";
    NSString *secret = @"02769559a6768be1";
    NSString *api_sig = [self md5:[NSString stringWithFormat:@"%@api_key%@auth_token%@formatjsonmethodflickr.photos.getInfonojsoncallback1photo_id%@", secret, api_key, auth_token, photo_id]];
    NSURL* jsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1&auth_token=%@&api_sig=%@", api_key, photo_id, auth_token, api_sig]];
    
	[self.spinner startAnimating];
    WebService* webService = [[WebService alloc] init];
	[webService beginRequestWithURL:jsonUrl finished:^(NSData* thumbResponse) {
		[self.spinner stopAnimating];
		if (thumbResponse == nil)
			return;
		
		NSString* json = [[NSString alloc] initWithData:thumbResponse encoding:NSASCIIStringEncoding];
		
		NSData* data =[json dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        NSDictionary* array = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        NSArray* photo = [array objectForKey:@"photo"];
        if (photo != nil)
        {
            NSString *url = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_b.jpg",
                             [photo valueForKey:@"farm"], [photo valueForKey:@"server"],
                             [photo valueForKey:@"id"], [photo valueForKey:@"secret"]];
            
			[self.spinner stopAnimating];
            NSURL * imageURL = [NSURL URLWithString:url];
            WebService* webService = [[WebService alloc] init];
            [webService beginRequestWithURL:imageURL finished:^(NSData* responseData)
             {
				 [self.spinner stopAnimating];
                 if (responseData != nil) {
                    UIImage * image = [UIImage imageWithData:responseData];
                    UIImageView *imageViewLarge = [[UIImageView alloc] initWithImage:image];
					imageViewLarge.tag = i;
                    imageViewLarge.contentMode = UIViewContentModeScaleAspectFill;
					 imageViewLarge.clipsToBounds = YES;
                    imageViewLarge.frame = CGRectMake(i*1024,0,1024,748);
					 imageViewLarge.alpha = 0;

                    [self.mainScrollView addSubview:imageViewLarge];
					 
					 [UIView animateWithDuration:0.2 animations:^{
						 imageViewLarge.alpha = 1;
					 }];
                 }
             }];
        }
	}];
}

- (void)buttonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int i = button.tag;
    [self.mainScrollView setContentOffset:CGPointMake(i*1024,0) animated:YES];
    [self selectPhotoAtIndex:i];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (scrollView == self.mainScrollView)
	{
		int i = self.mainScrollView.contentOffset.x / 1024;
		[self selectPhotoAtIndex:i];
	}
}

- (void)selectPhotoAtIndex:(int)i
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order == %d", i];
    NSArray *filteredArray = [[_photos allObjects] filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] == 0)
    {
        NSLog(@"Error");
        return;
    }
    
    PhotoModel *photo = [filteredArray objectAtIndex:0];
    self.titleLabel.text = [photo title];
    self.infoLabel.text = [NSString stringWithFormat:@"%@ | %@ | %@", photo.attribution, photo.source, photo.license];
    if ([[_isImageLoaded objectAtIndex:i] boolValue] == NO)
    {
        [self showFlickrImage:photo.flickrID atIndex:i];
    }
	
	for (UIButton* button in self.bottomScrollView.subviews)
	{
		if ([button isKindOfClass:[UIButton class]] == NO)
			continue;
		
		int buttonIdx = button.tag;
		if (buttonIdx == i)
		{
			button.transform = CGAffineTransformMakeScale(SELECTED_THUMBNAIL_SCALE, SELECTED_THUMBNAIL_SCALE);
			[self.bottomScrollView bringSubviewToFront:button];
		}
		else
		{
			button.transform = CGAffineTransformMakeScale(1, 1);
		}
				
	}
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (IBAction)closeMe
{
	[UIView animateWithDuration:0.25
					 animations:^{
						 self.view.alpha = 0;
					 }
					 completion:^(BOOL finished) {
						 [self.view removeFromSuperview];
                         ViewController *rootVC = (ViewController *)[[ModelManager sharedModelManager] rootVC];
                         rootVC.pbvc = nil;
					 }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (void)viewDidUnload {
	[self setSpinner:nil];
	[super viewDidUnload];
}
@end
