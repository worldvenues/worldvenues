//
//  TourModel.h
//  WorldVenues
//
//  Created by David Engler on 9/13/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VenueModel;

@interface TourModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *venue;
@end

@interface TourModel (CoreDataGeneratedAccessors)

- (void)addVenueObject:(VenueModel *)value;
- (void)removeVenueObject:(VenueModel *)value;
- (void)addVenue:(NSSet *)values;
- (void)removeVenue:(NSSet *)values;

@end
