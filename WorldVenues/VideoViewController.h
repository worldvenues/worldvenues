//
//  VideoViewController.h
//  WorldVenues
//
//  Created by David Engler on 9/27/12.
//
//

#import <UIKit/UIKit.h>

@interface VideoViewController : UIViewController

@property (strong) IBOutlet UIView *containerView;
@property (strong) IBOutlet UIToolbar *toolBar;
@property (strong) IBOutlet UIWebView *webView;
@property (strong) IBOutlet UILabel *titleLabel;
@property (strong) IBOutlet UILabel *urlLabel;
@property (strong) NSSet *videos;
@property int playIndex;

- (IBAction) closeMe;
- (IBAction) nextVideo;
- (IBAction) prevVideo;

@end
