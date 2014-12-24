//
//  VenueViewController.h
//  WorldVenues
//
//  Created by David Engler on 8/26/12.
//
//

#import <UIKit/UIKit.h>
#import "VenueModel.h"

@protocol VenueViewControllerDelegate;

@interface VenueViewController : UIViewController

@property (weak, nonatomic) id<VenueViewControllerDelegate> delegate;
@property (strong, nonatomic) VenueModel *venue;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong) IBOutlet UILabel *nameLabel;
@property (strong) IBOutlet UILabel *addressLabel;
@property (strong) IBOutlet UIButton *websiteLink;
@property (strong) IBOutlet UILabel *openedLabel;
@property (strong) IBOutlet UILabel *seatsLabel;
@property (strong) IBOutlet UILabel *seatingLabel;
@property (strong) IBOutlet UILabel *architectLabel;
@property (strong) IBOutlet UILabel *styleLabel;
@property (strong) IBOutlet UILabel *styleHeaderLabel;
@property (strong) IBOutlet UILabel *residentArtistLabel;
@property (strong) IBOutlet UILabel *residentArtistHeaderLabel;
@property (strong) IBOutlet UILabel *performancePerYearLabel;
@property (strong) IBOutlet UILabel *firstPerformanceLabel;
@property (strong) IBOutlet UILabel *funFactLabel;
@property (strong) IBOutlet UILabel *notableNotesLabel;
@property (strong) IBOutlet UILabel *famousPerformanceLabel;
@property (strong) IBOutlet UILabel *firstPerformanceHeaderLabel;
@property (strong) IBOutlet UILabel *funFactHeaderLabel;
@property (strong) IBOutlet UILabel *notableNotesHeaderLabel;

@property (strong) IBOutlet UIButton *flickrImage;
@property (strong) IBOutlet UIButton *videoThumbImage1;
@property (strong) IBOutlet UIButton *videoThumbImage2;
@property (strong) IBOutlet UIButton *videoThumbImage3;
@property (strong) IBOutlet UIButton *videoThumbImage4;
@property (strong) IBOutlet UIButton *videoThumbImage5;
@property (strong) IBOutlet UIButton *videoThumbImage6;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong) IBOutlet UIButton *visitedButton;
@property (strong) IBOutlet UIButton *favoriteButton;

//@property (strong) OFFlickrAPIContext *flickrContext;
//@property (strong) OFFlickrAPIRequest *flickrRequest;
@property (strong, nonatomic) IBOutlet UIView *leftBorderView;

- (IBAction) hideMe;
- (IBAction) setFavorite;
- (IBAction) setVisited;
- (IBAction) playVideo:(id)sender;
- (IBAction) browsePhotos;
- (IBAction) openWebsite;

@end




@protocol VenueViewControllerDelegate <NSObject>

-(void)venueViewController:(VenueViewController*)venueViewController favorited:(BOOL)favorited venue:(VenueModel*)venueModel;
-(void)venueViewController:(VenueViewController*)venueViewController visited:(BOOL)visited venue:(VenueModel*)venueModel;

@end
