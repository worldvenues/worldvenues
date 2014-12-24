//
//  VenueModel.h
//  WorldVenues
//
//  Created by David Engler on 10/23/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ArchitectModel, PhotoModel, ResidentArtistModel, StyleModel, TourModel, VideoModel;

@interface VenueModel : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * visited;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSString * famousPerformance;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSString * firstPerformance;
@property (nonatomic, retain) NSString * funFact;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameFirstLetter;
@property (nonatomic, retain) NSString * notableNotes;
@property (nonatomic, retain) NSString * opened;
@property (nonatomic, retain) NSNumber * performancePerYear;
@property (nonatomic, retain) NSString * seating;
@property (nonatomic, retain) NSNumber * seats;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * youtubeAccount;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *residentArtist;
@property (nonatomic, retain) NSSet *tour;
@property (nonatomic, retain) NSSet *videos;
@property (nonatomic, retain) NSSet *style;
@property (nonatomic, retain) NSSet *architect;
@end

@interface VenueModel (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(PhotoModel *)value;
- (void)removePhotosObject:(PhotoModel *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addResidentArtistObject:(ResidentArtistModel *)value;
- (void)removeResidentArtistObject:(ResidentArtistModel *)value;
- (void)addResidentArtist:(NSSet *)values;
- (void)removeResidentArtist:(NSSet *)values;

- (void)addTourObject:(TourModel *)value;
- (void)removeTourObject:(TourModel *)value;
- (void)addTour:(NSSet *)values;
- (void)removeTour:(NSSet *)values;

- (void)addVideosObject:(VideoModel *)value;
- (void)removeVideosObject:(VideoModel *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

- (void)addStyleObject:(StyleModel *)value;
- (void)removeStyleObject:(StyleModel *)value;
- (void)addStyle:(NSSet *)values;
- (void)removeStyle:(NSSet *)values;

- (void)addArchitectObject:(ArchitectModel *)value;
- (void)removeArchitectObject:(ArchitectModel *)value;
- (void)addArchitect:(NSSet *)values;
- (void)removeArchitect:(NSSet *)values;

@end
