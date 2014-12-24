//
//  TourBrowseViewController.m
//  WorldVenues
//
//  Created by David Engler on 9/12/12.
//
//

#import "TourBrowseViewController.h"
#import "ModelManager.h"
#import "TourModel.h"

@interface TourBrowseViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation TourBrowseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        ModelManager* modelManager = [ModelManager sharedModelManager];
        
        NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = [NSEntityDescription entityForName:[TourModel description]
                                          inManagedObjectContext:modelManager.managedObjectContext];
        //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name != 'Favorites'"];
        fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
        
        fetchRequest.fetchBatchSize = 100;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:modelManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        NSError* error = nil;
        [self.fetchedResultsController performFetch:&error];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

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
		cell.textLabel.adjustsFontSizeToFitWidth = YES;

		cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
		cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:195/255.0 green:67/255.0 blue:42/255.0 alpha:1];
    }

	TourModel* tour = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = tour.name;
    
    
    //cell.imageView.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://a0.twimg.com/profile_images/1843378620/wd10_avatar_normal.jpg"]]];
    
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
    TourModel* tour = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [_delegate tourSelected:tour];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];	
}

#pragma mark - Search Bar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    ModelManager* modelManager = [ModelManager sharedModelManager];

    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:[TourModel description]
                                      inManagedObjectContext:modelManager.managedObjectContext];
    if ([searchText length] > 0)
    {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    }
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil];
    
    fetchRequest.fetchBatchSize = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:modelManager.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError* error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    [self.tableView reloadData];
}

@end
