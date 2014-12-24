//
//  BrowseViewController.m
//  WorldVenues
//
//  Created by David Engler on 8/14/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>

#import "BrowseViewController.h"
#import "ModelManager.h"
#import "VenueModel.h"
#import "WebService.h"
#import "PhotoModel.h"

@interface BrowseViewController () <UITableViewDelegate>
{
    TourModel *_tour;
}

@end

@implementation BrowseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self clearSearch];
		self.title = @"Browse";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_tour || _isTravelLog)
    {
        self.tableView.sectionHeaderHeight = 0;
        [self.searchBar setHidden:YES];
        CGRect frame = self.tableView.frame;
        frame.origin.y = 0;//-self.searchBar.frame.size.height;
        self.tableView.frame = frame;
    }
    else
    {
        self.tableView.sectionHeaderHeight = 22;
        [self.searchBar setHidden:NO];
//        CGRect frame = self.tableView.frame;
//        frame.origin.y = 0;
//        self.tableView.frame = frame;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self clearSearch];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

//-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
//{
//	
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

		cell.backgroundView = nil;
		cell.backgroundView.opaque = NO;
		cell.backgroundColor = [UIColor clearColor];
		cell.contentView.opaque = NO;
		cell.contentView.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = [UIColor clearColor];

		cell.textLabel.textColor = [UIColor whiteColor];
		cell.textLabel.adjustsFontSizeToFitWidth = NO;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];

		cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:195/255.0 green:67/255.0 blue:42/255.0 alpha:1];
	
    }
	

//	cell.imageView.layer.cornerRadius = 7.0;
//	cell.imageView.layer.masksToBounds = YES;
	
	VenueModel* venue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (![cell.textLabel.text isEqualToString:venue.name])
    {
        cell.textLabel.text = venue.name;
		cell.imageView.image = [UIImage imageNamed:@"BlankVenueImage"];
        for(PhotoModel *photo in venue.photos)
        {
			// Find first
            if ([photo.order intValue] == 0)
            {
				NSString* fileFullPath = [self fileFullPathFromFlickrId:photo.flickrID];
				if ([[NSFileManager defaultManager] fileExistsAtPath:fileFullPath])
				{
					UIImage* image = [UIImage imageWithContentsOfFile:fileFullPath];
					cell.imageView.image =image;
				}
				else
				{
					[self showFlickrThumbImage:photo.flickrID forIndexPath:indexPath];
				}
				
                break;
            }
        }        
    }

    if ([venue.favorited boolValue] && [venue.visited boolValue])
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFavisited"]];
    else if ([venue.visited boolValue])
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconVisited"]];
    else if ([venue.favorited boolValue])
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFavorite"]];
    else
        cell.accessoryView = nil;

    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo name];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
	[headerView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
	
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
	label.font = [UIFont boldSystemFontOfSize:18];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.textColor = [UIColor colorWithRed:249/255.0 green:223/255.0 blue:180/255.0 alpha:1];
	label.backgroundColor = [UIColor clearColor];
	label.opaque = NO;
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(0, 1);
	[headerView addSubview:label];
	
	return headerView;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     ; *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    VenueModel* venue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [[ModelManager sharedModelManager] selectAnnotation:venue.name];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Helpers

- (void)setTour:(TourModel *)tour
{
    _tour = tour;
	self.title = tour.name;
    
    [self clearSearch];
}

- (void) clearSearch
{
    [self fetchWithSearchText:nil];
}

- (void) reloadData
{
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self fetchWithSearchText:searchText];
}

- (void)fetchWithSearchText:(NSString *)searchText
{
    ModelManager* modelManager = [ModelManager sharedModelManager];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:[VenueModel description]
                                      inManagedObjectContext:modelManager.managedObjectContext];
    if (searchText && [searchText length] > 0)
    {
        if (_tour)
        {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ and self in %@", searchText, _tour.venue];
        }
        else if (_isTravelLog)
        {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@ and (favorited == 1 || visited == 1)", searchText];
        }
        else
        {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        }
    }
    else if (_tour)
    {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"self in %@", _tour.venue];
    }
    else if (_isTravelLog)
    {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"favorited == 1 || visited == 1"];
    }
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    
    fetchRequest.fetchBatchSize = 100;
    
    if (_tour || _isTravelLog)
    {
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																			managedObjectContext:modelManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    else
    {
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																			managedObjectContext:modelManager.managedObjectContext sectionNameKeyPath:@"nameFirstLetter" cacheName:nil];
    }
    NSError* error = nil;
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

- (void)updateVenue:(VenueModel*)venue
{
	NSIndexPath* indexPath = [self.fetchedResultsController indexPathForObject:venue];
	[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
/*
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.imageView.image == nil)
    {
        VenueModel* venue = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSNumber *photo_id = [[venue.photos anyObject] flickrID];
        [self showFlickrThumbImage:photo_id forCell:cell];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadThumbImages];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) [self loadThumbImages];
}

- (void)loadThumbImages
{
    NSArray *indexArray = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexArray)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.imageView.image == nil)
        {
            VenueModel* venue = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSNumber *photo_id = [[venue.photos anyObject] flickrID];
            [self showFlickrThumbImage:photo_id forCell:cell];
        }
    }
}
*/
- (void)showFlickrThumbImage:(NSNumber *)photo_id forIndexPath:(NSIndexPath*)indexPath
{
    if (!photo_id)
		return;
    
    NSString *api_key = @"8146d1f5ee6dd1ddea68bbddf8fb5765";
    NSString *auth_token = @"72157631893050725-ff69eb74958563e9";
    NSString *secret = @"02769559a6768be1";
    NSString *api_sig = [self md5:[NSString stringWithFormat:@"%@api_key%@auth_token%@formatjsonmethodflickr.photos.getInfonojsoncallback1photo_id%@", secret, api_key, auth_token, photo_id]];
    NSURL* jsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1&auth_token=%@&api_sig=%@", api_key, photo_id, auth_token, api_sig]];
    
    WebService* webService = [[WebService alloc] init];
	[webService beginRequestWithURL:jsonUrl finished:^(NSData* thumbResponse) {
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
            
            NSURL * imageURL = [NSURL URLWithString:url];
            WebService* webService = [[WebService alloc] init];
            [webService beginRequestWithURL:imageURL finished:^(NSData* responseData)
             {				 
                 if (responseData != nil) {
                     UIImage * thumbnailImage = [UIImage imageWithData:responseData];
		
					 NSString* fileFullPath = [self fileFullPathFromFlickrId:photo_id];
					 NSData* pngData = UIImagePNGRepresentation(thumbnailImage);
					 [pngData writeToFile:fileFullPath atomically:YES];

					 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//					 UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
//                     cell.imageView.image = thumbnailImage;
//                    [cell setNeedsLayout];
                 }
             }];
        }
	}];
}

- (NSString*)fileFullPathFromFlickrId:(NSNumber*)flickrId
{
	NSString* fileName = [NSString stringWithFormat:@"%@_thumb.png", flickrId];
	NSString* fileFullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
	return fileFullPath;
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

@end
