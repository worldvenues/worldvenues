//
//  ViewController.h
//  WorldVenues
//
//  Created by David Engler on 7/24/12.
//  Copyright (c) 2012 KUSC Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ModelManager.h"
#import "TourBrowseViewController.h"
#import "VideoViewController.h"
#import "PhotoBrowseViewController.h"

@interface ViewController : UIViewController <ModelManagerDelegate, TourBrowserDelegate>

@property (strong) NSFetchedResultsController*	fetchedResultsController;
@property (strong, nonatomic) IBOutlet MKMapView*	mapView;
@property (strong, nonatomic) NSMutableArray*		annotations;
@property (strong, nonatomic) VideoViewController*  vvc;
@property (strong, nonatomic) PhotoBrowseViewController*  pbvc;

- (IBAction) takeATour;
- (IBAction) browseVenues;
- (IBAction) myTravelLog;
- (IBAction) about;
- (void) playVideo:(NSSet *)videos atIndex:(int)playIndex;
- (void) browsePhotos:(NSSet *)photos;
- (void) openVenue:(VenueModel *)venue;

@end
