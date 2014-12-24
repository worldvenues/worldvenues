//
//  PhotoModel.h
//  WorldVenues
//
//  Created by David Engler on 11/8/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VenueModel;

@interface PhotoModel : NSManagedObject

@property (nonatomic, retain) NSString * attribution;
@property (nonatomic, retain) NSNumber * flickrID;
@property (nonatomic, retain) NSString * license;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) VenueModel *venue;

@end
