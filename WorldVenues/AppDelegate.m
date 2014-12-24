//
//  AppDelegate.m
//  WorldVenues
//
//  Created by David Engler on 7/24/12.
//  Copyright (c) 2012 KUSC Interactive. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "GANTracker.h"

static NSString* const kAnalyticsAccountId = @"";
static const NSInteger kGANDispatchPeriodSec = 10;

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.splashScreenViewController = [[SplashScreenViewController alloc] init];
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.rootViewController = self.splashScreenViewController;
    [self.window makeKeyAndVisible];
    
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    ModelManager* modelManager = [ModelManager sharedModelManager];
    modelManager.app = self;
    [modelManager beginDownloadWithDelegate:self.viewController];

    // Analytics
	[[GANTracker sharedTracker] startTrackerWithAccountID:kAnalyticsAccountId
										   dispatchPeriod:kGANDispatchPeriodSec
												 delegate:nil];
	
	NSError* error;
	if (![[GANTracker sharedTracker] trackEvent:@"Application iOS"
										 action:@"Launch iOS"
										  label:@"Example iOS"
										  value:99
									  withError:&error]) {
		NSLog(@"error in trackEvent");
	}
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[[ModelManager sharedModelManager] saveContext];	
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSError* error = nil;
	if (![[GANTracker sharedTracker] trackPageview:@"/app_entry_point"
										 withError:&error]) {
		NSLog(@"error in trackPageview");
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    ModelManager* modelManager = [ModelManager sharedModelManager];
    [modelManager saveContext];
	
	[[GANTracker sharedTracker] stopTracker];	
}

@end
