//
//  VenueViewController.m
//  WorldVenues
//
//  Created by David Engler on 8/26/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>

#import "VenueViewController.h"
#import "PhotoModel.h"
#import "VideoModel.h"
#import "ResidentArtistModel.h"
#import "WebService.h"
#import "ModelManager.h"
#import "ViewController.h"
#import "GANTracker.h"

#define SPACE_BETWEEN_LABEL (15)

@interface VenueViewController () <UIGestureRecognizerDelegate>

@end

@implementation VenueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setVenue:(VenueModel *)venue
{
    _venue = venue;
    [self updateVenueInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self updateVenueInfo];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"PaperTile"]];
	
	self.view.layer.shadowColor = [UIColor blackColor].CGColor;
	self.view.layer.shadowRadius = 5;
	self.view.layer.shadowOpacity = 0.5;
	self.view.clipsToBounds = NO;
	self.view.layer.shadowOffset = CGSizeMake(-5, 0);

	[self changeFontsInView:self.view];
    
    [self moveViews:@[self.funFactLabel, self.funFactHeaderLabel] byLength:SPACE_BETWEEN_LABEL];
    [self moveViews:@[self.notableNotesLabel, self.notableNotesHeaderLabel] byLength:SPACE_BETWEEN_LABEL * 2];
    [self moveViews:@[self.firstPerformanceLabel, self.firstPerformanceHeaderLabel] byLength:SPACE_BETWEEN_LABEL * 3];
    [self moveViews:@[self.residentArtistHeaderLabel, self.residentArtistLabel] byLength:SPACE_BETWEEN_LABEL * 4];
    [self moveViews:@[self.websiteLink] byLength:SPACE_BETWEEN_LABEL * 5];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
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

- (void)updateVenueInfo
{
    if (!_venue) return;
	
	[self.scrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
	
    [self.nameLabel setText:[self.venue.name uppercaseString]];
    [self.addressLabel setText:self.venue.address];
    [self.websiteLink setTitle:self.venue.website forState:UIControlStateNormal];
    [self.openedLabel setText:self.venue.opened];
    [self.seatsLabel setText:[self.venue.seats stringValue]];
    [self.seatingLabel setText:self.venue.seating];
    
    [self.performancePerYearLabel setText:[self.venue.performancePerYear stringValue]];
    [self.firstPerformanceLabel setText:self.venue.firstPerformance];
    [self.funFactLabel setText:self.venue.funFact];
    [self.notableNotesLabel setText:self.venue.notableNotes];
    [self.famousPerformanceLabel setText:self.venue.famousPerformance];
    [self.funFactLabel setText:self.venue.funFact];
    [self.favoriteButton setImage:[UIImage imageNamed:@"BtnFavoriteYes.png"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"BtnFavoriteNo.png"] forState:UIControlStateNormal];
    [self.favoriteButton setSelected:[self.venue.favorited boolValue]];
    [self.visitedButton setImage:[UIImage imageNamed:@"BtnVisitedYes.png"] forState:UIControlStateSelected];
    [self.visitedButton setImage:[UIImage imageNamed:@"BtnVisitedNo.png"] forState:UIControlStateNormal];
    [self.visitedButton setSelected:[self.venue.visited boolValue]];
    
    [self setLabelText:self.architectLabel withData:self.venue.architect andMoveViews:@[self.styleLabel, self.styleHeaderLabel]];
    [self setLabelText:self.styleLabel withData:self.venue.style andMoveViews:nil];
    [self setLabelText:self.residentArtistLabel withData:self.venue.residentArtist andMoveViews:@[self.websiteLink]];
    
    for(PhotoModel *photo in _venue.photos)
    {
        if ([photo.order intValue] == 0)
        {
            [self showFlickrImage:photo.flickrID];
            break;
        }
    }
    
    [self setVideoThumb:0 forImage:self.videoThumbImage1];
    [self setVideoThumb:1 forImage:self.videoThumbImage2];
    [self setVideoThumb:2 forImage:self.videoThumbImage3];
    [self setVideoThumb:3 forImage:self.videoThumbImage4];
    [self setVideoThumb:4 forImage:self.videoThumbImage5];
    [self setVideoThumb:5 forImage:self.videoThumbImage6];
    
    [self fitLabel:self.funFactLabel andMoveViews:@[self.firstPerformanceLabel, self.notableNotesLabel, self.notableNotesHeaderLabel, self.firstPerformanceHeaderLabel, self.residentArtistHeaderLabel, self.residentArtistLabel, self.websiteLink]];
    [self fitLabel:self.notableNotesLabel andMoveViews:@[self.firstPerformanceLabel, self.firstPerformanceHeaderLabel, self.residentArtistHeaderLabel, self.residentArtistLabel, self.websiteLink]];
    [self fitLabel:self.firstPerformanceLabel andMoveViews:@[self.residentArtistHeaderLabel, self.residentArtistLabel, self.websiteLink]];
    
    if (_venue.videos.count <= 3)
    {
         [self moveViews:@[self.funFactLabel, self.notableNotesLabel, self.firstPerformanceLabel,
         self.funFactHeaderLabel, self.notableNotesHeaderLabel, self.firstPerformanceHeaderLabel, self.residentArtistHeaderLabel, self.residentArtistLabel, self.websiteLink] byLength:(self.videoThumbImage4.frame.origin.y - self.funFactHeaderLabel.frame.origin.y)];
    }
	else if (_venue.videos.count > 3)
    {
        [self moveViews:@[self.funFactLabel, self.notableNotesLabel, self.firstPerformanceLabel,
         self.funFactHeaderLabel, self.notableNotesHeaderLabel, self.firstPerformanceHeaderLabel, self.residentArtistHeaderLabel, self.residentArtistLabel, self.websiteLink] byLength:(self.videoThumbImage4.frame.origin.y * 2 - self.videoThumbImage1.frame.origin.y - self.funFactHeaderLabel.frame.origin.y)];
    }
    
    self.scrollView.contentSize = CGSizeMake(600, self.websiteLink.frame.origin.y + self.websiteLink.frame.size.height + 2 * SPACE_BETWEEN_LABEL);
	
	// Analytics
	NSError* error = nil;
	if (![[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/venue/%@", self.venue.name]
										 withError:&error])
	{
		NSLog(@"error in trackPageview");
	}
	
}

- (void)setLabelText:(UILabel *)label withData:(id)data andMoveViews:(NSArray *)viewsToMove
{
    NSEnumerator *e = [data objectEnumerator];
    int len = [data count];
    NSMutableString *ms = [[NSMutableString alloc] init];
    id a;
    int c = 0;
    while ((a = [e nextObject]) != nil)
    {
        [ms appendString:[a name]];
        if (++c < len) [ms appendString:@", "];
    }
    
    [label setText:ms];
    
    [self fitLabel:label andMoveViews:viewsToMove];
}

- (void)fitLabel:(UILabel *)label andMoveViews:(NSArray *)viewsToMove
{
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width,999);
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    [self moveViews:viewsToMove byLength:(newFrame.size.height - label.frame.size.height)];
    label.frame = newFrame;
}

- (void)moveViews:(NSArray *)viewsToMove byLength:(int)yMove
{
    for (UIView* v in viewsToMove)
    {
        CGRect frame = v.frame;
        frame.origin.y += yMove;
        v.frame = frame;
    }
}

- (void)setVideoThumb:(int)videoIndex forImage:(UIButton *)button
{
    if (videoIndex >= _venue.videos.count)
    {
        [button setHidden:YES];
        return;
    }
    [button setHidden:NO];
    VideoModel *video = [[_venue.videos allObjects] objectAtIndex:videoIndex];
    
	if (video == nil || video.url == nil || [video.url isEqualToString:@""])
		return;
	
    NSRange range1 = [video.url rangeOfString:@"=" options:NSBackwardsSearch];
    NSRange range2 = [video.url rangeOfString:@"/" options:NSBackwardsSearch];
    video.id = (range1.location != NSNotFound) ? [video.url substringFromIndex:range1.location+1] : [video.url substringFromIndex:range2.location+1];
    if ([video.url rangeOfString:@"vimeo"].location != NSNotFound) {
        [self setVimeoThumbImage:video forImage:button];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", video.id];
    NSURL * imageURL = [NSURL URLWithString:url];
    WebService* webService = [[WebService alloc] init];
    [webService beginRequestWithURL:imageURL finished:^(NSData* responseData)
    {
        if (responseData != nil) {
            UIImage * image = [UIImage imageWithData:responseData];
            [button setImage:image forState:UIControlStateNormal];
        }
    }];
    
    NSURL* jsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos/%@?v=2&alt=jsonc", video.id]];
	WebService* webService2 = [[WebService alloc] init];
    [webService2 beginRequestWithURL:jsonUrl finished:^(NSData* thumbResponse)
    {
		if (thumbResponse == nil)
			return;
		
		NSString* json = [[NSString alloc] initWithData:thumbResponse encoding:NSUTF8StringEncoding];
		NSLog(@"JSON Data:\r%@", json); 		// For debugging
		
		NSData* data =[json dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        NSArray* array = (NSArray*) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        video.title = [[array valueForKey:@"data"] valueForKey:@"title"];
    }];
}

- (void)setVimeoThumbImage:(VideoModel *)video forImage:(UIButton *)button
{
    NSURL* vimeoJsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://vimeo.com/api/v2/video/%@.json", video.id]];
    WebService* webService = [[WebService alloc] init];
	[webService beginRequestWithURL:vimeoJsonUrl finished:^(NSData* thumbResponse) {
		
		if (thumbResponse == nil)
			return;
		
		NSString* videoJson = [[NSString alloc] initWithData:thumbResponse encoding:NSASCIIStringEncoding];
		NSLog(@"Playlists JSON Data:\r%@", videoJson); 		// For debugging
		
		NSData* data =[videoJson dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error = nil;
        NSArray* array = (NSArray*) [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        video.title = [[array valueForKey:@"title"] objectAtIndex:0];
        NSString *url = [[array valueForKey:@"thumbnail_medium"] objectAtIndex:0];
        NSURL * imageURL = [NSURL URLWithString:url];
        WebService* webService = [[WebService alloc] init];
        [webService beginRequestWithURL:imageURL finished:^(NSData* responseData)
         {
             if (responseData != nil) {
                 UIImage * image = [UIImage imageWithData:responseData];
                 [button setImage:image forState:UIControlStateNormal];
             }
         }];
	}];
}

- (void)showFlickrImage:(NSNumber *)photo_id
{
    [self.flickrImage setImage:nil forState:UIControlStateNormal];
    
    NSString *api_key = @"8146d1f5ee6dd1ddea68bbddf8fb5765";
    NSString *auth_token = @"72157631893050725-ff69eb74958563e9";
    NSString *secret = @"02769559a6768be1";
    NSString *api_sig = [self md5:[NSString stringWithFormat:@"%@api_key%@auth_token%@formatjsonmethodflickr.photos.getInfonojsoncallback1photo_id%@", secret, api_key, auth_token, photo_id]];
    NSURL* jsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1&auth_token=%@&api_sig=%@", api_key, photo_id, auth_token, api_sig]];
    // NSLog(@"Flickr Image Json URL:\r%@", jsonUrl);
    
	[self.flickrImage setBackgroundImage:nil forState:UIControlStateNormal];
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
            NSString *url = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_q.jpg",
                [photo valueForKey:@"farm"], [photo valueForKey:@"server"],
                [photo valueForKey:@"id"], [photo valueForKey:@"secret"]];
            // NSLog(@"Flickr Image URL:\r%@", url);
            
            NSURL * imageURL = [NSURL URLWithString:url];
            WebService* webService = [[WebService alloc] init];
            [webService beginRequestWithURL:imageURL finished:^(NSData* responseData)
             {
                 if (responseData != nil) {
                     UIImage * image = [UIImage imageWithData:responseData];
//                     [[self.flickrImage imageView] setContentMode:UIViewContentModeScaleToFill];
                     [self.flickrImage setBackgroundImage:image forState:UIControlStateNormal];
                 }
             }];
        }
	}];
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
/*
- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{

}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
    
}
*/
- (void)viewDidUnload
{
	[self setScrollView:nil];
	[self setSpinner:nil];
	[self setLeftBorderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction) hideMe
{
    CGRect frame = self.view.frame;
    frame.origin.x += frame.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = frame;
    }];
}

- (IBAction)setFavorite
{
	_venue.favorited = @(![_venue.favorited boolValue]);
	[self.favoriteButton setSelected:[self.venue.favorited boolValue]];
	
	[self.delegate venueViewController:self favorited:[_venue.favorited boolValue] venue:self.venue];
}

- (IBAction)setVisited
{
    _venue.visited = @(![_venue.visited boolValue]);
    self.visitedButton.selected = [self.venue.visited boolValue];
	
	[self.delegate venueViewController:self visited:[_venue.visited boolValue] venue:self.venue];
}

- (IBAction) playVideo:(id)sender
{
    ViewController *rootVC = (ViewController *)[[ModelManager sharedModelManager] rootVC];
    if (sender == self.videoThumbImage1) [rootVC playVideo:_venue.videos atIndex:0];
    if (sender == self.videoThumbImage2) [rootVC playVideo:_venue.videos atIndex:1];
    if (sender == self.videoThumbImage3) [rootVC playVideo:_venue.videos atIndex:2];
    if (sender == self.videoThumbImage4) [rootVC playVideo:_venue.videos atIndex:3];
    if (sender == self.videoThumbImage5) [rootVC playVideo:_venue.videos atIndex:4];
    if (sender == self.videoThumbImage6) [rootVC playVideo:_venue.videos atIndex:5];
}

- (IBAction) browsePhotos
{
    if ([_venue.photos count] > 0)
    {
        ViewController *rootVC = (ViewController *)[[ModelManager sharedModelManager] rootVC];
        [rootVC browsePhotos:_venue.photos];
    }
}


- (IBAction)openWebsite
{
    NSURL *url = [[NSURL alloc] initWithString:_venue.website];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma - Gesture

- (IBAction)swipeAction:(id)sender
{
	[self hideMe];
}

@end
