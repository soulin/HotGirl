//
//  MainViewController.m
//  HotGirl
//
//  Created by 李云天 on 10-10-14.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "MainViewController.h"
#import "Constants.h"
#import "FotoViewController.h"
#import "HotGirlAppDelegate.h"
#import "HotGirlHelper.h"
#import "StringHelperExt.mm"

#define kPagePrevTag 1001
#define kPageCurrentTag 1002
#define kPageNextTag 1003
#define kPageTempTag 1000

@implementation MainViewController

@synthesize girls, girlIds, fotoViewController, albumCount;
@synthesize pageIndicator, pageCount, fotoAlbum, pagePrev, pageCurrent, pageNext, currentPageIndex;

#pragma mark - 重建视图

// 手指从左往右（查看以前的相册，比如当前页码是9，则查看第8页的相册）
// 1、清空tag为kPageNextTag(1003)的UIView【第10页】中的所有内容，并将其tag设置为kPageTempTag（1000）
// 2、将tag为kPageCurrentTag(1002)的UIView【第9页】的tag改为kPageNextTag(1003)
// 2、将tag为kPagePrevTag(1001)的UIView【第8页】的tag改为kPageCurrentTag(1002)
// 4，获取序号（self.girlids中的排序）从（page-1）* kFotoAlbumThumbPerPage开始的kFotoAlbumThumbPerPage个相册，
//    放到tag为kPageTempTag(1000)的UIView中，将其tag改为kPagePrevTag(1001)【第7页】，并更改其坐标的x值（x - 2 * [[UIScreen mainScreen] bounds].size.width）
// 5、第一页时，忽略第4步

// 手指从右往左（查看后面的相册，比如当前页码是9，则查看第10页的相册）right == YES
// 1、清空tag为kPagePrevTag(1001)的UIView【第8页】中的所有内容，并将其tag设置为kPageTempTag（1000）
// 2、将tag为kPageCurrentTag(1002)的UIView【第9页】的tag改为kPagePrevTag(1001)
// 2、将tag为kPageNextTag(1003)的UIView【第10页】的tag改为kPageCurrentTag(1002)
// 4，获取序号（self.girlids中的排序）从（page+1）* kFotoAlbumThumbPerPage开始的kFotoAlbumThumbPerPage个相册，
//    放到tag为kPageTempTag(1000)的UIView中，将其tag改为kPageNextTag(1003)【第11页】，并更改其坐标的x值（x + 2 * [[UIScreen mainScreen] bounds].size.width）
// 5、最后一页时，忽略第4步
- (void)rebuildAlbum:(NSUInteger)page directRight:(BOOL)right
{
	if (page > self.pageCount || page < 1)
    {
		return;
	}
	
	UIView *prev = [self.fotoAlbum viewWithTag:kPagePrevTag];
	UIView *current = [self.fotoAlbum viewWithTag:kPageCurrentTag];
	UIView *next = [self.fotoAlbum viewWithTag:kPageNextTag];
	
	// 翻页
	if (right)
    {
        // 手指从右往左
		for (UIButton *btn in [prev subviews])
        {
			if (nil != btn)
            {				
				[btn removeFromSuperview];
			}
		}
		[prev setTag:kPageTempTag];
		[current setTag:kPagePrevTag];
		[next setTag:kPageCurrentTag];
		
		if (page < self.pageCount)
        {
			prev = [self makeScrollPageView:page + 1 forUIView:prev];
		}
        
		[prev setTag:kPageNextTag];
	}
	else
	{
        // 手指从左往右
		for (UIButton *btn in [next subviews])
        {
			if (nil != btn)
            {
				[btn removeFromSuperview];
			}
		}
		
		[next setTag:kPageTempTag];
		[current setTag:kPageNextTag];
		[prev setTag:kPageCurrentTag];
		
		if (page > 1)
        {
			next = [self makeScrollPageView:page - 1 forUIView:next];
		}
		
		[next setTag:kPagePrevTag];
	}
}

#pragma mark - 查看某个相册

// 查看某个的相册
- (void)browserAlbum:(id)sender
{
	//NSLog(@"Get: %d.", [sender tag] - 20000);
    
	if (nil == self.fotoViewController)
    {
        self.fotoViewController = [[FotoViewController alloc] init];
	}
    
	[self.fotoViewController setGirlId:([sender tag] - 20000)];
    
	[self.navigationController pushViewController:self.fotoViewController animated:YES];
}

#pragma mark - 创建相册视图

- (CGFloat)getFotoThumbWidth
{
	return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? kFotoAlbumThumbWidthLandscape : kFotoAlbumThumbWidth;
}

- (CGFloat)getFotoThumbHeight
{
	return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? kFotoAlbumThumbHeightLandscape : kFotoAlbumThumbHeight;
}

// 获取某个相册的左上顶点坐标
- (CGPoint)getAlbumPoint:(NSUInteger)index rowOrColumn:(NSUInteger)column
{
	//CGFloat top = (1 == column) ? ([self.view frame].size.height - [self getFotoThumbHeight])/2 : kFotoAlbumThumbTop;
	
	CGFloat x = (index / column) * [self getFotoThumbWidth] + (index / column + 1) * kFotoAlbumThumbLeft;
	CGFloat y = (index % column) * [self getFotoThumbHeight] + (index % column + 1) * kFotoAlbumThumbTop;
	
	CGPoint p = CGPointMake(x, y);
	
	//NSLog(@"index: %d, rowOrColumn: %d, x: %g - y: %g", index, column, p.x, p.y);
	return p;
}

// 按照系统设置，每kFotoAlbumThumbPerPage个相册显示在一个UIView中，一共3个UIView用于翻页
// page是当前页码，用于计算视图的左上角顶点坐标
- (UIView *)makeScrollPageView:(NSUInteger)page forUIView:(UIView *)aView
{	
	CGRect rect = CGRectMake((page - 1) * kScreenWidth, 0, kScreenWidth, kScreenHeight);
	
	if (nil == aView)
    {
		aView = [[UIView alloc] initWithFrame:rect];
		[aView setBackgroundColor:[UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f]];
	}
	else
    {
		aView.frame = rect;
	}
    
	if (0 == page)
    {
		return aView;
	}
	
	for (NSUInteger i = 0; i < kFotoAlbumThumbPerPage; i++)
    {
		NSUInteger num = i + (page - 1) * kFotoAlbumThumbPerPage;
		NSString *girlId = [self.girlIds objectAtIndex:num];
		//NSLog(@"%@", girlId);
        
		CGPoint p = [self getAlbumPoint:i rowOrColumn:kFotoAlbumThumbHorizontalNumber];
		
		UIButton *albumCoverButton = [UIButton buttonWithType:UIButtonTypeCustom];
		albumCoverButton.frame = CGRectMake(p.x, p.y, [self getFotoThumbWidth], [self getFotoThumbHeight]);
		[albumCoverButton addTarget:self action:@selector(browserAlbum:) forControlEvents:UIControlEventTouchUpInside];
		albumCoverButton.tag = 20000 + [girlId intValue];
		albumCoverButton.backgroundColor = [UIColor whiteColor];
		
		UIImage *ccImage = [UIImage imageNamed:[NSString stringWithFormat:@"cover_%@.jpg",girlId]];
        
		// 显示名称时，使用背景图片
		if (kSHOWGIRLNAME)
        {
			[albumCoverButton setBackgroundImage:ccImage forState:UIControlStateNormal];
            
			NSString *girlName = [self.girls objectForKey:girlId];
			
			[albumCoverButton setTitle:girlName forState:UIControlStateNormal];
			[albumCoverButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
			[albumCoverButton setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
			[albumCoverButton.titleLabel setFont:[UIFont systemFontOfSize: 16]];
			[albumCoverButton.titleLabel setAlpha:0.6f];			
		}
		else
        {
			[albumCoverButton setImage:ccImage forState:UIControlStateNormal];
			[albumCoverButton.imageView setContentMode:UIViewContentModeScaleToFill];
		}
		//[ccImage release];
        
		[aView addSubview:albumCoverButton];
	}
	
	return aView;
}

// 在主视图中添加滚动相册视图
- (void)addScrollView:(CGFloat)width withHeight:(CGFloat)height
{
    self.fotoAlbum = [[UIScrollView alloc] initWithFrame:kScrenRect];
    self.fotoAlbum.pagingEnabled = YES;
    self.fotoAlbum.backgroundColor = [UIColor blackColor];
    self.fotoAlbum.showsVerticalScrollIndicator = NO;
    self.fotoAlbum.showsHorizontalScrollIndicator = NO;
    self.fotoAlbum.contentSize = CGSizeMake(width, height);
	//self.fotoAlbum.decelerationRate = UIScrollViewDecelerationRateFast;
    self.fotoAlbum.delegate = self;
    [self.view addSubview:self.fotoAlbum];
}

// 滚动相册视图的宽度，因为本程序只提供横向滚动
- (CGFloat)getScrollViewWidth:(NSUInteger)pages
{
	CGFloat width = pages * kScreenWidth;
	//NSLog(@"%g", width);
	return width;
}

// 用于旋转设备处理
- (void)layoutForCurrentOrientation
{
	//NSLog(@"Layout For Current Orientation");
}

- (void)changePageIndicator
{
	[self.pageIndicator setText:[NSString stringWithFormat:@"%d/%d", self.currentPageIndex, self.pageCount]];
}

// 添加页面导航提示
- (void)addPageIndicator
{
    float x = (kScreenWidth - kFotoAlbumThumbWidth)/2;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, kFotoAlbumThumbWidth, 20.0f)];
    
    [label setText:@"1/25"];
    [label setAlpha:0.5f];
    [label setOpaque:YES];
    [label setTextAlignment:UITextAlignmentCenter];
	
	self.pageIndicator = label;
	[self changePageIndicator];
	[label release];
	
	[self.view addSubview:self.pageIndicator];
}

#pragma mark - ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	// Switch the indicator when more than 50% of the previous/next page is visible
	int page = floor((scrollView.contentOffset.x - kScreenWidth / 2) / kScreenWidth) + 2;
	//NSLog(@"scrollView.contentOffset.x ,page * kScreenWidth: %g , %g", scrollView.contentOffset.x, page * kScreenWidth);
    
    // 以免出现把第一页或者最后一页翻掉的BUG
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > (self.pageCount - 1) * kScreenWidth)
    {
        return;
    }

	// 往左或者往右翻页
	if (page != self.currentPageIndex)
    {
        BOOL toRight = page > self.currentPageIndex;
        
        self.currentPageIndex = page;
		[self changePageIndicator];
        
        [self rebuildAlbum:page directRight:toRight];
	}
}

#pragma mark -
#pragma mark View loading and unloading
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		
		if (kSHOWGIRLNAME)
        {
			if (nil == self.girls)
            {
				self.girls = [NSMutableDictionary dictionary];
			}
			
			// 所有Girls
			self.girls = [HotGirlHelper fetchGirlsLite];
			
			// 排序后的Girls Id
			StringHelperExt *she = new StringHelperExt();
			int reverse = NO;
			NSArray *t = [self.girls allKeys];
			self.girlIds = [t sortedArrayUsingFunction:she->intSort context:&reverse];			
		}
		else
        {
			self.girlIds = [HotGirlHelper fetchGirlIds];
		}
		//NSLog(@"%@", self.girlIds);
		
		// 数量
		self.albumCount = [self.girlIds count];
		
		// 默认第一页
		self.currentPageIndex = 1;
		// 25.3页为26页
		self.pageCount = (int) ceil(1.0 * self.albumCount / kFotoAlbumThumbPerPage);

		// 添加ScrollView
		[self addScrollView:[self getScrollViewWidth:self.pageCount] withHeight:kScreenHeight];
		
		// 添加相册
		self.pagePrev = [self makeScrollPageView:0 forUIView:nil];
		[self.pagePrev setTag:kPagePrevTag];
		[self.fotoAlbum addSubview:self.pagePrev];
		
		self.pageCurrent = [self makeScrollPageView:1 forUIView:nil];
		[self.pageCurrent setTag:kPageCurrentTag];
		[self.fotoAlbum addSubview:self.pageCurrent];
		
		self.pageNext = [self makeScrollPageView:2 forUIView:nil];
		[self.pageNext setTag:kPageNextTag];
		[self.fotoAlbum addSubview:self.pageNext];
		
        // 添加页码指示
		[self addPageIndicator];
    }
	
	//NSLog(@"width: %g - height: %g", self.view.frame.size.width, self.view.frame.size.height);
	//NSLog(@"width: %g - height: %g", [self.view bounds].size.width, [self.view bounds].size.height);
	
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//self.title = NSLocalizedString(@"rootViewNavTitle", @"Title used for the Navigation Controller for the root view");	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	HotGirlAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate setFullScreen:self.navigationController isHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutForCurrentOrientation];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
	NSLog(@"come here from main view");
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	girls = nil;
	girlIds = nil;
	pageIndicator = nil;
	fotoAlbum = nil;
	pagePrev = nil;
	pageCurrent = nil;
	pageNext = nil;
	fotoViewController = nil;	
}

- (void)dealloc {
	[girls release];
	[girlIds release];
	[pageIndicator release];
	[fotoAlbum release];
	[pagePrev release];
	[pageCurrent release];
	[pageNext release];
	[fotoViewController release];
	
    [super dealloc];
}


@end
