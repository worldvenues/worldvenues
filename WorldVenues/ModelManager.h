//
//  ModelManager.h
//
//  Created by Sherwin Zadeh on 8/5/11.
//  Copyright 2011 KUSC Interactive, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"

@protocol ModelManagerDelegate;

@interface ModelManager : NSObject <UIAlertViewDelegate>

+ (ModelManager*) sharedModelManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext*			managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel*			managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator*	persistentStoreCoordinator;

@property (assign, nonatomic) BOOL modelManagerDownloaded;

@property (strong, nonatomic) AppDelegate *app;
@property (strong, nonatomic) IBOutlet MKMapView*	mapView;
@property (strong, nonatomic) IBOutlet UIViewController* rootVC;

//@property (readonly, strong) FavoritesModel* favoritesModel;
//@property (readonly, strong) PlaylistModel* favoritesPlaylist;
		   
- (void)beginDownloadWithDelegate:(id<ModelManagerDelegate>) delegate;

- (void)saveContext;
- (void)purge;

//-(void)addSongToFavorites:(SongModel*)songModel;
-(void)selectAnnotation:(NSString *)venueName;

@end

@protocol ModelManagerDelegate <NSObject>

-(void)modelManagerDownloadedSuccessfully:(BOOL)success;


@end
