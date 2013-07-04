
//
//  FotoViewController.m
//  HotGirl
//
//  Created by 李云天 on 10-10-18.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "FotoViewController.h"
#import "HotGirl.h"
#import "HotGirlHelper.h"
#import "HotGirlAppDelegate.h"
#import "MsgBoxHelper.h"
#import "ReportBug.h"
#import "MainViewController.h"
#import "AboutHotGirlController.h"
#import "Constants.h"

@interface FotoViewController (AutoscrollingMethods)
- (void)autoscrollTimerFired:(NSTimer *)timer;
- (void)stopAutoscroll;
// 自动播放时，更改按钮图片
- (void)changePlayItemTo:(UIBarButtonSystemItem)item;
@end

@interface FotoViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(FotoScrollView *)aview zoomScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation FotoViewController
@synthesize aboutHotGirlController, pagingScrollView, girlFotoes, girl, girlId, isSameGirl;

- (void)releaseFotoView
{
	for (FotoScrollView *page in [pagingScrollView subviews]) {
		[page removeFromSuperview];
    }
	/*
	[pagingScrollView removeFromSuperview];
	[pagingScrollView release];
	pagingScrollView = nil;
	//*/

	[visiblePages removeAllObjects];
	[recycledPages removeAllObjects];
}

- (void)setGirlId:(NSUInteger)newGirlId
{
	isSameGirl = YES;
	if (girlId != newGirlId) {
		isSameGirl = NO;
		
		girlId = newGirlId;
		
		[self fetchGilr];
	}

}

- (void)fetchGilr
{
	if (nil == self.girlFotoes) {
		self.girlFotoes = [NSMutableArray array];
	}

	self.girlFotoes = [HotGirlHelper fetchGirlFotoes:self.girlId];
	self.girl = [HotGirlHelper fetchGirl:self.girlId];
	self.title = girl.girlName;
}

// 查看帮助
- (IBAction)viewAboutInfo:(id)sender
{	
	if (self.aboutHotGirlController == nil) {
		self.aboutHotGirlController = [[AboutHotGirlController alloc] initWithNibName:@"AboutHotGirl" bundle:nil];
	}
	UINavigationController *about = [[UINavigationController alloc] initWithRootViewController:self.aboutHotGirlController];
	
	//about.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:about animated:YES];
	
	[about release];
}

#pragma mark - 工具栏按钮

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
	NSString *msg = error ? [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"UIImageWriteToSavedPhotosAlbumFail", nil), [error description]] : NSLocalizedString(@"UIImageWriteToSavedPhotosAlbumOK", nil);
	
	[MsgBoxHelper showMsgBoxOK:msg fromDeleate:self];
}

// 工具栏上的播放、暂停按钮
- (UIBarButtonItem *)createToolbarPlayItem:(UIBarButtonSystemItem)item
{
	UIBarButtonItem *playItem = [[[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:item
								  target:self 
								  action:@selector(playAction)] 
								 autorelease];
	return playItem;
}

// 自动播放时，更改按钮图片
- (void)changePlayItemTo:(UIBarButtonSystemItem)item
{
	NSMutableArray *tbItems = [[NSMutableArray arrayWithArray:self.toolbarItems] retain];

	UIBarButtonItem *tbitem = [self createToolbarPlayItem:item];
	[tbItems replaceObjectAtIndex:2 withObject:tbitem];
	self.toolbarItems = tbItems;
	[tbItems release];
}

// 自动播放
- (IBAction)playAction {
	FotoScrollView *page = [visiblePages anyObject];
	
	if (nil == autoscrollTimer) {
		
		[self changePlayItemTo:UIBarButtonSystemItemPause];
		
		autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
														   target:self 
														 selector:@selector(autoscrollTimerFired:) 
														 userInfo:page
														  repeats:YES];
		// 隐藏工具栏
		HotGirlAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate setFullScreen:self.navigationController isHidden:YES];
	}
	else {
		[self stopAutoscroll];
	}
}

// 查看当前的网址
- (IBAction)viewinfoAction {
	[self stopAutoscroll];
	
	NSString *website;
	if ([self.girl.website isEqualToString:@""]) {
		website = kMokoWebsite;
	}
	else {
		website = self.girl.website;
	}

	[[UIApplication sharedApplication ] openURL:[NSURL URLWithString:website]];
}

// 将当前图片写到保存的相册中
- (void) saveToSystemAlbum
{
	[self stopAutoscroll];
	
	FotoScrollView *page = [visiblePages anyObject];
    UIImageWriteToSavedPhotosAlbum([self imageAtIndex:page.index], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void) mailToOther
{
	[self stopAutoscroll];
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	
	NSString *subject = self.girl.girlName;
	NSString *body = @"";
    
	FotoScrollView *page = [visiblePages anyObject];
	NSString *imageName = [page.imageName stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
	//NSLog(@"%@", imageName);
	
	// We must always check whether the current device is configured for sending emails
	if (mailClass != nil && [mailClass canSendMail])
	{
		[self displayComposerSheet:subject mailBody:body mailAttach:imageName];
	}
	else
	{
		[ReportBug launchMailAppOnDevice:subject mailBody:body];
	}
}
#pragma mark - Action Sheet Method
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d", buttonIndex);
	switch (buttonIndex) 
    {
		case 0:
            [self saveToSystemAlbum];
			break;
		case 1:
			[self mailToOther];
			break;
		default:
			break;
	}
}

// 共享
- (IBAction) shareAction
{	
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:NSLocalizedString(@"Share", nil)
								  delegate:self
								  cancelButtonTitle:NSLocalizedString(@"ButtonCancel", nil)
								  destructiveButtonTitle:nil
								  otherButtonTitles:NSLocalizedString(@"Share.Savetoalbum", nil), NSLocalizedString(@"Share.Mailtoother", nil),nil
                                  ];
	[actionSheet showFromToolbar:self.navigationController.toolbar];
	[actionSheet release];
}

// 在工具栏上添加按钮
- (void)addToolbarButton
{
    UIBarButtonItem *shareItem = [[[UIBarButtonItem alloc] 
                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                              target:self
                              action:@selector(shareAction)]
                              autorelease];
	
	// Create a space item and set it and the search bar as the items for the toolbar.
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

	UIBarButtonItem *playItem = [self createToolbarPlayItem:UIBarButtonSystemItemPlay];
	
    UIBarButtonItem *spaceItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];

	UIBarButtonItem *viewinfoItem = [[[UIBarButtonItem alloc] 
								  initWithImage:[UIImage imageNamed:@"icon_girlinfo.png"]
								  style:UIBarButtonItemStylePlain
								  target:self 
								  action:@selector(viewinfoAction)] 
								 autorelease];
	
	self.toolbarItems = [NSArray arrayWithObjects:shareItem, spaceItem, playItem, spaceItem2, viewinfoItem, nil];
}

- (void)showFotoes
{
	DebugRect(self.view.frame);

    // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    // Recycle no-longer-visible pages 
    for (FotoScrollView *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
        DebugObj(page);
    }
    [visiblePages minusSet:recycledPages];
    
    DebugObj(recycledPages);
    DebugObj(visiblePages);
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            FotoScrollView *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[[FotoScrollView alloc] init] autorelease];
				[page setTapDelegate:self];
            }
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }
}

- (FotoScrollView *)dequeueRecycledPage
{
    FotoScrollView *page = [recycledPages anyObject];
    if (page) {
        [[page retain] autorelease];
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (FotoScrollView *page in visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(FotoScrollView *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
	page.imageName = [self imageNameAtIndex:index];
	
	[page displayImage:[self imageAtIndex:index]];
}


#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	DebugPoint(scrollView.contentOffset);
    [self showFotoes];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayComposerSheet:(NSString *)subject mailBody:(NSString *)body mailAttach:(NSString *)attach
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:subject];
	
	// Attach an image to the email
	NSString *path = [[NSBundle mainBundle] pathForResource:attach ofType:@"jpg"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
	[picker addAttachmentData:myData mimeType:@"image/jpeg" fileName:attach];
	
	// Fill out the email body text
	NSString *emailBody = body;
	[picker setMessageBody:emailBody isHTML:YES];
	
	[self presentModalViewController:picker animated:YES];
    
	[picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	NSString *msg = @"";
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//msg = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			msg = NSLocalizedString(@"MailResultSaved", nil);
			break;
		case MFMailComposeResultSent:
			msg = NSLocalizedString(@"MailResultSent", nil);
			break;
		case MFMailComposeResultFailed:
			msg = NSLocalizedString(@"MailResultFailed", nil);
			break;
		default:
			msg = NSLocalizedString(@"MailNotSent", nil);
			break;
	}
	
	// 用于修正邮件视图关闭后，回到pagingScrollView开头的问题
	CGPoint offset = self.pagingScrollView.contentOffset;

	[self dismissModalViewControllerAnimated:YES];
	
	// 用于修正邮件视图关闭后，回到pagingScrollView开头的问题
	[self.pagingScrollView setContentOffset:offset];
	
	if (![msg isEqualToString:@""]) {
		[MsgBoxHelper showMsgBoxOK:msg fromDeleate:self];
	}
}

#pragma mark -
#pragma mark TapDetectingImageViewDelegate methods

- (void)fotoScrollView:(FotoScrollView *)aview gotSingleTapAtPoint:(CGPoint)tapPoint {
	[self stopAutoscroll];
	
    // Single tap shows or hides toolbar.
	HotGirlAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate setFullScreen:self.navigationController isHidden:!self.navigationController.toolbarHidden];
}

- (void)fotoScrollView:(FotoScrollView *)aview gotDoubleTapAtPoint:(CGPoint)tapPoint {
	[self stopAutoscroll];
    // double tap zooms in

	CGFloat xScale = aview.frame.size.width / aview.contentSize.width;
	CGFloat yScale = aview.frame.size.height / aview.contentSize.height;
	CGFloat newScale = MIN(xScale, yScale);
	
    CGRect zoomRect = [self zoomRectForScale:aview zoomScale:newScale withCenter:tapPoint];
    [aview zoomToRect:zoomRect animated:YES];
}

- (void)fotoScrollView:(FotoScrollView *)aview gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
	[self stopAutoscroll];
	
    // two-finger tap zooms out
}

#pragma mark - View controller rotation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    //return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    // here, our pagingScrollView bounds have not yet been updated for the new interface orientation. So this is a good
    // place to calculate the content offset that we will need in the new orientation

    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    
    if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }        
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DebugRect(pagingScrollView.bounds);
    DebugRect(pagingScrollView.frame);
    DebugPoint(pagingScrollView.contentOffset);
    DebugRect(self.view.bounds);
    DebugRect(self.view.frame);
    DebugRect([[UIScreen mainScreen] bounds]);
    
	// Frame needs changing
	pagingScrollView.frame = [self frameForPagingScrollView];
    
    // recalculate contentSize based on current orientation
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // adjust frames and configuration of each visible page
    for (FotoScrollView *page in visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    
    [pagingScrollView setContentOffset: CGPointMake(newOffset, 0)];
}

#pragma mark - Frame calculations

#define PADDING  0

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;;
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self imageCount], bounds.size.height);
}

#pragma mark -
#pragma mark Image wrangling
- (UIImage *)imageAtIndex:(NSUInteger)index {
    NSString *imageName = [self imageNameAtIndex:index];

    // use "imageWithContentsOfFile:" instead of "imageNamed:" here to avoid caching our images
	imageName = [imageName stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    return [UIImage imageWithContentsOfFile:path];
}

- (NSString *)imageNameAtIndex:(NSUInteger)index {
    NSString *name = nil;
    if (index < [self imageCount]) {
        name = [self.girlFotoes objectAtIndex:index];
    }

    return name;
}

- (NSUInteger)imageCount {
    return [self.girlFotoes count];
}

#pragma mark -
#pragma mark Autoscrolling methods
- (void)autoscrollTimerFired:(NSTimer*)timer {
	CGPoint offset = self.pagingScrollView.contentOffset;
	
	if (offset.x + self.view.frame.size.width < self.pagingScrollView.contentSize.width)
	{
		CGPoint newOffset = CGPointMake(offset.x + self.view.frame.size.width, offset.y);
		[self.pagingScrollView setContentOffset:newOffset animated:YES];
	}
	
	// 当到最后一张时，停止自动播放
	if (offset.x + 2 * self.view.frame.size.width >= self.pagingScrollView.contentSize.width)
	{
		[self stopAutoscroll];
	}

}

// 停止自动播放，只要屏幕上有点击，即停止
- (void)stopAutoscroll
{
	[autoscrollTimer invalidate];
	autoscrollTimer = nil;
	
	[self changePlayItemTo:UIBarButtonSystemItemPlay];
}

#pragma mark -
#pragma mark Utility methods

- (CGRect)zoomRectForScale:(FotoScrollView *)aview zoomScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [aview frame].size.height / scale;
    zoomRect.size.width  = [aview frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark -
#pragma mark View loading and unloading

- (void)didReceiveMemoryWarning {
    // Release any cached data, images, etc that aren't in use.
    
    // Release images
	[recycledPages removeAllObjects];
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (id) init {
    if ((self = [super init])) {
		[self addToolbarButton];
        
        // Step 1: make the outer paging scroll view
        pagingScrollView = [[UIScrollView alloc] init];
        pagingScrollView.pagingEnabled = YES;
        pagingScrollView.backgroundColor = [UIColor whiteColor];
        pagingScrollView.showsVerticalScrollIndicator = NO;
        pagingScrollView.showsHorizontalScrollIndicator = NO;
        pagingScrollView.delegate = self;
        [pagingScrollView setBouncesZoom:YES];
        
        //self.view = pagingScrollView;
        [[self view] addSubview:pagingScrollView];
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
        [self.view setBackgroundColor:[UIColor grayColor]];
        
        // Step 2: prepare to tile content
        recycledPages = [[NSMutableSet alloc] init];
        visiblePages  = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    
    [pagingScrollView setFrame: [self frameForPagingScrollView]];
    [pagingScrollView setContentSize: [self contentSizeForPagingScrollView]];
    [pagingScrollView setContentOffset: CGPointMake(0.0, 0.0)];
    
    if (!self.isSameGirl)
    {
        for (FotoScrollView *page in [pagingScrollView subviews])
        {
            [page removeFromSuperview];
        }
        
        [visiblePages removeAllObjects];
        [recycledPages removeAllObjects];
    }
    
    [self showFotoes];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// 关于按钮
    /*
	UIBarButtonItem *aboutButton = [[[UIBarButtonItem alloc] 
									  initWithImage:[UIImage imageNamed:@"tb_about.png"]
									  style:UIBarButtonItemStylePlain
									  target:self 
									 action:@selector(viewAboutInfo:)] 
									 autorelease];
	self.navigationItem.rightBarButtonItem = aboutButton;
    [aboutButton release];
    */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	//[aboutHotGirlController release];
	aboutHotGirlController = nil;
    //[pagingScrollView release];
    pagingScrollView = nil;
    //[recycledPages release];
    recycledPages = nil;
    //[visiblePages release];
    visiblePages = nil;
	
	//[girlFotoes release];
	girlFotoes = nil;
	//[girl release];
	girl = nil;
}

- (void)dealloc
{
	[aboutHotGirlController release];
    [pagingScrollView release];
	[girlFotoes release];
	[girl release];
	[recycledPages release];
	[visiblePages release];
	
    [super dealloc];
}
@end
