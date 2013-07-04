//
//  HotGirlAppDelegate.m
//  HotGirl
//
//  Created by 李云天 on 10-10-14.
//  Copyright iHomeWiki 2010. All rights reserved.
//

#import "HotGirlAppDelegate.h"
#import "MainViewController.h"
#import "HotGirlHelper.h"

@implementation HotGirlAppDelegate

@synthesize window, mainViewController, mainNavigationController;


#pragma mark - UINavigationControllerDelegate methods
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSLog(@"willShowViewController: %@", viewController);
	
	//[self releaseFotoView];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSLog(@"didShowViewController: %@", viewController);
}


// 隐藏状态栏，导航栏和工具栏
- (void)setFullScreen:(UINavigationController *)navigationController isHidden:(BOOL)hidden
{
	[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	[navigationController setNavigationBarHidden:hidden animated:YES];
	[navigationController setToolbarHidden:hidden animated:YES];
}

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	[HotGirlHelper singleton];
	
	if (nil == self.mainViewController) {
		//self.mainViewController = [[MainViewController alloc] initWithNibName:@"PhotoAlbumViewController" bundle:nil];
        self.mainViewController = [[MainViewController alloc] init];
	}
    
    self.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];

	[self.mainNavigationController.toolbar setBarStyle:UIBarStyleBlackTranslucent];
	[self.mainNavigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	[window addSubview:[self.mainNavigationController view]];

    [window makeKeyAndVisible];
    
    [self.mainNavigationController release];
	//NSLog(@"width: %g - height: %g", window.frame.size.width, window.frame.size.height);
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
	[mainViewController release];
	
    [super dealloc];
}


@end
