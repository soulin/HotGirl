//
//  MainViewController.h
//  HotGirl
//
//  Created by 李云天 on 10-10-14.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FotoViewController;
@interface MainViewController : UIViewController
<UIScrollViewDelegate>
{
	NSMutableDictionary *girls;
	NSArray *girlIds;
	
	// 一共225个相册，每页显示9个，一共25页
	// 页码总数
	NSUInteger pageCount;
	// 翻页时，当前显示的页码
	NSUInteger currentPageIndex;

	// 用于显示全部225个相册
	UIScrollView *fotoAlbum;
	// 相册数量
	NSUInteger albumCount;
	
	// 3个视图，用于翻页处理
	// 前一个视图
	UIView *pagePrev;
	// 当前视图
	UIView *pageCurrent;
	// 后一个视图
	UIView *pageNext;
	
	// 在视图顶部显示一个上页，下页的指示，使用UILabel实现
	UILabel *pageIndicator;
	
	// 用于显示图片
	FotoViewController *fotoViewController;
}
@property (nonatomic, retain) NSMutableDictionary *girls;
@property (nonatomic, retain) NSArray *girlIds;

@property (nonatomic, assign) NSUInteger currentPageIndex;

@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, retain) UIScrollView *fotoAlbum;
@property (nonatomic, assign) NSUInteger albumCount;
@property (nonatomic, retain) UIView *pagePrev;
@property (nonatomic, retain) UIView *pageCurrent;
@property (nonatomic, retain) UIView *pageNext;

@property (nonatomic, retain) UILabel *pageIndicator;

@property (nonatomic, retain) FotoViewController *fotoViewController;

// 在主视图中添加滚动相册视图
- (void)addScrollView:(CGFloat)width withHeight:(CGFloat)height;
// 滚动相册视图的宽度，因为本程序只提供横向滚动
- (CGFloat)getScrollViewWidth:(NSUInteger)column;
// 获取某个相册的左上顶点坐标
- (CGPoint)getAlbumPoint:(NSUInteger)index rowOrColumn:(NSUInteger)column;

// 用于旋转设备处理
- (void)layoutForCurrentOrientation;

// 添加页面导航提示
- (void)changePageIndicator;
- (void)addPageIndicator;

// 按照系统设置，每kFotoAlbumThumbPerPage个相册显示在一个UIView中，一共3个UIView用于翻页
// page是当前页码，用于计算视图的左上角顶点坐标
- (UIView *)makeScrollPageView:(NSUInteger)page forUIView:(UIView *)aView;
// 往后或者往后翻页，按照软件设计，往右时，取后面的相册，directRight == YES
- (void)rebuildAlbum:(NSUInteger)page directRight:(BOOL)right;

// 查看某个人的相册
- (void)browserAlbum:(id)sender;

@end
