//
//  AppDelegate.h
//  WorldVenues
//
//  Created by David Engler on 7/24/12.
//  Copyright (c) 2012 KUSC Interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplashScreenViewController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SplashScreenViewController*	splashScreenViewController;
@property (strong, nonatomic) ViewController *viewController;

@end
