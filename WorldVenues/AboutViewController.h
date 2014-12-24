//
//  AboutViewController.h
//  WorldVenues
//
//  Created by David Engler on 8/29/12.
//
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
}

- (IBAction) hideMe;

@end
