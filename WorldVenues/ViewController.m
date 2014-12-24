//
//  ViewController.m
//  WorldVenues
//
//  Created by David Engler on 7/24/12.
//  Copyright (c) 2012 KUSC Interactive. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ViewController.h"
//#import "LocationMapAnnotation.h"
#import "ModelManager.h"
#import "VenueModel.h"
#import "VenueModel+MKAnnotation.h"
#import "BrowseViewController.h"
#import "TourBrowseViewController.h"
#import "VenueViewController.h"
#import "AboutViewController.h"
#import "VideoViewController.h"

#define ANIMATION_DURATION (0.5)

@interface ViewController () <VenueViewControllerDelegate>

@property UINavigationController *tourNC;
@property UINavigationController *browseNC;
@property UINavigationController *travelLogNC;

@property TourBrowseViewController *tourBrowseVC;
@property BrowseViewController *tourVenuesBrowseVC;
@property BrowseViewController *browseVC;
@property BrowseViewController *travelLogVC;
@property VenueViewController *venueVC;
@property AboutViewController *aboutVC;

//@property VenuesTableViewController *vtvc;
@property (strong, nonatomic) IBOutlet UIImageView *sideBar;
@property (strong, nonatomic) IBOutlet UIButton *tourButton;
@property (strong, nonatomic) IBOutlet UIButton *browseButton;
@property (strong, nonatomic) IBOutlet UIButton *travelLogButton;
@property (strong, nonatomic) IBOutlet UIButton *aboutButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.mapView.mapType = MKMapTypeStandard;
	self.sideBar.layer.shadowColor = [UIColor blackColor].CGColor;
	self.sideBar.layer.shadowRadius = 5;
	self.sideBar.layer.shadowOpacity = 1;
	self.sideBar.clipsToBounds = NO;
	self.sideBar.layer.shadowOffset = CGSizeMake(2.5, 0);
}

- (void)viewDidUnload
{
	[self setSideBar:nil];
	[self setTourButton:nil];
	[self setBrowseButton:nil];
	[self setTravelLogButton:nil];
	[self setAboutButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark - ModelManagerDelegate

-(void)modelManagerDownloadedSuccessfully:(BOOL)success
{
	// Do any additional setup after loading the view, typically from a nib.
    ModelManager* modelManager = [ModelManager sharedModelManager];
    modelManager.app.splashScreenViewController = nil;
    modelManager.app.window.rootViewController = self;
    modelManager.mapView = self.mapView;
    modelManager.rootVC = self;
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:[VenueModel description]
                                      inManagedObjectContext:modelManager.managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name != 'Favorites'"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    
    fetchRequest.fetchBatchSize = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:modelManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError* error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    self.annotations = [self.fetchedResultsController.fetchedObjects mutableCopy];
//    NSArray* fetchedResults = self.fetchedResultsController.fetchedObjects;
//    self.annotations = [NSMutableArray arrayWithCapacity:[fetchedResults count]];
    
//     for (VenueModel* vm in fetchedResults) {
//         //NSLog(@"%@", vm.name);
//         LocationMapAnnotation* locationMapAnnotation = [[LocationMapAnnotation alloc] initWithVenue:vm];
//         [self.annotations addObject:locationMapAnnotation];
//     }    
    
	[self.mapView addAnnotations:self.annotations];
    
    self.tourBrowseVC = [[TourBrowseViewController alloc] init];
    [self.tourBrowseVC setTitle:@"Take a Tour"];
    self.tourBrowseVC.delegate = self;
    self.tourNC = [[UINavigationController alloc] initWithRootViewController:self.tourBrowseVC];
	self.tourNC.navigationBar.barStyle = UIBarStyleBlack;
    CGRect frame = self.tourNC.view.frame;
    frame.size.width = 320;
    frame.size.height = 748;
    frame.origin.x = -frame.size.width;
    self.tourNC.view.frame = frame;
    [self.mapView addSubview:self.tourNC.view];
    
    self.browseVC = [[BrowseViewController alloc] init];
    frame = self.browseVC.view.frame;
    frame.origin.x = -frame.size.width;
    self.browseVC.view.frame = frame;
	self.browseNC = [[UINavigationController alloc] initWithRootViewController:self.browseVC];
	self.browseNC.navigationBar.barStyle = UIBarStyleBlack;
    frame = self.browseNC.view.frame;
    frame.size.width = 320;
    frame.size.height = 748;
    frame.origin.x = -frame.size.width;
    self.browseNC.view.frame = frame;
    [self.mapView addSubview:self.browseNC.view];
    
    self.travelLogVC = [[BrowseViewController alloc] init];
    [self.travelLogVC setIsTravelLog:YES];
    frame = self.travelLogVC.view.frame;
    frame.origin.x = -frame.size.width;
    self.travelLogVC.view.frame = frame;
	self.travelLogNC = [[UINavigationController alloc] initWithRootViewController:self.travelLogVC];
	self.travelLogNC.navigationBar.barStyle = UIBarStyleBlack;
    self.travelLogVC.title = @"My Travel Log";
    frame = self.travelLogNC.view.frame;
    frame.size.width = 320;
    frame.size.height = 748;
    frame.origin.x = -frame.size.width;
    self.travelLogNC.view.frame = frame;
    [self.mapView addSubview:self.travelLogNC.view];
    
    self.aboutVC = [[AboutViewController alloc] init];
    frame = self.aboutVC.view.frame;
    CGSize screenSize = self.mapView.bounds.size;
    frame.origin.x = screenSize.width;
    self.aboutVC.view.frame = frame;
    [self.mapView addSubview:self.aboutVC.view];

    self.venueVC = [[VenueViewController alloc] init];
	self.venueVC.delegate = self;
    frame = self.venueVC.view.frame;
    frame.origin.x = screenSize.width;
    self.venueVC.view.frame = frame;
    [self.mapView addSubview:self.venueVC.view];
    
    [self browseVenuesWithTour:nil];
}

#pragma mark - MKMapViewDelegate

// Helper
-(void)updateAnnotationView:(MKAnnotationView*)aView withVenueModel:(VenueModel*) venue
{
    if ([venue.favorited boolValue] && [venue.visited boolValue])
        aView.image = [UIImage imageNamed:@"MarkerFavisited"];
    else if ([venue.favorited boolValue])
        aView.image = [UIImage imageNamed:@"MarkerFavorited"];
    else if ([venue.visited boolValue])
        aView.image = [UIImage imageNamed:@"MarkerVisited"];
    else
        aView.image = [UIImage imageNamed:@"Marker"];	
}

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:@"MyMap"];
    if (!aView) {
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyMap"];
    }
    aView.annotation = annotation;
    aView.canShowCallout = YES;
    aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    if ([[(LocationMapAnnotation *)annotation venue] favorited])
	VenueModel* venue = (VenueModel*)annotation;
	[self updateAnnotationView:aView withVenueModel:venue];
    
    return aView;
}

- (void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
//    LocationMapAnnotation *a = view.annotation;
	VenueModel* venue = (VenueModel*) view.annotation;
    [self openVenue:venue];
}

- (void) openVenue:(VenueModel *)venue
{
    self.venueVC.venue = venue;
    [self openView:self.venueVC];
}

- (IBAction) takeATour
{
    if (self.tourButton.selected == NO)
    {
        [self openView:self.tourNC];
        [self.tourVenuesBrowseVC reloadData];
    }
    else
        [self openView:nil];    
}

- (IBAction) browseVenues
{
    if (self.browseButton.selected == NO)
        [self browseVenuesWithTour:nil];
    else
        [self openView:nil];	
}

- (IBAction) browseVenuesWithTour:(TourModel *)tour
{
    if (tour)
    {
        self.tourVenuesBrowseVC = [[BrowseViewController alloc] init];
        [self.tourVenuesBrowseVC setTour:tour];
        [self.tourNC pushViewController:self.tourVenuesBrowseVC animated:YES];
    }
    else
    {
        [self.browseVC reloadData];
        [self openView:self.browseNC];
    }
}

- (IBAction) myTravelLog
{
    if (self.travelLogButton.selected == NO)
    {
        [self.travelLogVC clearSearch];
        [self openView:self.travelLogNC];
    }
    else
        [self openView:nil];
}

- (IBAction) about
{
    if (self.aboutButton.selected == NO)
        [self openView:self.aboutVC];
    else
        [self openView:nil];
}

- (void)openView:(UIViewController *)vcToOpen
{
    self.tourButton.selected = NO;
	self.browseButton.selected = NO;
	self.travelLogButton.selected = NO;
	self.aboutButton.selected = NO;
    
    if (vcToOpen == self.tourNC) self.tourButton.selected = YES;
    if (vcToOpen == self.browseNC)
	{
		self.browseButton.selected = YES;
		[self.browseVC viewWillAppear:YES];
	}
    if (vcToOpen == self.travelLogNC) self.travelLogButton.selected = YES;
    if (vcToOpen == self.aboutVC) self.aboutButton.selected = YES;
    
	NSArray* leftVCs = @[self.tourNC, self.browseNC, self.travelLogNC];
	NSArray* rightVCs = @[self.venueVC, self.aboutVC];
	
	// First close all but the vc
	for (UIViewController* vc in leftVCs)
	{
		if (vc != vcToOpen)
			[self closeViewFromLeft:vc];
	}
	for (UIViewController* vc in rightVCs)
	{
		if (vc != vcToOpen)
			[self closeViewFromRight:vc];
	}
	
	// Open VC after delay
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];	
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ANIMATION_DURATION * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		if ([leftVCs containsObject:vcToOpen])
			[self openViewFromLeft:vcToOpen];
		else if ([rightVCs containsObject:vcToOpen])
			[self openViewFromRight:vcToOpen];
		else
			NSLog(@"Error");
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		
	});
	
}

- (void) openViewFromLeft:(UIViewController *)vc
{	
    CGRect frame = vc.view.frame;
    if (frame.origin.x < 0)
    {
        frame.origin.x = 0;

//		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        [UIView animateWithDuration:ANIMATION_DURATION
						 animations:^{
							 vc.view.frame = frame;
						 } completion:^(BOOL finished) {
//							 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
							 
						 }];
    }
}

- (void) closeViewFromLeft:(UIViewController *)vc
{
    CGRect frame = vc.view.frame;
    if (frame.origin.x >= 0)
    {
        //frame.origin.x = ;
        //vc.view.frame = frame;
        frame.origin.x = -frame.size.width;
        
//        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            vc.view.frame = frame;
        }completion:^(BOOL finished) {
//			[[UIApplication sharedApplication] endIgnoringInteractionEvents];

		}];
    }
}

- (void) openViewFromRight:(UIViewController *)vc
{
	
    CGRect frame = vc.view.frame;
    CGSize screenSize = self.mapView.bounds.size;
    if (frame.origin.x >= screenSize.width)
    {
        //frame.origin.x = ;
        //vc.view.frame = frame;
        frame.origin.x = screenSize.width - frame.size.width;
		
//        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        [UIView animateWithDuration:ANIMATION_DURATION
						 animations:^{
							 vc.view.frame = frame;
						 }
						 completion:^(BOOL finished) {
//							 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
						 }];
    }
}

- (void) closeViewFromRight:(UIViewController *)vc
{
    CGRect frame = vc.view.frame;
    CGSize screenSize = self.mapView.bounds.size;
    if (frame.origin.x < screenSize.width)
    {
        //frame.origin.x = screenSize.width;
        //vc.view.frame = frame;
        frame.origin.x = screenSize.width;
        
 //       [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            vc.view.frame = frame;
        } completion:^(BOOL finished) {
//			[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		}];
    }
}

- (void)tourSelected:(TourModel *)tour
{
    [self browseVenuesWithTour:tour];
}

- (void) playVideo:(NSSet *)videos atIndex:(int)playIndex
{
    _vvc = [[VideoViewController alloc] init];
    _vvc.videos = videos;
    _vvc.playIndex = playIndex;
    //NSLog(@"%@", videoURL);
    [self.view addSubview:_vvc.view];
}

- (void) browsePhotos:(NSSet *)photos
{
    self.pbvc = [[PhotoBrowseViewController alloc] init];
    self.pbvc.photos = photos;
	
	self.pbvc.view.alpha = 0;
    [self.view addSubview:self.pbvc.view];
	[UIView animateWithDuration:0.25 animations:^{
		self.pbvc.view.alpha = 1;
	}];
}

#pragma mark - VenueViewControllerDelegate

-(void)venueViewController:(VenueViewController*)venueViewController favorited:(BOOL)favorited venue:(VenueModel*)venue
{
	MKAnnotationView* annotationView = [self.mapView viewForAnnotation:venue];
	[self updateAnnotationView:annotationView withVenueModel:venue];
	[self.browseVC	updateVenue:venue];
}

-(void)venueViewController:(VenueViewController*)venueViewController visited:(BOOL)visited venue:(VenueModel*)venue
{
	MKAnnotationView* annotationView = [self.mapView viewForAnnotation:venue];
	[self updateAnnotationView:annotationView withVenueModel:venue];
	[self.browseVC	updateVenue:venue];	
}




@end
