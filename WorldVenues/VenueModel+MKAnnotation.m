//
//  VenueModelMKAnnotation.m
//  WorldVenues
//
//  Created by Sherwin Zadeh on 11/8/12.
//
//

#import "VenueModel+MKAnnotation.h"

@implementation VenueModel(MKAnnotation)

- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];
    return coordinate;
}

- (NSString *)title
{
    return self.name;
}

@end
