//
//  FotoViewController.h
//  HotGirl
//
//  Created by 李云天 on 10-10-18.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FotoScrollView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class HotGirl;
@class AboutHotGirlController;

@interface FotoViewController : UIViewController
<UIScrollViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, TapDetectingImageViewDelegate>
{
	AboutHotGirlController *aboutHotGirlController;
	NSUInteger girlId;
	BOOL isSameGirl;
	
    UIScrollView *pagingScrollView;
	
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
	
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int           firstVisiblePageIndexBeforeRotation;
    CGFloat       percentScrolledIntoFirstVisiblePage;
	
	// 当前模特的图片
	NSMutableArray *girlFotoes;
	HotGirl *girl;
	
    NSTimer *autoscrollTimer;  // Timer used for auto-scrolling.
    float autoscrollDistance;  // Distance to scroll the thumb view when auto-scroll timer fires.
}
@property (nonatomic,retain) AboutHotGirlController *aboutHotGirlController;

@property (nonatomic, retain) UIScrollView *pagingScrollView;
@property (nonatomic, retain) NSMutableArray *girlFotoes;
@property (nonatomic, retain) HotGirl *girl;
@property (nonatomic, assign) NSUInteger girlId;
@property (nonatomic, assign) BOOL isSameGirl;

- (void)fetchGilr;
- (void)addToolbarButton;
- (void)configurePage:(FotoScrollView *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;

- (void)showFotoes;
- (FotoScrollView *)dequeueRecycledPage;

- (NSUInteger)imageCount;
- (NSString *)imageNameAtIndex:(NSUInteger)index;
- (UIImage *)imageAtIndex:(NSUInteger)index;

// 工具栏上的播放、暂停按钮
- (UIBarButtonItem *)createToolbarPlayItem:(UIBarButtonSystemItem)item;
// 自动播放时，更改按钮图片
- (void)changePlayItemTo:(UIBarButtonSystemItem)item;

// 发送邮件
- (void)displayComposerSheet:(NSString *)subject mailBody:(NSString *)body mailAttach:(NSString *)attach;
@end
