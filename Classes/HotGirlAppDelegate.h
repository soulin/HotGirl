//
//  HotGirlAppDelegate.h
//  HotGirl
//
//  Created by 李云天 on 10-10-14.
//  Copyright iHomeWiki 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface HotGirlAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	MainViewController *mainViewController;
    UINavigationController *mainNavigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;
@property (nonatomic, retain) IBOutlet UINavigationController *mainNavigationController;

// 隐藏状态栏，导航栏和工具栏
- (void)setFullScreen:(UINavigationController *)navigationController isHidden:(BOOL)hidden;
@end

