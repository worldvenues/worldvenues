//
//  ModelManager.m
//
//  Created by Sherwin Zadeh on 8/5/11.
//  Copyright 2011 KUSC Interactive, Inc. All rights reserved.
//

#import "ModelManager.h"
#import "WebService.h"
#import "Additions.h"

#import "VenueModel.h"
#import "VenueModel+MKAnnotation.h"
#import "PhotoModel.h"
#import "TourModel.h"
#import "VideoModel.h"
#import "ResidentArtistModel.h"
#import "ViewController.h"
#import "StyleModel.h"
#import "ArchitectModel.h"

#define GET_VENUES_URL (@"http://worldvenu.es/feed")

#define ISNSNULL(X) ([X isKindOfClass:[NSNull class]])

#define ALERT_VIEW_NO_CONNECTION 100
#define ALERT_VIEW_LOGIN 200	

static ModelManager* g_sharedModelManager = nil;

// Private
@interface ModelManager() 
{
	//PlaylistModel* _favoritesPlaylist;
}

@property (unsafe_unretained) id<ModelManagerDelegate> delegate;
@property (assign) int numberofRunningWebServices;

-(void)sync;
-(void)delegateCallbackHelper;
-(void)createModelObjectsFromJsonString:(NSString*)jsonString;
-(NSURL*)applicationDocumentsDirectory;

@end

@implementation ModelManager

@synthesize delegate = _delegate;
@synthesize numberofRunningWebServices = _numberofRunningWebServices;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize modelManagerDownloaded = _modelManagerDownloaded;
//@dynamic favoritesPlaylist;


#pragma mark - Singleton

+ (ModelManager*) sharedModelManager 
{	
	if (g_sharedModelManager == nil) {
		g_sharedModelManager = [[ModelManager alloc] init];
	}
	
	return g_sharedModelManager;
}

#pragma mark - Life Cycle

- (id)init 
{
    self = [super init];
    if (self) {
    }

    return self;
}

- (void)beginDownloadWithDelegate:(id<ModelManagerDelegate>) delegate
{
	self.delegate = delegate;
	
	[self sync];
}

-(void)createModelObjectsFromJsonString:(NSString*)jsonString
{
	NSData* venuesResponseData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];

	NSError* error = nil;	
	NSDictionary* venuesData = (NSDictionary*) [NSJSONSerialization JSONObjectWithData:venuesResponseData options:NSJSONReadingAllowFragments error:&error];
	NSArray* venuesArray = [venuesData notNullObjectForKey:@"rows"];
    
	for (NSDictionary* venueDictionary in venuesArray)
	{	
        NSDictionary *venueDetailsDictionary = [venueDictionary notNullObjectForKey:@"value"];
		NSString* venueName = [venueDetailsDictionary stringForKey:@"venue"];
		
		VenueModel* venue = [self venueWithName:venueName];
										   
		venue.address = [venueDetailsDictionary stringForKey:@"address"];
		venue.facebook = [venueDetailsDictionary stringForKey:@"facebook"];
		venue.firstPerformance = [venueDetailsDictionary stringForKey:@"first_performance"];
		venue.latitude = [venueDetailsDictionary numberForKey:@"latitude"];
		venue.longitude = [venueDetailsDictionary numberForKey:@"longitude"];
        venue.nameFirstLetter = [NSString stringWithFormat:@"%c", [venue.name characterAtIndex:0]];
		venue.notableNotes = [venueDetailsDictionary stringForKey:@"notable_notes"];
		venue.opened = [venueDetailsDictionary stringForKey:@"opened"];
		venue.seating = [venueDetailsDictionary stringForKey:@"seating"];
		venue.seats = [venueDetailsDictionary numberForKey:@"seats"];
		venue.twitter = [venueDetailsDictionary stringForKey:@"twitter"];
		venue.website = [venueDetailsDictionary stringForKey:@"website"];
		venue.youtubeAccount = [venueDetailsDictionary stringForKey:@"youtube_account"];
        venue.funFact = [venueDetailsDictionary stringForKey:@"fun_fact"];
        
        NSArray* architectsArray = [venueDetailsDictionary arrayForKey:@"architect"];
		NSMutableSet* architectsModelSet = [NSMutableSet set];
		for (NSString* architectName in architectsArray)
		{
			if ([architectName isKindOfClass:[NSString class]] == NO)
				continue;
			
			ArchitectModel* a = (ArchitectModel*) [NSEntityDescription insertNewObjectForEntityForName:[ArchitectModel description]
																				inManagedObjectContext:self.managedObjectContext];
			a.name = architectName;
			[architectsModelSet addObject:a];
		}
        venue.architect = architectsModelSet; // Replace previous

        NSArray* residentArtistArray = [venueDetailsDictionary arrayForKey:@"resident_artist"];
		NSMutableSet* residentArtistModelSet = [NSMutableSet set];
		for (NSString *artistName in residentArtistArray)
		{
			if ([artistName isKindOfClass:[NSString class]] == NO)
				continue;

			ResidentArtistModel* artist = (ResidentArtistModel*) [NSEntityDescription insertNewObjectForEntityForName:[ResidentArtistModel description]
																							   inManagedObjectContext:self.managedObjectContext];
			artist.name = artistName;
			[residentArtistModelSet addObject:artist];
		}
        venue.residentArtist = residentArtistModelSet;

        NSArray* styleArray = [venueDetailsDictionary arrayForKey:@"style"];
		NSMutableSet* styleModelSet = [NSMutableSet set];
		for (NSString* styleName in styleArray)
		{
			if ([styleName isKindOfClass:[NSString class]] == NO)
				continue;
			
            StyleModel* style = (StyleModel*) [NSEntityDescription insertNewObjectForEntityForName:[StyleModel description]
																			inManagedObjectContext:self.managedObjectContext];
			style.name = styleName;
			[styleModelSet addObject:style];
		}
		venue.style = styleModelSet;
		        
        NSArray* toursArray = [venueDetailsDictionary arrayForKey:@"tour"];
		for (NSString* tourName in toursArray)
		{
			if ([tourName isKindOfClass:[NSString class]] == NO)
				continue;
			
			TourModel* tour = [self tourWithName:tourName];
			[tour addVenueObject:venue];
		}
		
        NSArray* photosArray = (NSArray*) [venueDetailsDictionary arrayForKey:@"photos"];
		NSMutableSet* photosModelSet = [NSMutableSet set];
		int photo_order = 0;
		for (NSDictionary* photoDictionary in photosArray)
		{
			if ([photoDictionary isKindOfClass:[NSDictionary class]] == NO)
				continue;
			
			NSNumber* flickrId = [photoDictionary numberForKey:@"flickr_id"];
			
			PhotoModel* photo = [self photoWithFlickrId:flickrId];
                
			// Video Model
			photo.title			= [photoDictionary stringForKey:@"title"];
			photo.attribution	= [photoDictionary stringForKey:@"attribution"];
			photo.source		= [photoDictionary stringForKey:@"source"];
			photo.license		= [photoDictionary stringForKey:@"license"];
			photo.order         = [NSNumber numberWithInt:photo_order];
			photo_order++;
			
			[photosModelSet addObject:photo];				
		}
		venue.photos = photosModelSet;

        
        NSArray* videosArray = (NSArray*) [venueDetailsDictionary arrayForKey:@"videos"];
		NSMutableSet* videosModelSet = [NSMutableSet set];
		for (NSString* videoURL in videosArray)
		{
			if ([videoURL isKindOfClass:[NSString class]] == NO)
				continue;
			
			VideoModel* video = (VideoModel*) [NSEntityDescription insertNewObjectForEntityForName:[VideoModel description]
																			inManagedObjectContext:self.managedObjectContext];
			video.url = videoURL;
			[videosModelSet addObject:video];
		}
		venue.videos = videosModelSet;

	}	
	
}

-(NSArray*)makeArrayIfNotAlready:(id)object
{
	if ([object isKindOfClass:[NSArray class]])
	{
		return (NSArray*)object;
	}
	else
	{
		return @[object];
	}	
}

-(VenueModel*)venueWithName:(NSString*)venueName
{
	VenueModel* venue = nil;
	
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[VenueModel description]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", venueName];
	
	// See if already exists, if not create
	NSError* error = nil;
	NSArray* fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedResults != nil && [fetchedResults count] > 0)
	{
		venue = [fetchedResults objectAtIndex:0];
	}
	else
	{
		venue = (VenueModel*) [NSEntityDescription insertNewObjectForEntityForName:[VenueModel description]
															inManagedObjectContext:self.managedObjectContext];
		venue.name = [venueName copy];
	}
	
	return venue;
}

-(void)sync
{
	//[self deleteAllPlaylistsExceptFavorites];
	
	__block id observer = nil;
	observer = [[NSNotificationCenter defaultCenter] addObserverForName:WEBSERVICES_ALL_FINISHED_NOTIFICATION
																 object:nil
																  queue:nil
															 usingBlock:^(NSNotification* notification)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:observer];
		[[ModelManager sharedModelManager] performSelectorOnMainThread:@selector(delegateCallbackHelper) 
															withObject:nil
														 waitUntilDone:NO];
	}];

	NSURL* url = [NSURL URLWithString:GET_VENUES_URL];
//	NSURL* url = [[NSBundle mainBundle] URLForResource:@"TestPlaylist" withExtension:@"json"];
//	 [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/TestPlaylist.jo
	WebService* webService = [[WebService alloc] init];
	[webService beginRequestWithURL:url finished:^(NSData* venuesResponse) {
		
		if (venuesResponse == nil)
			return;
		
		NSString* venuesResponseString = [[NSString alloc] initWithData:venuesResponse encoding:NSASCIIStringEncoding];
		NSLog(@"Playlists JSON Data:\r%@", venuesResponseString); 		// For debugging
		
		
		[self createModelObjectsFromJsonString:venuesResponseString];

		
	}];
	
	return;
}

-(void)delegateCallbackHelper
{
	[self.delegate modelManagerDownloadedSuccessfully:YES];
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
	
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {

    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
	
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SoundSnipsModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}





#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

-(void)purge
{
	NSArray* stores = [self.persistentStoreCoordinator persistentStores];
	
	for (NSPersistentStore *store in stores) {
		[self.persistentStoreCoordinator removePersistentStore:store error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
	}
	
	_persistentStoreCoordinator = nil;	
	_managedObjectContext = nil;
	_managedObjectModel = nil;
}

-(TourModel*)tourWithName:(NSString*)name
{
	TourModel* tour = nil;
	
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[TourModel description]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
	
	// See if already exists, if not create
	NSError* error = nil;
	NSArray* fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedResults != nil && [fetchedResults count] > 0)
	{
		tour = [fetchedResults objectAtIndex:0];
	}
	else
	{
		tour = (TourModel*) [NSEntityDescription insertNewObjectForEntityForName:[TourModel description]
																   inManagedObjectContext:self.managedObjectContext];
		tour.name = name;
	}
	
	return tour;
}

-(PhotoModel*)photoWithFlickrId:(NSNumber*)flickrId
{
	PhotoModel* photo = nil;
	
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PhotoModel description]];
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"flickrID == %@", flickrId];

	// See if already exists, if not create
	NSError* error = nil;
	NSArray* fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (fetchedResults != nil && [fetchedResults count] > 0)
	{
		photo = [fetchedResults objectAtIndex:0];
	}
	else
	{
		photo = (PhotoModel*) [NSEntityDescription insertNewObjectForEntityForName:[PhotoModel description]
															inManagedObjectContext:self.managedObjectContext];
		photo.flickrID = flickrId;
	}
	
	return photo;
}



/*
-(void)deleteAllPlaylistsExceptFavorites
{
	NSFetchRequest* fetchRequest = nil;
	NSError* error = nil;
	
	//
	// Delete all songs that are NOT in favorites
	//
	
	fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[SongModel description]];
	fetchRequest.predicate = [NSPredicate predicateWithValue:YES];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
	
	NSArray* songs = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (SongModel* song in songs) {
		BOOL inFavorites = NO;
		for (PlaylistEntryModel* entry in song.playlistEntries) {
			if ([entry.playlist.name isEqualToString:@"Favorites"]) {
				inFavorites = YES;
				break;
			}
		}
		
		if (!inFavorites) {
			[self.managedObjectContext deleteObject:song];
		}
	}
	
	//
	// Delete all Playlists, except Favorites. Will also cascade to PlaylistEntries
	//
	
	fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PlaylistModel description]];
	fetchRequest.predicate = [NSPredicate predicateWithValue:YES];
	fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
	
	NSArray* playlists = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	for (PlaylistModel* playlist in playlists) {
		if (![playlist.name isEqualToString:@"Favorites"]) {
			[self.managedObjectContext deleteObject:playlist];
		}
	}
	
	
	[self saveContext];
}

-(PlaylistModel*)favoritesPlaylist
{
	if (_favoritesPlaylist == nil) {
	
		NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PlaylistModel description]];
		fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == 'Favorites'"]; // there should be only one
		
		NSError* error = nil;
		NSArray* fetchedResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if (fetchedResults != nil && [fetchedResults count] > 0) {
			_favoritesPlaylist = [fetchedResults objectAtIndex:0];
		}
		else {
			_favoritesPlaylist = (PlaylistModel*) [NSEntityDescription insertNewObjectForEntityForName:[PlaylistModel description]
																				inManagedObjectContext:self.managedObjectContext];
			_favoritesPlaylist.name = @"Favorites";
		}
	}
	return _favoritesPlaylist;
}

-(void)addSongToFavorites:(SongModel*)songModel
{	
	NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PlaylistEntryModel description]];
	fetchRequest.resultType = NSDictionaryResultType;
	fetchRequest.predicate = [NSPredicate predicateWithFormat:@"self in %@", _favoritesPlaylist.playlistEntries];
	NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"order"];
	NSExpression *maxOrderExpression = [NSExpression expressionForFunction:@"max:"
																  arguments:[NSArray arrayWithObject:keyPathExpression]];	
	NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
	[expressionDescription setName:@"maxOrder"];
	[expressionDescription setExpression:maxOrderExpression];
	[expressionDescription setExpressionResultType:NSInteger32AttributeType];
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
	
	NSError* error;
	NSArray* maxResultArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//	NSDictionary* dic = [[maxResultArray objectAtIndex:0] valueForKey:@"max"]
	int max = (maxResultArray == nil || [maxResultArray count] == 0) ? -1 : [[[maxResultArray objectAtIndex:0] valueForKey:@"maxOrder"] intValue];
	
	PlaylistEntryModel* entry = [NSEntityDescription insertNewObjectForEntityForName:[PlaylistEntryModel description]
															  inManagedObjectContext:self.managedObjectContext];
	entry.song = songModel;
	entry.order = [NSNumber numberWithInt:max + 1];
	[self.favoritesPlaylist addPlaylistEntriesObject:entry];
	
	[self saveContext];
}
*/

-(void)selectAnnotation:(NSString *)venueName
{
    NSEnumerator *e = [self.mapView.annotations objectEnumerator];
    VenueModel *venue;
    while (venue = [e nextObject]) {
        if (venue.name == venueName)
        {
            CLLocationCoordinate2D newCenter = venue.coordinate;
            newCenter.longitude +=30;
            if (newCenter.longitude > 179) newCenter.longitude = 179;
            [self.mapView setCenterCoordinate:newCenter animated:YES];
            [self.mapView selectAnnotation:venue animated:YES];
            [(ViewController*)self.rootVC openVenue:venue];
            break;
        }
    }
}

@end
