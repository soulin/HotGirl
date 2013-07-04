    //
//  AboutHotGirlController.m
//  HotGirl
//
//  Created by liyuntian on 10-11-5.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "AboutHotGirlController.h"
#import "Constants.h"

@implementation AboutHotGirlController

@synthesize aboutTable, aboutInfo, aboutKeys, tempUrl, apps;

#pragma mark -
#pragma mark Self API
- (IBAction)backAction
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	//return [keys count];
	return [aboutKeys count] > 0 ? [aboutKeys count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([aboutKeys count] == 0) {
		return 0;
	}
	
	NSString *key= [aboutKeys objectAtIndex:section];
	NSArray *nameSection = [aboutInfo objectForKey:key];
	
	return [nameSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	NSString *key = [aboutKeys objectAtIndex:section];
	NSArray *nameSection = [aboutInfo objectForKey:key];
	
	static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:SectionsTableIdentifier] autorelease];
		
	}
	
	NSArray *line = [nameSection objectAtIndex:row];
	cell.textLabel.text = [line objectAtIndex:0];
	cell.detailTextLabel.text = [line objectAtIndex:1];
	
	// 加个图标，指示可以点击
	if (@"aboutihomewiki_apps" == key) {
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.tag = [cell.textLabel.text intValue];
		cell.textLabel.text = @"";
	}
	else {
		cell.accessoryType = UITableViewCellStateDefaultMask;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	//  网址
	if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"AboutHotGirlWebsite", nil)]) {
		cell.detailTextLabel.textColor = [UIColor blueColor];
	}
	
	return cell;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([aboutKeys count] == 0) {
		return @"";
	}
	
	NSString *key = [aboutKeys objectAtIndex:section];
	
	NSString *sectionTitle = nil;
	
	if (@"aboutihomewiki" == key) {
		sectionTitle = NSLocalizedString(@"AboutIHomeWiki", nil);
	}
	else if (@"aboutihomewiki_apps" == key) {
		sectionTitle = NSLocalizedString(@"AboutIHomeWikiApps", nil);
	}
	else if (@"aboutihomewiki_topgirl" == key) {
		sectionTitle = NSLocalizedString(@"AboutHotGirl", nil);
	}
	else {
		sectionTitle = key;
	}
	
	return sectionTitle;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	//如果是网址，则可以点击
	if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"AboutHotGirlWebsite", nil)]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:NSLocalizedString(@"OpenURLInSafari", nil)
									  delegate:self
									  cancelButtonTitle:NSLocalizedString(@"ButtonCancel", nil)
									  destructiveButtonTitle:NSLocalizedString(@"ButtonOK", nil)
									  otherButtonTitles:nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
		
		self.tempUrl = cell.detailTextLabel.text;
	}

	if (cell.tag > 389516900) {
		NSString *url = [NSString stringWithFormat:@"itms://itunes.apple.com/app/id%d?mt=8", cell.tag];
		[[UIApplication sharedApplication ] openURL:[NSURL URLWithString:url]]; 
	}
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	if (cell.tag > 389516900) {
		NSString *url = [NSString stringWithFormat:@"itms://itunes.apple.com/app/id%d?mt=8", cell.tag];
		[[UIApplication sharedApplication ] openURL:[NSURL URLWithString:url]]; 
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate Delegate Methods
-(void)actionSheet:(UIActionSheet *) actionSheet didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	if(!buttonIndex == [actionSheet cancelButtonIndex])
	{
		[[UIApplication sharedApplication ] openURL:[NSURL URLWithString:self.tempUrl]]; 
	}
}

- (void)aboutIHomeWiki
{
	NSMutableArray *keys = [[NSMutableArray alloc] init];
	[keys addObject:@"aboutihomewiki_topgirl"];
	[keys addObject:@"aboutihomewiki_apps"];
	[keys addObject:@"aboutihomewiki"];
	self.aboutKeys = keys;
	keys = nil;
	[keys release];
	
	// 关于内容
	NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
	
	/* 关于家庭百科 */
	NSMutableArray *items = [[NSMutableArray alloc] init];
	
	// 版本
	NSArray * version = [NSArray arrayWithObjects:NSLocalizedString(@"AboutHotGirlVersion", nil), kIHomeWikiVersion, nil];
	[items addObject:version];
	//[version release];
	
	// 网址
	NSArray * weburl = [NSArray arrayWithObjects:NSLocalizedString(@"AboutHotGirlWebsite", nil), kIHomeWikiWebsite, nil];
	[items addObject:weburl];
	//[weburl release];
	
	// Copyright
	NSArray * copyright = [NSArray arrayWithObjects:NSLocalizedString(@"AboutHotGirlCopyright", nil), kIHomeWikiCopyright, nil];
	[items addObject:copyright];
	//[copyright release];
	
	[info setObject:items forKey:@"aboutihomewiki"];
	[items release];
	
	/* 关于TopGirl系列 */
	NSMutableArray *topgirlItems = [[NSMutableArray alloc] init];
	
	// 版本
	NSString *sv = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];	
	NSArray * version_topgirl = [NSArray arrayWithObjects:NSLocalizedString(@"AboutHotGirlVersion", nil), sv, nil];
	[topgirlItems addObject:version_topgirl];
	
	// 网址
	NSArray * weburl_topgirl = [NSArray arrayWithObjects:NSLocalizedString(@"AboutHotGirlWebsite", nil), kIHomeWikiWebsiteOfTopGirl, nil];
	[topgirlItems addObject:weburl_topgirl];
	
	// Copyright
	NSArray * copyright_topgirl = [NSArray arrayWithObjects:NSLocalizedString(@"AboutHotGirlCopyright", nil), kIHomeWikiCopyrightOfTopGirl, nil];
	[topgirlItems addObject:copyright_topgirl];	
	
	[info setObject:topgirlItems forKey:@"aboutihomewiki_topgirl"];
	[topgirlItems release];
	
	/* 关于所有APP */
	NSMutableArray *appItems = [[NSMutableArray alloc] init];
	
	NSArray * app1 = [NSArray arrayWithObjects:@"393288356", NSLocalizedString(@"AppBaiduZhidaoHD", nil), nil];
	[appItems addObject:app1];

	NSArray * app2 = [NSArray arrayWithObjects:@"394072267", NSLocalizedString(@"AppBaiduZhidao", nil), nil];
	[appItems addObject:app2];

	NSArray * app3 = [NSArray arrayWithObjects:@"389516986", NSLocalizedString(@"AppHealthFitness", nil), nil];
	[appItems addObject:app3];	

	NSArray * app4 = [NSArray arrayWithObjects:@"390830814", NSLocalizedString(@"AppHealthFitnessFree", nil), nil];
	[appItems addObject:app4];	
	
	[info setObject:appItems forKey:@"aboutihomewiki_apps"];
	[appItems release];
	
	// 用于输出
	self.aboutInfo = info;
	[info release];
}


#pragma mark - View controller rotation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    //return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//*
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	CGRect rect = self.aboutTable.frame;
	rect.origin.y = self.navigationController.navigationBar.frame.size.height;
	self.aboutTable.frame = rect;
	//*/

	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// 导航标题
	self.title = NSLocalizedString(@"About", nil);
	
	// 返回按钮
	UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"AboutBack", nil)
																	style:UIBarButtonItemStyleBordered
																   target:self
																   action:@selector(backAction)] autorelease];
	self.navigationItem.leftBarButtonItem = backButton;
	
	[self aboutIHomeWiki];
	
	self.apps = [NSMutableDictionary dictionary];
	[self.apps setObject:@"itms://itunes.apple.com/app/id393288356?mt=8" forKey:@"AppBaiduZhidaoHD"];
	[self.apps setObject:@"itms://itunes.apple.com/app/id394072267?mt=8" forKey:@"AppBaiduZhidao"];
	[self.apps setObject:@"itms://itunes.apple.com/app/id389516986?mt=8" forKey:@"AppHealthFitness"];
	[self.apps setObject:@"itms://itunes.apple.com/app/id390830814?mt=8" forKey:@"AppHealthFitnessFree"];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	aboutInfo = nil;
	aboutTable = nil;
	aboutKeys = nil;
	apps = nil;
}


- (void)dealloc {
	[aboutInfo release];
	[aboutTable release];
	[aboutKeys release];
	[apps release];
	
	[aboutInfo release];
	[aboutKeys release];
	
    [super dealloc];
}


@end
