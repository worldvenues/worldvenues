//
//  BrowseViewController.h
//  WorldVenues
//
//  Created by David Engler on 8/14/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TourModel.h"

@interface BrowseViewController : UIViewController

@property (strong) NSFetchedResultsController* fetchedResultsController;
@property (strong) IBOutlet UITableView *tableView;
@property (strong) IBOutlet UISearchBar *searchBar;

@property BOOL isTravelLog;

- (void)setTour:(TourModel *)tour;
- (void)clearSearch;
- (void)reloadData;
- (void)updateVenue:(VenueModel*)venue;

@end
