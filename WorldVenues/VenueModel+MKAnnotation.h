//
//  VenueModelMKAnnotation.h
//  WorldVenues
//
//  Created by Sherwin Zadeh on 11/8/12.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "VenueModel.h"

@interface VenueModel(MKAnnotation) <MKAnnotation>

- (CLLocationCoordinate2D)coordinate;
- (NSString *)title;

@end
