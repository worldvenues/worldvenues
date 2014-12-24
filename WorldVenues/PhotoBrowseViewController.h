//
//  PhotoBrowseViewController.h
//  WorldVenues
//
//  Created by David Engler on 11/5/12.
//
//

#import <UIKit/UIKit.h>

@interface PhotoBrowseViewController : UIViewController

@property (strong) IBOutlet UIScrollView *mainScrollView;
@property (strong) IBOutlet UIScrollView *bottomScrollView;
@property (strong) NSSet *photos;

@property (strong) IBOutlet UILabel *titleLabel;
@property (strong) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction) closeMe;

@end
