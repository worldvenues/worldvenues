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

@protocol TourBrowserDelegate;

@interface TourBrowseViewController : UIViewController

@property (strong) NSFetchedResultsController* fetchedResultsController;
@property (strong) IBOutlet UITableView *tableView;
@property (weak) id<TourBrowserDelegate> delegate;

@end

@protocol TourBrowserDelegate <NSObject>

-(void)tourSelected:(TourModel *)tour;

@end