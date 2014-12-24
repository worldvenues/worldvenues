//
//  VideoModel.h
//  WorldVenues
//
//  Created by David Engler on 10/23/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VenueModel;

@interface VideoModel : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) VenueModel *venue;

@end
