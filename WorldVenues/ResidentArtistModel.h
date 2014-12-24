//
//  ResidentArtistModel.h
//  WorldVenues
//
//  Created by David Engler on 9/23/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VenueModel;

@interface ResidentArtistModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) VenueModel *venue;

@end
